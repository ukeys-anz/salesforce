/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description virtual service class for all API callouts
 */
public virtual class Service {

  protected HttpCalloutResponse response = new HttpCalloutResponse();

  /**
   * @param ocvId customer id
   * @return `HttpCalloutResponse` api response
   * @description virtual accounts and goals callout
   */
  public virtual HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    return null;
  }

  /**
   * @param response HttpCalloutResponse to test various error codes
   * @description setter method for response property
   */
  @TestVisible
  private void setCalloutResponse(HttpCalloutResponse response) {
    this.response = response;
  }

  /**
   * @param ocvID customer id
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a fabric callout
   */
  public Map<String, String> setFabricCommonHeaders(
    String ocvID,
    Map<String, String> headers
  ) {
    String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvID);
    headers.put('Authorization', 'Bearer ' + serializedToken);
    return setMuleCommonHeaders(headers);
  }

  /**
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
  @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
  public Map<String, String> setMuleCommonHeaders(Map<String, String> headers) {
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    return headers;
  }
}
