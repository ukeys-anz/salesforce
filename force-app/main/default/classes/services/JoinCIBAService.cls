/**
 * @author shawg2
 * @since January 2024
 * @description Construct JWT header & payload for CIBA request
 * @group Services
 * @runTests JoinCIBAServiceTest
 */

public with sharing virtual class JoinCIBAService extends Service {
  /**
   * @description Initiate callout to start the CIBA process.
   * @param ocvId OCV Id for Customer providing authorisation
   * @param jwtRequest jwt request payload to initiate the CIBA authentication request
   * @return HttpCalloutResponse from Callout
   */
  public virtual HttpCalloutResponse initiateAuthenticationRequest(
    String ocvId,
    String jwtRequest
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    StaffTokenRequestModel staffModel = getStaffRequestModelByOcvId(ocvId);
    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-type', 'application/x-www-form-urlEncoded');
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    String body = getAuthorisationRequest(ocvId, jwtRequest);
    return calloutService.makeRestCallout(
      System.Label.CIBA_AuthorisationRequestEndpoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @description Initiate callout to get auth request status.
   * @param authRequestId
   * @param ocvId
   * @return HttpCalloutResponse from Callout
   */
  public virtual HttpCalloutResponse authenticationPollingResponse(
    String authRequestId,
    String ocvId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    StaffTokenRequestModel staffModel = getStaffRequestModelByOcvId(ocvId);
    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-type', 'application/x-www-form-urlEncoded');
    headers.put('x-correlation-id', CommonUtil.generateUUID());
    String body = getAccessTokenRequest(authRequestId);
    return calloutService.makeRestCallout(
      System.Label.CIBA_AccessTokenRequestEndpoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @description builds JSON string with authRequestId and grantType
   * @param authRequestId authRequestId for Customer authentication
   * @return JSON string with authRequestId and grantType
   */

  public String getAccessTokenRequest(String authRequestId) {
    Map<String, String> requestMap = getForgeAuthInfo();
    requestMap.put('auth_req_id', authRequestId);
    requestMap.put('grant_type', System.Label.Grant_Type);
    return urlEncodeFromMap(requestMap);
  }

  /**
   * @description build JSON string with client_id, client_secret and request
   * @param ocvId OCV Id for Customer providing authorisation
   * @param jwtRequest jwt request payload to initiate the CIBA authentication request
   * @return JSON string with client_id, client_secret and request
   */
  @TestVisible
  private String getAuthorisationRequest(String ocvId, String jwtRequest) {
    Map<String, String> requestMap = getForgeAuthInfo();
    requestMap.put('request', jwtRequest);
    return urlEncodeFromMap(requestMap);
  }
  /**
   * @description To get the public key from Mulesoft
   * @param kid
   * @param ocvId OCV Id for Customer providing authorisation
   * @return response
   */
  public virtual HttpCalloutResponse getPublicKey(String kid, String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    StaffTokenRequestModel staffModel = getStaffRequestModelByOcvId(ocvId);
    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-type', 'application/json');
    String encodedKid = EncodingUtil.urlEncode(kid, 'UTF-8');
    return calloutService.makeRestCallout(
      System.Label.CIBA_getForgePublicKeyEndpoint + encodedKid,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
  }

  private StaffTokenRequestModel getStaffRequestModelByOcvId(String ocvId) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = ocvId;
    staffModel.anzTokenType = 'staffRqfCustomer';
    return staffModel;
  }
  private Map<String, String> getForgeAuthInfo() {
    Forgerock_Auth__mdt forgeAuth = Forgerock_Auth__mdt.getInstance('ForgeV2');
    Map<String, String> requestMap = new Map<String, String>();
    requestMap.put('client_id', forgeAuth.Encrypted_Forge_Client_Id__c);
    requestMap.put('client_secret', forgeAuth.Encrypted_Forge_Client_Secret__c);
    return requestMap;
  }

  private static String urlEncodeFromMap(Map<String, String> requestMap) {
    String result = '';
    for (String thisKey : requestMap.keySet()) {
      result +=
        EncodingUtil.urlEncode(thisKey, 'UTF-8') +
        '=' +
        EncodingUtil.urlEncode(requestMap.get(thisKey), 'UTF-8') +
        '&';
    }
    return result.removeEnd('&');
  }
}
