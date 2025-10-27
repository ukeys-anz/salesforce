/** @description This class provides functionality for performing MFA (Multi-Factor Authentication) reset operations
 * for brokers, including obtaining elevated tokens and executing the MFA reset process.
 */
public with sharing class MFAResetService extends Service {
  @testVisible
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @description Retrieves an elevated token for a specified broker using their email and a staff token.
   *
   * @param brokerEmail The email address of the broker for whom the elevated token is requested.
   * @param staffToken The token provided by staff for authorization in the request.
   * @return HttpCalloutResponse The response from the elevated token request, containing the token or error information.
   */
  public HttpCalloutResponse getElevatedToken(
    String brokerEmail,
    String staffToken
  ) {
    Lib_HttpCallout.RESTCalloutWrapper elevatedTokenRequest = buildElevatedTokenRequest(
      brokerEmail,
      staffToken
    );
    return CALLOUT.makeRestCallout(elevatedTokenRequest);
  }

  /**
   * @description Initiates the MFA reset process for a broker using the provided elevated token.
   *
   * @param elevatedToken The token obtained from the elevated token request, used for authorization in the MFA reset call.
   * @return HttpCalloutResponse The response from the MFA reset request, indicating success or failure.
   */
  public HttpCalloutResponse resetMFA(String elevatedToken) {
    Lib_HttpCallout.RESTCalloutWrapper mfaResetRequest = buildMFAResetRequest(
      elevatedToken
    );
    return CALLOUT.makeRestCallout(mfaResetRequest);
  }

  /**
   * @description Constructs the common headers required for API calls to the Mule application.
   *
   * @return Map<String, String> A map containing the common headers, including client ID and secret.
   */
  @testVisible
  private static Map<String, String> getCommonMuleHeaders() {
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.UserName}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('traceparent', CommonUtil.generateTraceParent());
    return headers;
  }

  /**
   * @description Builds the request body for obtaining an elevated token needed for performing the MFA reset for a broker.
   *
   * @param brokerEmail The email address of the broker for whom MFA has to be reset.
   * @param staffToken The token of current staff user, for authorization of the request.
   * @return `RESTCalloutWrapper` the request body for the elevated token request.
   */
  @testVisible
  private static Lib_HttpCallout.RESTCalloutWrapper buildElevatedTokenRequest(
    String brokerEmail,
    String staffToken
  ) {
    Map<String, String> headers = getCommonMuleHeaders();
    headers.put('Content-Type', 'application/x-www-form-urlencoded');
    Lib_HttpCallout.RESTCalloutWrapper req = new Lib_HttpCallout.RESTCalloutWrapper();
    req.endpoint = Label.Mulesoft_Get_Forge_Elevated_Token;
    req.headers = headers;
    req.method = HTTP_METHOD.HTTP_POST;
    req.timeout = 120000;
    req.requestBody = String.format(
      'client_id={0}&grant_type={1}&scope={2}&id_type=email' +
      '&id_value={3}&subject_token_type={4}&subject_token={5}',
      new List<Object>{
        Label.Forge_MFA_Reset_Client_Id,
        'urn:ietf:params:oauth:grant-type:token-exchange',
        'AU_ANZx_Broker_Accreditation_and_Onboarding_Team' /* AD Group authorized to reset MFA */,
        brokerEmail,
        'urn:ietf:params:oauth:token-type:jwt',
        staffToken
      }
    );
    return req;
  }

  /**
   * @description Builds the request body for resetting login MFA of a broker.
   *
   * @param elevatedToken The elevated token with scopes needed to perform the MFA reset for a broker.
   * @return `RESTCalloutWrapper` the request body for resetting MFA of a broker.
   */
  @testVisible
  private static Lib_HttpCallout.RESTCalloutWrapper buildMFAResetRequest(
    String elevatedToken
  ) {
    Map<String, String> headers = getCommonMuleHeaders();
    headers.put('Authorization', 'Bearer ' + elevatedToken);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout.RESTCalloutWrapper req = new Lib_HttpCallout.RESTCalloutWrapper();
    req.endpoint = Label.Mulesoft_Reset_Forge_MFA;
    req.headers = headers;
    req.method = HTTP_METHOD.HTTP_POST;
    req.timeout = 120000;
    req.requestBody = '{"types":["TYPE_OATH_TOTP"],"reason":"Support ticket #12345 - Broker locked out"}';
    return req;
  }
}
