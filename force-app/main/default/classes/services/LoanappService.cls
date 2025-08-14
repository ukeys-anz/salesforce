/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group Platform
 * @description Service class for Salesforce to Create application in LEX
 */
public with sharing virtual class LoanappService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  /**
   * @description to get the callout response from Create Application endpoint
   * @param model LoanappModel
   * @return String
   */
  public String getCreateApplicationCalloutResponse(LoanappModel model) {
    if (model == null) {
      return null;
    }
    String createApplicationEndpoint = Label.CreateApplicationEndpoint;
    String payLoad = JSON.serialize(model, true);
    ARNCService service = new ARNCService();
    HttpCalloutResponse response = service.makeLoanappCallout(
      createApplicationEndpoint,
      payLoad
    );
    if (!response.successful) {
      throw response.error;
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    List<Object> extRefs = responseMap.containsKey('externalReferences')
      ? (List<Object>) responseMap.get('externalReferences')
      : new List<Object>();
    Object firstEntry = !extRefs.isEmpty() ? extRefs[0] : null;
    String applicationKey = (firstEntry != null)
      ? String.valueOf(firstEntry).substringAfter('simpology/')
      : null;
    return applicationKey;
  }

  /**
   * @description to get the callout response from ANZ Plus Loanapp Callout
   * @param model ANZ Plus Loanapp model
   * @return HttpCalloutResponse
   */
  public virtual HttpCalloutResponse getANZPlusLoanappCalloutResponse(
    ANZPlusLoanAppModel model
  ) {
    if (model == null) {
      return null;
    }
    String payLoad = JSON.serialize(model, true);
    Map<String, String> headers = getHeaders();
    Lib_HttpCallout.RESTCalloutWrapper restWrap = new Lib_HttpCallout.RESTCalloutWrapper();
    restWrap.endpoint = Label.CreateApplicationEndpoint;
    restWrap.method = HTTP_METHOD.HTTP_POST;
    restWrap.headers = headers;
    restWrap.requestBody = payload;
    restWrap.timeout = 120000;
    return CALLOUT.makeRestCallout(restWrap);
  }

  /**
   * @description to get the callout headers for Callout
   * @return Map<String, String>
   */
  private static Map<String, String> getHeaders() {
    User currentUser = USER_INFO.getUser();
    Map<String, String> headers = new Map<String, String>{
      'Channel' => 'DCRM',
      'Content-Type' => 'application/json',
      'X-Workstation' => Label.Customer_Auth_Workstation,
      'X-Operator-Branch' => Label.Customer_Auth_Operator_Branch,
      'X-Originating-App' => Label.Customer_Auth_Originating_App,
      'client_id' => '{!$Credential.Username}',
      'client_secret' => '{!$Credential.Password}',
      'x-correlation-id' => UniqueIdUtil.getTraceId(),
      'Authorization' => 'Bearer ' + AuthTokenCacheUtil.getSessionIdToken()
    };
    if (String.isNotEmpty(currentUser.Lan_Id__c)) {
      headers.put('X-Operator-Id', currentUser.Lan_Id__c);
    }
    return headers;
  }
}
