/**
 * @author Ian Huang
 * @since July 2025
 * @description extended C360 service class for ANZ Retail & Commercial banking API calls
 * @group Service
 * @runTests ARNC360ServiceTest
 */
public with sharing class ARNC360Service extends Service {
  private static final UserInfoRepository USER_INFO_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  /**
   * @param calloutRequest ExternalObjectCalloutRequestBase
   * @return HttpCalloutResponse
   * @description Generic method for querying exernal data via API
   */
  public HttpCalloutResponse queryExternalData(
    ExternalObjectQueryBase.ExternalObjectCalloutRequestBase calloutRequest
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers, calloutRequest.getStaffModel());
    Lib_HttpCallout.RESTCalloutWrapper restWrap = new Lib_HttpCallout.RESTCalloutWrapper();
    restWrap.endpoint = calloutRequest.getEndpoint();
    restWrap.method = HTTP_METHOD.HTTP_POST;
    restWrap.headers = headers;
    restWrap.requestBody = calloutRequest.getPayload();
    restWrap.timeout = calloutRequest.timeout;
    return calloutService.makeRestCallout(restWrap);
  }

  /**
   * @return String jwt token
   * @description generate jwt token
   */
  public static String generateJWTToken() {
    Auth.JWT jwt = new Auth.JWT();
    jwt.setAud('mulesoft');
    jwt.setIss('salesforce');
    jwt.setSub(UserInfo.getUserEmail());
    jwt.setValidityLength(15);

    //determine JWT signing certificate based on if the org is Production or Sandbox
    String jwtSigningCert = SFConstants.IS_SANDBOX
      ? System.Label.CCRM_JWT_Siging_Certificate_NP
      : System.Label.CCRM_JWT_Siging_Certificate;
    Auth.JWS jws = new Auth.JWS(jwt, jwtSigningCert);

    String token = jws.getCompactSerialization();
    return token;
  }

  /**
   * @param headers key value pairs of headers to set
   * @param staffModel staffModel
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
  private Map<String, String> setCommonHeaders(
    Map<String, String> headers,
    StaffTokenRequestModel staffModel
  ) {
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
    String operatorId = USER_INFO_REPO.getUser().Lan_Id__c;
    if (String.isNotEmpty(operatorId)) {
      headers.put('X-Operator-Id', operatorId);
    }
    if (staffModel == null) {
      //usual flow
      headers = setMuleSoftCommonHeaders(headers);
    } else {
      //new Ingress++ flow
      headers.putAll(setCalloutCommonHeaders(staffModel));
    }
    return headers;
  }

  /**
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
  private Map<String, String> setMuleSoftCommonHeaders(
    Map<String, String> headers
  ) {
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Authorization', 'Bearer ' + generateJWTToken());
    return headers;
  }
}
