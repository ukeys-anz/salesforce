/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description virtual service class for all API callouts
 * @group Services
 * Suppressing ExcessivePublicCount rule to allow for added callouts
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing virtual class Service {
  protected HttpCalloutResponse response = new HttpCalloutResponse();
  protected Boolean preset = false;
  public enum IdType {
    OCVID,
    PERSONAID
  }

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
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return `HttpCalloutResponse` api response
   * @description virtual financial accounts callout
   */
  public virtual HttpCalloutResponse getFinancialAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    return null;
  }

  /**
   * @param ocvId contains customer id
   * @return `HttpCalloutResponse` api response
   * @description virtual home loan accounts callout
   */
  public virtual HttpCalloutResponse getHomeLoanAccounts(String ocvId) {
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
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches forge api callout
   */
  public virtual HttpCalloutResponse getForgeJWTToken(
    Service.IdType idType,
    String idValue,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `HttpCalloutResponse` api response
   * @description virtual transaction history callout
   */
  public virtual HttpCalloutResponse getTransactionHistory(
    String ocvId,
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
   * @param cardNumber card number to be locked
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description virtual card controls api to temp lock card
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
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets Authorization required for a callout
   */
  public Map<String, String> setAuthorizationCommonHeaders(
    IdType idType,
    String idValue,
    Map<String, String> headers
  ) {
    String serializedToken = AuthTokenCacheUtil.getStaffToken(idType, idValue);
    headers.put('Authorization', 'Bearer ' + serializedToken);
    return headers;
  }

  /**
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
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
      UniqueIdUtil.generateSpanId() +
      '-' +
      UniqueIdUtil.getTraceFlag()
    );
    return headers;
  }

  /**
   * @param idType Enum for specifying which type of id is used: OCV ID or PERSONA ID
   * @param idValue ocv id or persona Id
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a callout
   */
  public Map<String, String> setCalloutCommonHeaders(
    IdType idType,
    String idValue,
    Map<String, String> headers
  ) {
    headers = setAuthorizationCommonHeaders(idType, idValue, headers);
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
   * @param resourceName the name of the static resource to fetch
   * @return `Blob` blob body of static resource
   * @description returns the body of the static resource as a blob used for mock data
   */
  public static Blob getStaticResourceAsBlob(String resourceName) {
    StaticResource sr;
    if (StaticResource.sObjectType.getDescribe().isQueryable()) {
      sr = [SELECT Body FROM StaticResource WHERE Name = :resourceName];
    }
    return sr.body;
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

  /**
   * @param ocvId customer id
   * @param paramUrl params to be sent to api
   * @return `HttpCalloutResponse` api response
   * @description virtual account buckets callout
   */
  public virtual HttpCalloutResponse getAccountBuckets(
    String ocvId,
    String paramUrl
  ) {
    return null;
  }

  /**

   * @param calloutUrl ABN or ACN callout url
   * @param abnOrAcn number to be validated
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches ABN info api callout
   */
  public virtual HttpCalloutResponse getAbnAcnInformation(
    String calloutUrl,
    String abnOrAcn
  ) {
    return null;
  }

  /**
   * @param lookupString from address search bar
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches addresses list
   */
  public virtual HttpCalloutResponse getAddresses(String lookupString) {
    return null;
  }

  /**
   * @param encodedAddressId from selected address
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches address details
   */
  public virtual HttpCalloutResponse getSelectedAddress(
    String encodedAddressId
  ) {
    return null;
  }

  /**
   * @param lookupString from address search bar
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches addresses list
   */
  public virtual HttpCalloutResponse getAddressesV2(String lookupString) {
    return null;
  }

  /**
   * @param globalAddressKey from selected address
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches address details
   */
  public virtual HttpCalloutResponse getSelectedAddressV2(
    String globalAddressKey
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @return `HttpCalloutResponse` api response
   * @description virtual card control list callout
   */
  public virtual HttpCalloutResponse getCardControlsList(String ocvId) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param transactionId transaction id
   * @return `HttpCalloutResponse` api response
   * @description virtual disputes search tokenized card number callout
   */
  public virtual HttpCalloutResponse getTokenizedCardNumber(
    String ocvId,
    String transactionId
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param packageId package id
   * @param checkingAccount the account number for the checking account
   * @param savingsAccount the account number for the savings account
   * @return `PackageClosureParams` api response
   * @description virtual account buckets callout
   */
  public virtual HttpCalloutResponse closePackage(
    String ocvId,
    String packageId,
    String checkingAccount,
    String savingsAccount
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param messageContent the content of the message to be sent
   * @param customerName the first name of the customer
   * @param issueType the issue type (default to Follow Up)
   * @param issueSubType the issue sub type (default to ANZ Plus Support)
   * @return `HttpCalloutResponse` the api response
   * @description sends the initial chat message
   */
  public virtual HttpCalloutResponse initiateChat(
    String ocvId,
    String messageContent,
    String customerName,
    String issueType,
    String issueSubType
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param conversationSid the chat id to reinitiate
   * @return `HttpCalloutResponse` the api response
   * @description sends the initial chat message
   */
  public virtual HttpCalloutResponse reinitiateChat(
    String ocvId,
    String conversationSid
  ) {
    return null;
  }

  /**
   * @param record lead record
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches party information
   */
  public virtual HttpCalloutResponse searchPartyInfo(Lead record) {
    return null;
  }

  /**
   * @param record lead record
   * @return `HttpCalloutResponse` api response
   * @description virtual fetches party information
   */
  public virtual HttpCalloutResponse createParty(Lead record) {
    return null;
  }

  /**
   * @param cobCase COB Case holding Id, personaId and status to be used for callout
   * @return `HttpCalloutResponse` api response
   * @description virtual triggers Temporal Case Workflow
   */
  public virtual HttpCalloutResponse triggerTemporalCaseWorkflow(Case cobCase) {
    return null;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param tokenizedFields the account number for the checking account
   * @return `HttpCalloutResponse` api response
   * @description virtual stravinsky cobPid detokenize api
   */
  public virtual HttpCalloutResponse detokenizeCOBPID(
    String personaId,
    List<COBPrimaryIDDocumentModel.TokenizedValue> tokenizedFields
  ) {
    return null;
  }

  /**
   * @param personaId COB Primary ID record Persona Id
   * @param detokenizedValue detokenized COBPID ready for tokenization
   * @return `HttpCalloutResponse` api response
   * @description virtual stravinsky cobPid detokenize api
   */
  public virtual HttpCalloutResponse tokenizeCOBPID(
    String personaId,
    COBPrimaryIDDocumentModel detokenizedValue
  ) {
    return null;
  }

  /**
   * @param ocvId customer id
   * @param docId document id reference in external system
   * @return HttpCalloutResponse api response
   * @description virtual gets CFaaS download url
   */
  public virtual HttpCalloutResponse getDownloadUrl(
    String ocvId,
    String docId
  ) {
    return null;
  }

  /**
   * @param url google bucket url pointing to document store
   * @param otp one time pin to be set in header in order to access above url
   * @param contentType represents document content type which is set in header
   * @return HttpCalloutResponse api response
   * @description virtual fetches CFaaS document content
   */
  public virtual HttpCalloutResponse fetchDocumentContent(
    String url,
    String otp,
    String contentType
  ) {
    return null;
  }
}
