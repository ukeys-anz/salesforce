/**
 * @author Ashish Kumar
 * @since August 2024
 * @description extended service class for ANZ Retail & Commercial banking API calls
 * @group Service
 * @runTests AccountRegistrationExternalQueryTest
 */
public with sharing class AccountRegistrationExternalQuery extends ExternalObjectQueryBase {
  private static final String CUSTOMER_REGISTRATION_NUMBER = 'Customer Registration Number';
  private static final string CARD_NUMBER = 'Card Number';
  private static final Map<String, Map<String, Object>> MAP_OF_STATUS = new Map<String, Map<String, Object>>{
    CUSTOMER_REGISTRATION_NUMBER => new Map<String, Object>{
      'asteriskCount' => 5,
      'statuses' => new Map<String, String>{
        'A' => 'A - Active',
        'I' => 'I - Inactive',
        'S' => 'S - Suspended',
        'C' => 'C - Closed'
      }
    },
    CARD_NUMBER => new Map<String, Object>{
      'asteriskCount' => 12,
      'statuses' => new Map<String, String>{
        'A' => 'A - Blocked',
        'B' => 'B - Blocked',
        'C' => 'C - Closed',
        'D' => 'D - Delinquent',
        'E' => 'E - Delinquent',
        'F' => 'F - Blocked',
        'G' => 'G - Blocked',
        'H' => 'H - Blocked',
        'I' => 'I - Issued',
        'L' => 'L - Lost',
        'P' => 'P - Blocked',
        'R' => 'R - Registration',
        'S' => 'S - Stolen',
        'T' => 'T - Blocked',
        'U' => 'U - Unissued'
      }
    }
  };
  /**
   * @description constructor
   */
  public AccountRegistrationExternalQuery() {
    this.enableServerPagination = false;
  }

  /**
   * @description class for List of account registration callout response
   */
  public class AccountRegistrationCalloutResponse extends ExternalObjectQueryBase.ExternalObjectCalloutResponse {
    List<CRNDetailWrapper> crnDetails;
  }

  /**
   * @description class for account registration callout response
   */
  public class CRNDetailWrapper {
    public String tokenizedRegistrationNo;
    public String crnLast4Digits;
    public String customerPreferredName;
    public String registrationType;
    public String registrationStatus;
    public String cardStatus;
  }

  /**
   * @description public execute method
   * @param queryContext DataSource.QueryContext
   * @return ExternalObjectQueryBase.ExternalQueryResult query result
   */
  public override virtual ExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    QueryModeEnum queryMode = prepareCallout(queryContext);
    if (queryMode == QueryModeEnum.RECORD_DETAIL) {
      return createDummyExternalRecord(
        this.externalId,
        new Map<String, Object>{
          'crnLast4Digits' => this.externalId?.substringAfterLast('-')
        }
      );
    }
    HttpCalloutResponse response = makeCallout(queryMode, queryContext);
    this.calloutResponse = parseResponse(response.body);
    return createExternalRecords(this.calloutResponse);
  }

  /**
   * @description Deserialize API callout response
   * @param responseBody API response payload
   * @return ExternalObjectCalloutResponse
   */
  @testVisible
  protected override ExternalObjectCalloutResponse parseResponse(
    String responseBody
  ) {
    if (String.isBlank(responseBody)) {
      return this.calloutResponse;
    }
    this.calloutResponse = (AccountRegistrationCalloutResponse) CalloutModel.deserialize(
      responseBody,
      AccountRegistrationCalloutResponse.class
    );
    return this.calloutResponse;
  }

  /**
   * @description Transform API response to diary comment records
   * @param calloutResponse response
   * @return List<Map<String, Object>>
   */
  protected override ExternalObjectQueryBase.ExternalQueryResult createExternalRecords(
    ExternalObjectCalloutResponse calloutResponse
  ) {
    ExternalObjectQueryBase.ExternalQueryResult result = new ExternalObjectQueryBase.ExternalQueryResult();
    if (calloutResponse == null) {
      return result;
    }
    AccountRegistrationCalloutResponse accountRegistrationCalloutResponse = (AccountRegistrationCalloutResponse) calloutResponse;
    for (
      CRNDetailWrapper crnDetails : accountRegistrationCalloutResponse.crnDetails
    ) {
      Map<String, String> mapOfStatus = (Map<String, String>) MAP_OF_STATUS.get(
          crnDetails.registrationType
        )
        ?.get('statuses');
      String statusValue = crnDetails.registrationType ==
        CUSTOMER_REGISTRATION_NUMBER
        ? crnDetails.registrationStatus
        : crnDetails.cardStatus;
      Map<String, Object> row = new Map<String, Object>{
        'tokenizedRegistrationNo' => crnDetails.tokenizedRegistrationNo,
        'registrationType' => crnDetails.registrationType,
        'registrationStatus' => mapOfStatus?.get(statusValue)
        ?? statusValue,
        'customerPreferredName' => crnDetails.customerPreferredName,
        'crnLast4Digits' => getMaskedRegistrationNumber(
          crnDetails.registrationType,
          crnDetails.crnLast4Digits
        ),
        this.parentField => this.parentId,
        'ExternalId' => this.parentId?.substringAfter('-') +
        '-' +
        crnDetails.tokenizedRegistrationNo +
        '-' +
        getMaskedRegistrationNumber(
          crnDetails.registrationType,
          crnDetails.crnLast4Digits
        ),
        'DisplayUrl' => getDisplayUrl(
          'AR-' + crnDetails.tokenizedRegistrationNo
        )
      };
      result.externalRecords.add(row);
    }

    return result;
  }

  /**
   * @description Rest API callout to get diary comments
   * @param queryMode QueryMode Enum
   * @param queryContext DataSource QueryContext
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout(
    QueryModeEnum queryMode,
    DataSource.QueryContext queryContext
  ) {
    ARNCService service = new ARNCService();
    String endPoint = buildEndpoint(queryMode);
    HttpCalloutResponse response = service.queryAccountRegistrations(endPoint);
    return response;
  }

  /**
   * @param queryMode enum to determine if it is related list or detail page
   * @return HttpCalloutResponse
   * @description method to build endpoint
   */
  @TestVisible
  private String buildEndpoint(QueryModeEnum queryMode) {
    String endPoint = Label.Account_Registration_Endpoint;
    // endpoint in case of related list
    if (queryMode == QueryModeEnum.RELATED_LIST) {
      String accNumber = this.parentId.substringAfter('-');
      endPoint = endPoint.replace('{accountNumber}', accNumber);
    }
    return endPoint;
  }

  /**
   * @param registrationType String
   * @param crnLast4Digits String
   * @return String
   * @description method to generate masked CRN
   */
  @TestVisible
  private String getMaskedRegistrationNumber(
    String registrationType,
    String crnLast4Digits
  ) {
    return '*'
        .repeat(
          (Integer) MAP_OF_STATUS?.get(registrationType).get('asteriskCount')
        ) + crnLast4Digits;
  }
}
