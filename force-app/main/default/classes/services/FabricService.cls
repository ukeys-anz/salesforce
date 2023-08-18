/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description fabric implementation of the API service
 * @group Services
 */
public with sharing class FabricService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return `HttpCalloutResponse` the api response
   * @description fetches accounts and goals from the fabric API
   */
  public override HttpCalloutResponse getFinancialAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    String financialAccountApiVersion;
    String urlParam = '';
    String urlParamV1 = '';
    String urlParamV1beta1 = '';
    if (!accountNumbers.isEmpty()) {
      for (String accountNumber : accountNumbers) {
        urlParamV1 += 'filter.accounts=accounts/' + accountNumber + '&';
        urlParamV1beta1 += 'account_numbers=' + accountNumber + '&';
      }
    }

    if (Label.AccountAPIUpliftedToV1 == 'True') {
      urlParam = urlParamV1;
      financialAccountApiVersion = Label.MS_Get_Financial_AccountsV1;
    } else {
      urlParam = urlParamV1beta1;
      financialAccountApiVersion = Label.MS_Get_Financial_Accounts;
    }

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      financialAccountApiVersion +
      '?' +
      urlParam,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id
   * @param paramUrl Used to fetch the next lot of transactions or search by date
   * @return `HttpCalloutResponse` the api response
   * @description fetches transaction history from the fabric API
   */
  public override HttpCalloutResponse getTransactionHistory(
    String ocvId,
    String paramUrl
  ) {
    String transactionApiVersion;
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();

    if (Label.TransactionAPIUpliftedToV1 == 'True') {
      transactionApiVersion = Label.MS_Get_TransactionsV1;
    } else {
      transactionApiVersion = Label.MS_Get_Transactions;
    }

    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      transactionApiVersion +
      paramUrl,
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
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Cards,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param cardNumber card number to be locked
   * @param ocvId customer id
   * @return `HttpCalloutResponse` the api response
   * @description calls card controls api to place a temp card lock
   */
  public override HttpCalloutResponse lockCard(
    String cardNumber,
    String ocvId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Temp_Lock_Card +
      cardNumber +
      '/set',
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"card_controls" : [{ "control_type": "GCT_GLOBAL"}]}'
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
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
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
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
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
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
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
   * @param paramUrl url parameters to be sent
   * @return `HttpCalloutResponse` the api response
   * @description fetches account buckets from fabric api
   */
  public override HttpCalloutResponse getAccountBuckets(
    String ocvId,
    String paramUrl
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_Account_Buckets +
      paramUrl,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id to get card controls list for
   * @return `HttpCalloutResponse` the api response
   * @description retrieves the list of card controls
   */
  public override HttpCalloutResponse getCardControlsList(String ocvId) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Get_Card_Control_List,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param transactionId transaction id to get related tokenized card number for
   * @return `HttpCalloutResponse` the api response
   * @description retrieves the tokenized card number relating to the transaction
   */
  public override HttpCalloutResponse getTokenizedCardNumber(
    String ocvId,
    String transactionId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_Tokenized_Card +
      transactionId +
      '/tokenized-card',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
}
