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
    String urlParam =
      'filter.view_type=ACCOUNT_VIEW_TYPE_ALL_DIGITAL_ACTIVE&page_size=' +
      Label.ListAccountsAPIPageSize +
      '&';
    for (String accountNumber : accountNumbers) {
      String accountFilter = 'accounts/' + accountNumber;
      urlParam +=
        'filter.accounts=' +
        EncodingUtil.urlEncode(accountFilter, 'UTF-8') +
        '&';
    }
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_Financial_AccountsV1 + '?' + urlParam,
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
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_TransactionsV1 + paramUrl,
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
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_Cards,
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
      Label.MS_Temp_Lock_Card + cardNumber + '/set',
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
      Label.MS_Replace_Card + cardNumber + '/replace',
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"reason":"REASON_' + reason.toUpperCase() + '"}'
    );
    return response;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param accountNumber Account number for which we want to fetch the statements
   * @param pageSize number of document records to be returned from Fabric
   * @param contextType which indicates whether the documents is statements or notices
   * @return `HttpCalloutResponse` the api response
   * @description fetches statements from the fabric API
   */
  public override HttpCalloutResponse getStatements(
    String ocvId,
    String accountNumber,
    String pageSize,
    String contextType
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    StaffTokenRequestModel staffModel = getStaffModel(
      'DocumentsApiScopes',
      ocvId
    );
    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-Type', 'application/json');
    List<String> queryParams = new List<String>();
    queryParams.add('page_size=' + pageSize);
    queryParams.add(
      'accounts_filter.accounts=' +
      EncodingUtil.urlEncode('accounts/' + accountNumber, 'UTF-8')
    );

    Map<String, FinancialAccountDocumentTypes__mdt> documentTypes = FinancialAccountDocumentTypes__mdt.getall();

    for (
      FinancialAccountDocumentTypes__mdt documentType : documentTypes.values()
    ) {
      if (documentType.Type__c == contextType) {
        queryParams.add(
          'structured_filter.doctypes=' +
          EncodingUtil.urlEncode(documentType.Document_Type__c, 'UTF-8')
        );
      }
    }
    // Make the callout
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_StatementList + '?' + String.join(queryParams, '&'),
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }
  /**
   * @param ocvId required to make the callout to Mulesoft
   * @param documentId for which we want to fetch the document url
   * @return `HttpCalloutResponse` the api response
   * @description fetches document URL from the fabric API against the document url mentioned
   */
  public override HttpCalloutResponse getStatementUrl(
    String ocvId,
    String documentId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    StaffTokenRequestModel staffModel = getStaffModel(
      'GenerateSignedDocumentURLScopes',
      ocvId
    );
    Map<String, String> headers = setCalloutCommonHeaders(staffModel);
    headers.put('cache-control', 'no-store');
    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Get_StatementUrl + documentId,
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
      Label.MS_Get_Account_Buckets + paramUrl,
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
      Label.MS_Get_Card_Control_List,
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
      Label.MS_Get_Tokenized_Card + transactionId + '/tokenized-card',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param financialAccountNumber financial account number on which update is required
   * @param signMode sing mode that need to be updated
   * @param ocvId required to make the callout to Mulesoft
   * @return `HttpCalloutResponse` the api response
   * @description updates the number of signature on financial account
   */
  public override HttpCalloutResponse updateSigningAutority(
    String financialAccountNumber,
    Integer signMode,
    String ocvId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);

    HttpCalloutResponse response = calloutService.makeRestCallout(
      Label.MS_Upadte_Signing_Authority.replace(
        '{accountId}',
        financialAccountNumber
      ),
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"account": "' +
        financialAccountNumber +
        '"' +
        ',' +
        '"sign_mode": ' +
        signMode +
        '}'
    );

    return response;
  }

  /**
   * @description getStaffModel method
   * @param scopes requested
   * @param ocvId customer id
   * @return StaffTokenRequestModel
   */
  public StaffTokenRequestModel getStaffModel(String scopes, String ocvId) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.apiScopesRequested = scopes;
    staffModel.anzTokenType = 'staffRqfCustomer';
    staffModel.realm = 'customer';
    staffModel.idType = Service.IdType.OCVID;
    staffModel.idValue = ocvId;
    staffModel.isSecureWafFlow = true;
    return staffModel;
  }
}
