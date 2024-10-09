/**
 * @author Ashish Kumar
 * @since  08/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description Account Registration external query base class
 */
public with sharing class CCRMAccountRegistrationQuery extends CCRMExternalObjectQueryBase {
  private static final Map<String, Map<String, Object>> MAP_OF_STATUS = new Map<String, Map<String, Object>>{
    CCRMConstants.CUSTOMER_REGISTRATION_NUMBER => new Map<String, Object>{
      'asteriskCount' => 5,
      'statuses' => new Map<String, String>{
        'A' => 'A - Active',
        'I' => 'I - Inactive',
        'S' => 'S - Suspended',
        'C' => 'C - Closed'
      }
    },
    CCRMConstants.CARD_NUMBER => new Map<String, Object>{
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
  public CCRMAccountRegistrationQuery() {
    this.enableServerPagination = false;
  }

  /**
   * @description class for List of account registration callout response
   */
  public class AccountRegistrationCalloutResponse {
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
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result
   */
  public override virtual CCRMExternalObjectQueryBase.ExternalQueryResult execute(
    DataSource.QueryContext queryContext
  ) {
    super.execute(queryContext);
    getParent();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    prepareCallout();
    try {
      if (String.isNotBlank(this.externalId) && String.isBlank(this.parentId)) {
        Map<String, Object> row = new Map<String, Object>{
          'ExternalId' => this.externalId,
          'crnLast4Digits' => this.externalId?.substringAfterLast('-'),
          'AdditionalInformation' => 'No further information available'
        };
        result.queryResult.add(row);
        return result;
      }
      HttpCalloutResponse response = makeCallout();
      if (!response.successful || response.body == null) {
        Logger.error('Error : ' + response.error);
        Logger.saveLog();
        return result;
      }
      AccountRegistrationCalloutResponse calloutResponse = (AccountRegistrationCalloutResponse) System.JSON.deserialize(
        response.body,
        AccountRegistrationCalloutResponse.class
      );
      result = createAccountRegistration(calloutResponse);
    } catch (Exception e) {
      Logger.error('Error : ' + e.getMessage());
      Logger.saveLog();
    }
    return result;
  }

  /**
   * @description Transform API response to diary comment records
   * @param calloutResponse response
   * @return CCRMExternalObjectQueryBase.ExternalQueryResult query result
   */
  private CCRMExternalObjectQueryBase.ExternalQueryResult createAccountRegistration(
    AccountRegistrationCalloutResponse calloutResponse
  ) {
    CCRMExternalObjectQueryBase.ExternalQueryResult result = new CCRMExternalObjectQueryBase.ExternalQueryResult();
    Map<String, Object> row;
    if (calloutResponse == null) {
      return result;
    }
    for (CRNDetailWrapper crnDetails : calloutResponse.crnDetails) {
      row = new Map<String, Object>();
      Map<String, String> mapOfStatus = (Map<String, String>) MAP_OF_STATUS.get(
          crnDetails.registrationType
        )
        ?.get('statuses');
      String statusValue = crnDetails.registrationType ==
        CCRMConstants.CUSTOMER_REGISTRATION_NUMBER
        ? crnDetails.registrationStatus
        : crnDetails.cardStatus;
      row = new Map<String, Object>{
        'tokenizedRegistrationNo' => crnDetails.tokenizedRegistrationNo,
        'registrationType' => crnDetails.registrationType,
        'registrationStatus' => mapOfStatus?.get(statusValue)
          ?? statusValue,
        'customerPreferredName' => crnDetails.customerPreferredName,
        'crnLast4Digits' => getMaskedRegistrationNumber(
          crnDetails.registrationType,
          crnDetails.crnLast4Digits
        ),
        this.parent => this.parentId,
        'ExternalId' => this.parentId?.substringAfter('-') +
        '-' +
        crnDetails.tokenizedRegistrationNo +
        '-' +
        getMaskedRegistrationNumber(
          crnDetails.registrationType,
          crnDetails.crnLast4Digits
        ),
        'DisplayUrl' => URL.getOrgDomainUrl().toExternalForm() +
        'AR-' +
        crnDetails.tokenizedRegistrationNo
      };
      result.queryResult.add(row);
    }

    return result;
  }
  /**
   * @description Parse query filters and prepare for API calls
   * @param
   */
  protected override void prepareCallout() {
    parseFilters(this.parent);
  }
  /**
   * @description Rest API callout to get diary comments
   * @param
   * @return HttpCalloutResponse
   */
  protected virtual override HttpCalloutResponse makeCallout() {
    CCRMARNCService service = new CCRMARNCService();
    Map<String, String> attributes = new Map<String, String>();
    if (String.isNotBlank(this.parent) && String.isNotBlank(this.parentId)) {
      attributes.put(this.parent, this.parentId);
    }
    String endPoint = buildEndpoint(this.parent, attributes);
    HttpCalloutResponse response = service.queryAccountRegistrations(endPoint);
    return response;
  }

  /**
   * @param parent parent
   * @param params String
   * @return HttpCalloutResponse
   * @description method to build endpoint
   */
  @TestVisible
  private String buildEndpoint(String parent, Map<String, String> params) {
    String parentValue = params.get(parent);
    String endPoint = Label.Account_Registration_Endpoint;

    // process parent value if it exists
    if (parentValue != null && parentValue.contains('-')) {
      String accNumber = parentValue.substringAfter('-');
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
