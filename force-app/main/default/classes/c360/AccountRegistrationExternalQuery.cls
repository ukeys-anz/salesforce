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
    public String cardLast4digits;
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
      Integer strNumberofAsterisk = (Integer) MAP_OF_STATUS
        ?.get(crnDetails.registrationType)
        ?.get('asteriskCount');
      String statusValue = crnDetails.registrationType ==
        CUSTOMER_REGISTRATION_NUMBER
        ? crnDetails.registrationStatus
        : crnDetails.cardStatus;
      Map<String, Object> row = new Map<String, Object>{
        'tokenizedRegistrationNo' => crnDetails.tokenizedRegistrationNo,
        'registrationType' => crnDetails.registrationType,
        'registrationStatus' => mapOfStatus?.get(statusValue) ?? statusValue,
        'customerPreferredName' => crnDetails.customerPreferredName,
        'crnLast4Digits' => getMaskedRegistrationNumber(
          strNumberofAsterisk,
          crnDetails.crnLast4Digits
        ),
        'cardLast4digits' => getMaskedRegistrationNumber(
          12,
          crnDetails.cardLast4digits
        ),
        this.parentField => this.parentId,
        'ExternalId' => this.parentId?.substringAfter('-') +
        '-' +
        crnDetails.tokenizedRegistrationNo +
        '-' +
        getMaskedRegistrationNumber(
          strNumberofAsterisk,
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
    if(this.parentId == null) {
      return;
    }
    ARNCService service = new ARNCService();
    String accNumber = this.parentId.substringAfter('|');
    HttpCalloutResponse response = service.queryAccountRegistrations(accNumber);
    return response;
  }

  /**
   * @param strNumberofAsterisk String
   * @param cardNumber String
   * @return String
   * @description method to generate masked CRN
   */
  @TestVisible
  private String getMaskedRegistrationNumber(
    Integer strNumberofAsterisk,
    String cardNumber
  ) {
    return '*'.repeat(strNumberofAsterisk) + cardNumber;
  }
}
