/**
 * @author Lance Shi
 * @since March 2021
 * @description Azure implementation of the API service
 */
public with sharing class AzureService extends Service {
  /**
   * @param redirectURL redirect url in the http request
   * @param code code in the http request
   * @return `HttpCalloutResponse` api response
   * @description fetches from azure api
   */
  public override HttpCalloutResponse getIdentityTokens(
    String redirectURL,
    String code
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/x-www-form-urlencoded');
    String reqBody =
      'client_id={!$Credential.UserName}&client_secret={!$Credential.Password}&redirect_uri=' +
      redirectURL +
      '&grant_type=authorization_code' +
      '&code=' +
      code;
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:TokenUrl',
      HTTP_METHOD.HTTP_POST,
      headers,
      reqBody
    );
    return response;
  }

  /**
   * @param existingRefreshToken existing refresh token id
   * @return `HttpCalloutResponse` api response
   * @description fetches response from azure api
   */
  public override HttpCalloutResponse getRefreshIdToken(
    String existingRefreshToken
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('Content-Type', 'application/x-www-form-urlencoded');
    String reqBody =
      'client_id={!$Credential.UserName}&client_secret={!$Credential.Password}&refresh_token=' +
      existingRefreshToken +
      '&grant_type=refresh_token';
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:TokenUrl',
      HTTP_METHOD.HTTP_POST,
      headers,
      reqBody
    );
    return response;
  }
}
