/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description virtual service class for all API callouts
 * @group Services
 */
public with sharing virtual class Service {
  protected HttpCalloutResponse response = new HttpCalloutResponse();
  protected Boolean preset = false;

  /**
   * @param ocvId customer id
   * @param endPoint endPoint
   * @return `HttpCalloutResponse` api response
   * @description virtual chat channels callout
   */
  public virtual HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @return `HttpCalloutResponse` api response
   * @description virtual accounts and goals callout
   */
  public virtual HttpCalloutResponse getAccountsAndGoals(String ocvId) {
    return null;
  }

  /**
   * @param redirectURL redirect url in the http request
   * @param code code in the http request
   * @return `HttpCalloutResponse` api response
   * @description virtual azure identity callout
   */
  public virtual HttpCalloutResponse getIdentityTokens(
    String redirectURL,
    String code
  ) {
    return null;
  }

  /**
   * @param existingRefreshToken existing refresh token id
   * @return `HttpCalloutResponse` api response
   * @description virtual azure refresh id token callout
   */
  public virtual HttpCalloutResponse getRefreshIdToken(
    String existingRefreshToken
  ) {
    return null;
  }

  /**
   * @param ocvId ocv id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches forge api callout
   */
  public virtual HttpCalloutResponse getForgeJWTToken(
    String ocvId,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param accountNumber Account number for which we want to fetch the transactions
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `HttpCalloutResponse` api response
   * @description virtual transaction history callout
   */
  public virtual HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @return `HttpCalloutResponse` api response
   * @description virtual card list callout
   */
  public virtual HttpCalloutResponse getCardList(String ocvId) {
    return null;
  }

  /**
   * @param cardNumber card number to get blocked
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description virtual temporarily lock cards api
   */
  public virtual HttpCalloutResponse lockCard(String cardNumber, String ocvId) {
    return null;
  }

  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `HttpCalloutResponse` the api response
   * @description replace cards api
   */
  public virtual HttpCalloutResponse replaceCard(
    String cardNumber,
    String ocvId,
    String reason
  ) {
    return null;
  }

  /**
   * @param fraudLockInformation `Map<String,String>` which contains:
   * - cardNumber card number to send to api
   * - ocvId customer id
   * - status chosen by fraud agent
   * - reason for fraud action. If chosen to cancel the card, this will be "Fraud"
   * @return `HttpCalloutResponse` the api response
   * @description fraud lock/unlock/cancel cards api
   */
  public virtual HttpCalloutResponse setFraudCardStatus(
    Map<String, String> fraudLockInformation
  ) {
    return null;
  }

  /**
   * @param response HttpCalloutResponse to test various error codes
   * @description setter method for response property
   */
  @TestVisible
  private void setCalloutResponse(HttpCalloutResponse response) {
    this.response = response;
    this.preset = true;
  }

  /**
   * @param ocvID customer id
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets Authorization required for a callout
   */
  public Map<String, String> setAuthorizationCommonHeaders(
    String ocvID,
    Map<String, String> headers
  ) {
    String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvID);
    headers.put('Authorization', 'Bearer ' + serializedToken);
    return headers;
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
    // version and trace flag is hardcoded in util methods as a temporary solve, this has scope to change in future
    headers.put(
      'x-correlation-id',
      UniqueIdUtil.getVersion() +
      '-' +
      UniqueIdUtil.getTraceId() +
      '-' +
      UniqueIdUtil.getParentId() +
      '-' +
      UniqueIdUtil.getTraceFlag()
    );
    return headers;
  }

  /**
   * @param ocvID customer id
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a callout
   */
  public Map<String, String> setCalloutCommonHeaders(
    String ocvID,
    Map<String, String> headers
  ) {
    headers = setAuthorizationCommonHeaders(ocvID, headers);
    headers = setMuleCommonHeaders(headers);
    return headers;
  }

  /**
   * @param resourceName the name of the static resource to fetch
   * @return `String` body of static resource
   * @description returns the body of the static resource as a string used for mock data
   */
  public static String getStaticResource(String resourceName) {
    StaticResource sr;
    if (StaticResource.sObjectType.getDescribe().isQueryable()) {
      sr = [SELECT body FROM StaticResource WHERE Name = :resourceName];
    }
    return sr.body.toString();
  }

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches customer info api callout
   */
  public virtual HttpCalloutResponse getCustomerInformation(
    String customerId,
    String customerIdentifier
  ) {
    return null;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber used to fetch the statements from Mulesoft related to the Account Number
   * @param pageSize number of statement records to be returned from Fabric
   * @return `HttpCalloutResponse` api response
   * @description virtual statement callout
   */
  public virtual HttpCalloutResponse getStatements(
    String ocvId,
    String accountNumber,
    String pageSize
  ) {
    return null;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param statementId  used to fetch the statements from Mulesoft related to the Account Number
   * @return `HttpCalloutResponse` api response
   * @description virtual statement callout
   */
  public virtual HttpCalloutResponse getStatementUrl(
    String ocvId,
    String statementId
  ) {
    return null;
  }
}
