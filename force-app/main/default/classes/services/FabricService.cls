/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description fabric implementation of the API service
 * @group Services
 */
public with sharing class FabricService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @return `HttpCalloutResponse` the api response
   * @description fetches accounts and goals from the fabric API
   */
  public override HttpCalloutResponse getFinancialAccounts(String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Financial_Accounts,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId ocv id
   * @param idToken id token as the bearer token
   * @param forgeAuth custom metadata which contains the client id and secret
   * @return `HttpCalloutResponse` api response
   * @description fetches response from forge api
   */
  public override HttpCalloutResponse getForgeJWTToken(
    String ocvId,
    String idToken,
    Forgerock_Auth__mdt forgeAuth
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Authorization', 'Bearer ' + idToken);
    headers.put('Content-Type', 'application/x-www-form-urlencoded');

    String payload =
      'identity_system_client_id=' +
      EncodingUtil.urlEncode(forgeAuth.Encrypted_forge_client_id__c, 'UTF-8') +
      '&identity_system_client_secret=' +
      EncodingUtil.urlEncode(
        forgeAuth.Encrypted_forge_client_secret__c,
        'UTF-8'
      ) +
      '&ocvId=' +
      EncodingUtil.urlEncode(ocvId, 'UTF-8') +
      '&scope=aegis-introspect' +
      '&requested_token_type=StaffJWT' +
      '&personaType=retail';

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Forge_Token,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );
    return response;
  }

  /**
   * @param ocvId customer id
   * @param accountNumber Account number for which we want to fetch the transactions
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `HttpCalloutResponse` the api response
   * @description fetches transaction history from the fabric API
   */
  public override HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String accountNumber,
    String paramUrl
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);

    String endPointParams = String.isNotBlank(paramUrl)
      ? paramUrl
      : '?account_numbers=' + accountNumber;

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_Transactions +
      endPointParams,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description fetches card listfrom the fabric API
   */
  public override HttpCalloutResponse getCardList(String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Cards,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param cardNumber card number to get blocked
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description temporarily lock cards api
   */
  public override HttpCalloutResponse lockCard(
    String cardNumber,
    String ocvId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Temp_Block_Card +
      cardNumber +
      '/block',
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"action":"ACTION_BLOCK"}'
    );
    return response;
  }

  /**
   * @param cardNumber card number to get replaced
   * @param ocvId customer id
   * @param reason reason to replace the card
   * @return `HttpCalloutResponse` the api response
   * @description replace cards api
   */
  public override HttpCalloutResponse replaceCard(
    String cardNumber,
    String ocvId,
    String reason
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Replace_Card +
      cardNumber +
      '/replace',
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"reason":"REASON_' +
      reason.toUpperCase() +
      '"}'
    );
    return response;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @param pageSize number of statement records to be returned from Fabric
   * @return `HttpCalloutResponse` the api response
   * @description fetches statements from the fabric API
   */
  public override HttpCalloutResponse getStatements(
    String ocvId,
    String accountNumber,
    String pageSize
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_StatementList,
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"page_size":' +
      pageSize +
      ',' +
      '"account_numbers": ["' +
      accountNumber +
      '"]}'
    );
    return response;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param statementId for which we want to fetch the statement url
   * @return `HttpCalloutResponse` the api response
   * @description fetches statement URL from the fabric API against the statement url mentioned
   */
  public override HttpCalloutResponse getStatementUrl(
    String ocvId,
    String statementId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    headers.put('cache-control', 'no-store');
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_StatementUrl +
      statementId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id used to fetch account buckets
   * @return `HttpCalloutResponse` the api response
   * @description fetches account buckets from fabric api
   */
  public override HttpCalloutResponse getAccountBuckets(String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Account_Buckets,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
}
