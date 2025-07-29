/**
 * @author Hitesh
 * @since  July 2025
 * @group Platform
 * @description Service class for FinancialSummary
 */
public with sharing virtual class FinancialSummaryService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @description to get the callout response Financial Service Endpoint
   * @param endPoint - endpoint to which we have to make a callout
   * @param requestObj - searlized wrapper object
   * @param useStaffToken - Boolean JWE Staff token is used (ex - TML)
   * @return HttpCalloutResponse - callout response
   */
  public virtual HttpCalloutResponse getFinancialSummaryResponse(
    String endPoint,
    String requestObj,
    Boolean useStaffToken
  ) {
    Map<String, String> headers = new Map<String, String>();
    HTTP_METHOD method = HTTP_METHOD.HTTP_POST;
    if (useStaffToken) {
      headers = generateHeaderForStaffToken();
    } else {
      headers = generateHeader();
    }
    return CALLOUT.makeRestCallout(endPoint, method, headers, requestObj);
  }

  /**
   * @description This method is used to generate Header
   * @return Map<String, String> return the header in form of key-value pair
   */
  @TestVisible
  private static Map<String, String> generateHeader() {
    Map<String, String> headers = new Map<String, String>();
    headers.put('Channel', 'DCRM');
    headers.put('Content-Type', 'application/json');
    headers.put('X-Workstation', System.Label.Customer_Auth_Workstation);
    headers.put(
      'X-Operator-Branch',
      System.Label.Customer_Auth_Operator_Branch
    );
    headers.put(
      'X-Originating-App',
      System.Label.Customer_Auth_Originating_App
    );
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Authorization', 'Bearer ' + ARNCService.generateJWTToken());
    return headers;
  }

  /**
   * @description This method is used to generate Header based on JWE Staff Token
   * @return Map<String, String> return the header in form of key-value pair
   */
  @TestVisible
  private static Map<String, String> generateHeaderForStaffToken() {
    Service serv = new Service();
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.realm = 'system';
    staffModel.apiScopesRequested = 'DCRM_FinSummary';
    Map<String, String> headers = serv.setCalloutCommonHeaders(staffModel);
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Content-type', 'application/json');
    headers.put('X-Originating-App', 'CRM');
    headers.put('X-Operator-Branch', '1234');
    return headers;
  }
}
