/**
 * @author : Naman Garg
 * @description : This class is used to display the Financial Summaries.
 * @since : Aug 2023
 */

public class CCRMFinancialSummaryController {
  private final static String ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME = 'BankingAccount';
  private static Map<String, String> roleTypes = new Map<String, String>{
    'BCC' => 'Business Card Customer',
    'CLG' => 'Customer Lending Group',
    'COF' => 'Co-Owner First',
    'COO' => 'Co-Owner Other',
    'DBN' => 'Direct Beneficiary',
    'GTR' => 'Guarantor',
    'PCC' => 'Personal Card Customer',
    'PRI' => 'Primary Owner',
    'SOL' => 'Sole Owner',
    'TSF' => 'Trustee First',
    'TSO' => 'Trustee Other',
    'UNO' => 'Unnamed Owner'
  };

  private static Set<String> productTypes = new Set<String>{
    'CAP-CIS:DDA',
    'CAP-CIS:FM',
    'CAP-CIS:SSI',
    'CAP-CIS:RSV',
    'CAP-CIS:ILS',
    'CAP-CIS:PCA',
    'CAP-CIS:CDA'
  };

  @TestVisible
  private static final String BASE_CALLOUT_URL = Label.Financial_Account_Endpoint;
  @TestVisible
  private static final String TOTAL_CUSTOMER_BALANCE_FIELDSET = 'TOTAL_CUSTOMER_BALANCE';
  @TestVisible
  private static final String TERMINALS_FIELDSET = 'TERMINALS';
  @TestVisible
  private static final String TOTAL_ASSET_FINANCE_BALANCE_FIELDSET = 'TOTAL_ASSET_FINANCE_BALANCE';
  @TestVisible
  private static final String TOTAL_ASSET_FINANCE_BALANCE_TYPE = 'BOTH';
  @TestVisible
  private static final String MULE_RESPONSE = 'Request Received';
  @TestVisible
  private static final String CACHE_ACK = 'Data found in cache';

  /**
   * @description - This method is used to fetch the summaries values from the cache and if no values present then it will
   * 			   make a callout to mule to get the Financial Summaries result
   * @param finSumCallout - CCRMFinancialSummaryWrapper.FinSummaryCallout contains the responseId and the the Api which need to be call
   * @return CCRMFinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static CCRMFinancialSummaryResponseWrapper getSummariesByResponseId(
    CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    //It will check if the responseId i.e Customer Id is exists in the cache or not
    //If yes, then it will fetch the data of the Financial summaries from the cache
    //Else it will make a callout to retrieve the respective financial Summaries data.
    if (sessionPart.contains(finSumCallout.responseId)) {
      return getDataFromCache(sessionPart, finSumCallout);
    }
    return getDataFromCallout(finSumCallout);
  }

  /**
   * @description - This method is used to fetch the data from the cache
   * @param sessionPart - Cache SessionPartition to get the Cache partition
   * @param finSumCallout - Instance of Financial Summary Callout containing response Id and the the Api which need to be call
   * @return CCRMFinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @TestVisible
  private static CCRMFinancialSummaryResponseWrapper getDataFromCache(
    Cache.SessionPartition sessionPart,
    CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    CCRMFinancialSummaryResponseWrapper finSumRespFromCache = new CCRMFinancialSummaryResponseWrapper();

    String cachedJson = (String) sessionPart.get(finSumCallout.responseId);
    finSumRespFromCache = (CCRMFinancialSummaryResponseWrapper) JSON.deserialize(
      cachedJson,
      CCRMFinancialSummaryResponseWrapper.class
    );
    finSumRespFromCache.responseId = finSumCallout.responseId;
    finSumRespFromCache.cacheAck = CACHE_ACK;
    return finSumRespFromCache;
  }

  /**
   * @description - This method is used to fetch the data by making a callout
   * @param finSumCallout - Instance of Financial Summary Callout containing response Id and the the Api which need to be call
   * @return CCRMFinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static CCRMFinancialSummaryResponseWrapper getDataFromCallout(
    CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    List<String> accountNumberList = new List<String>();
    CCRMFinancialSummaryResponseWrapper finSumRespFromCallout = new CCRMFinancialSummaryResponseWrapper();
    CCRMFinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new CCRMFinancialSummaryWrapper.CustomerIdWrapper();

    finSumRespFromCallout.responseId = finSumCallout.responseId;
    custIdWrapper = getCLGRelatedCustomerIds(finSumRespFromCallout.responseId);
    accountNumberList = retrieveFinancialAccountsByCustomerId(
      custIdWrapper.capIdsList
    );

    //Making a callout to get the Total Balance
    //and if accountNumberList is Empty then it will return 'No Available Balance' as an acknowledgement
    finSumRespFromCallout.totalBalanceAck = getTotalBalance(
      finSumRespFromCallout.responseId,
      accountNumberList,
      TOTAL_CUSTOMER_BALANCE_FIELDSET,
      finSumCallout.callTotalCustBalanceApi
    );

    //Making a callout to get the Total Merchant Terminal
    //and if capCustomerIdList is Empty then it will return 'No Available Balance' as an acknowledgement
    finSumRespFromCallout.terminalAck = getTotalMerchantTerminals(
      finSumRespFromCallout.responseId,
      custIdWrapper.capIdsModifiedList,
      TERMINALS_FIELDSET,
      finSumCallout.callTerminalApi
    );

    //Making a callout to get the Total Asset Finance Balance
    //and if capCustomerIdList is Empty then it will return 'No Available Balance' as an acknowledgement
    finSumRespFromCallout.assetBalanceAck = getTotalAssetFinanceBalance(
      finSumRespFromCallout.responseId,
      custIdWrapper.capIdsModifiedList,
      TOTAL_ASSET_FINANCE_BALANCE_TYPE,
      TOTAL_ASSET_FINANCE_BALANCE_FIELDSET,
      finSumCallout.callAssetFinanceBalanceApi
    );

    populateDataInCache(finSumRespFromCallout);

    return finSumRespFromCallout;
  }

  /**
   * @description - Get legal entity customer Ids related to CLG
   * @param customerId - CLG customer Id
   * @return List<String> List of External Ids
   */
  @TestVisible
  private static CCRMFinancialSummaryWrapper.CustomerIdWrapper getCLGRelatedCustomerIds(
    String customerId
  ) {
    CCRMFinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new CCRMFinancialSummaryWrapper.CustomerIdWrapper();
    String capId = '';
    Set<String> capIdSet = new Set<String>();
    List<String> capIdsModifiedList = new List<String>();

    Account accountRec = [
      SELECT Id, External_Id__c, RecordType.DeveloperName
      FROM Account
      WHERE Id = :customerId
      LIMIT 1
    ];
    if (
      accountRec.RecordType.DeveloperName != 'CLG' &&
      accountRec.External_Id__c != null
    ) {
      custIdWrapper.capIdsList.add(accountRec.External_Id__c);
      capId = splitExternalId(accountRec.External_Id__c, '_');
      capIdSet.add(capId);
      capIdSet.removeAll(new Set<String>{ null });
      custIdWrapper.capIdsModifiedList.addAll(capIdSet);
      return custIdWrapper;
    }
    try {
      for (FinServ__AccountAccountRelation__c aar : [
        SELECT Id, FinServ__RelatedAccount__r.External_Id__c
        FROM FinServ__AccountAccountRelation__c
        WHERE
          FinServ__Account__c = :customerId
          AND FinServ__Active__c = TRUE
          AND FinServ__Account__r.RecordType.DeveloperName = 'CLG'
          AND FinServ__RelatedAccount__r.External_Id__c != NULL
        WITH SECURITY_ENFORCED
      ]) {
        if (
          !custIdWrapper.capIdsList.contains(
            aar.FinServ__RelatedAccount__r.External_Id__c
          )
        ) {
          custIdWrapper.capIdsList.add(
            aar.FinServ__RelatedAccount__r.External_Id__c
          );
          capId = splitExternalId(
            aar.FinServ__RelatedAccount__r.External_Id__c,
            '_'
          );
          capIdSet.add(capId);
        }
      }
      capIdSet.removeAll(new Set<String>{ null });
      custIdWrapper.capIdsModifiedList.addAll(capIdSet);
      return custIdWrapper;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Retrieves list of financial accounts related to a customer via financial account role relationship (FAR)
   * @param customerIds the FAR related customer external Id
   * @return List<String> list of account Number
   */
  @TestVisible
  private static List<String> retrieveFinancialAccountsByCustomerId(
    List<String> customerIds
  ) {
    List<String> accountNumberList = new List<String>();
    String prodType = '';

    if (customerIds.IsEmpty()) {
      return accountNumberList;
    }

    if (
      !(PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') &&
      PermissionUtils.canQuery('FinServ__FinancialAccount__c'))
    ) {
      return accountNumberList;
    }

    try {
      for (FinServ__FinancialAccountRole__c faRole : [
        SELECT
          FinServ__FinancialAccount__c,
          FinServ__FinancialAccount__r.Account_Key__c,
          FinServ__FinancialAccount__r.Name,
          FinServ__FinancialAccount__r.FinServ__Status__c,
          FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
          FinServ__FinancialAccount__r.Product_Type__c,
          FinServ__FinancialAccount__r.Product_SubCode__c,
          FinServ__RelatedAccount__r.External_Id__c,
          Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE
          FinServ__RelatedAccount__r.External_Id__c IN :customerIds
          AND FinServ__FinancialAccount__r.RecordType.DeveloperName = :ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME
          AND FinServ__Active__c = TRUE
          AND FinServ__FinancialAccount__r.Product_Type__c IN :productTypes
          AND Role_Type__c IN :roleTypes.keyset()
        WITH SECURITY_ENFORCED
        ORDER BY FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      ]) {
        prodType = splitExternalId(
          faRole.FinServ__FinancialAccount__r.Product_Type__c,
          ':'
        );
        if (prodType != null) {
          accountNumberList.add(
            faRole.FinServ__FinancialAccount__r.Product_Type__c.split(':')[1] +
              '-' +
              faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
          );
        }
      }
      return accountNumberList;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method is used to split the External Id
   * @name splitExternalId
   * @param externalId External Id of Account
   * @param operator operator symbol
   * @return String - externalId after split
   */
  public static String splitExternalId(String externalId, String operator) {
    if (!externalId.contains(operator)) {
      return null;
    }
    List<String> externalIdSplit = new List<String>(externalId.split(operator));
    return externalIdSplit.size() > 1 ? externalIdSplit[1] : null;
  }

  /**
   * @description : This method is used to make a callout to get the Total Balance
   * @param responseId - Id of the record
   * @param accountNumbers - List of accountNumbers
   * @param fieldSet - Constant keyword to unique Identify the callout
   * @param callTotalCustBalanceApi - true if we need to call this API
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalBalance(
    String responseId,
    List<String> accountNumbers,
    String fieldSet,
    Boolean callTotalCustBalanceApi
  ) {
    if (accountNumbers.isEmpty()) {
      return CCRMConstants.NO_AVAILABLE_BALANCE;
    }

    if (!callTotalCustBalanceApi) {
      return null;
    }

    Map<String, String> headers = generateHeader();
    String endPoint = BASE_CALLOUT_URL + 'summaries';

    CCRMFinancialSummaryWrapper.TotalBalance totalBalanceWrapper = new CCRMFinancialSummaryWrapper.TotalBalance(
      accountNumbers,
      fieldSet,
      responseId
    );

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(totalBalanceWrapper)
    );
  }

  /**
   * @description This method is used to make a callout to get the Total Merchant Terminals
   * @param responseId - Id of the record
   * @param capCustomerIds - List of capCustomerIds
   * @param fieldSet - Constant keyword to unique Identify the callout
   * @param callTerminalApi - true if we need to call this API
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalMerchantTerminals(
    String responseId,
    List<String> capCustomerIds,
    String fieldSet,
    Boolean callTerminalApi
  ) {
    if (capCustomerIds.isEmpty()) {
      return CCRMConstants.NO_AVAILABLE_BALANCE;
    }
    if (!callTerminalApi) {
      return null;
    }
    Map<String, String> headers = generateHeader();
    String endPoint = BASE_CALLOUT_URL + 'merchant-facility-accounts';

    CCRMFinancialSummaryWrapper.TerminalAndTotalAsset terminalWrapper = new CCRMFinancialSummaryWrapper.TerminalAndTotalAsset(
      capCustomerIds,
      fieldSet,
      responseId
    );

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(terminalWrapper)
    );
  }

  /**
   * @description This method is used to make a callout to get the Total Asset Finance Balance
   * @param responseId - Id of the record
   * @param capCustomerIds - List of capCustomerIds
   * @param type - type
   * @param fieldSet - Constant keyword to unique Identify the callout
   * @param callTotalCustBalanceApi - true if we need to call this API
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalAssetFinanceBalance(
    String responseId,
    List<String> capCustomerIds,
    String type,
    String fieldSet,
    Boolean callTotalCustBalanceApi
  ) {
    if (capCustomerIds.isEmpty()) {
      return CCRMConstants.NO_AVAILABLE_BALANCE;
    }
    if (!callTotalCustBalanceApi) {
      return null;
    }

    Map<String, String> headers = generateHeader();
    String endPoint = BASE_CALLOUT_URL + 'asset-finance-accounts';

    CCRMFinancialSummaryWrapper.TerminalAndTotalAsset assetFinanceWrapper = new CCRMFinancialSummaryWrapper.TerminalAndTotalAsset(
      capCustomerIds,
      type,
      fieldSet,
      responseId
    );

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(assetFinanceWrapper)
    );
  }

  /**
   * @description This method is used to generate Header
   * @return Map<String, String> return the header in form of key-value pair
   */
  @TestVisible
  private static Map<String, String> generateHeader() {
    Map<String, String> headers = new Map<String, String>();
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
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put(
      'Authorization',
      'Bearer ' + CCRMARNCService.generateJWTToken()
    );
    return headers;
  }

  /**
   * @description : This method is used to make a callout to get the Financial Summaries
   * @param endPoint - endpoint to which we have to make a callout
   * @param method - Http Method name
   * @param headers - header
   * @param requestObj - body of the request
   * @return String - callout response
   */
  @TestVisible
  private static String makeApiCallout(
    String endPoint,
    HTTP_METHOD method,
    Map<String, String> headers,
    String requestObj
  ) {
    try {
      HttpCalloutResponse httpResponse;
      Lib_HttpCallout calloutService = new Lib_HttpCallout();
      httpResponse = calloutService.makeRestCallout(
        endPoint,
        method,
        headers,
        requestObj
      );
      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(httpResponse)
      );
      Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(
        (String) responseMap.get('body')
      );
      return (String) responseBody.get('status');
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method is used to insert the data in the cache after the callout.
   * @param finSumResponse - containing the response of the callout
   */
  @TestVisible
  private static void populateDataInCache(
    CCRMFinancialSummaryResponseWrapper finSumResponse
  ) {
    CCRMFinancialSummaryWrapper.CacheData cacheWrapper = new CCRMFinancialSummaryWrapper.CacheData();
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    if (finSumResponse.totalBalanceAck != null) {
      cacheWrapper.totalBalanceAck = finSumResponse.totalBalanceAck;
    }
    if (finSumResponse.terminalAck != null) {
      cacheWrapper.terminalAck = finSumResponse.terminalAck;
    }
    if (finSumResponse.assetBalanceAck != null) {
      cacheWrapper.assetBalanceAck = finSumResponse.assetBalanceAck;
    }
    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(finSumResponse.responseId, JSON.serialize(cacheWrapper));
  }

  /**
   * @description This method is used to insert the data in the cache when platform event fire
   * @param response - Platform Event published by mule
   */
  @AuraEnabled
  public static void insertDataInCache(String response) {
    CCRMFinancialSummaryWrapper.CacheData cacheWrapper = new CCRMFinancialSummaryWrapper.CacheData();
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    String responseId = (String) resMap.get('Response_Id__c');
    String status = (String) resMap.get('Status__c');

    if (sessionPart.contains(responseId)) {
      String cachedData = (String) sessionPart.get(responseId);
      cacheWrapper = (CCRMFinancialSummaryWrapper.CacheData) JSON.deserialize(
        cachedData,
        CCRMFinancialSummaryWrapper.CacheData.class
      );
    }

    if (status == 'Error') {
      handleErrorResponse(cacheWrapper, responseId, sessionPart, resMap);
    }
    if (status == 'Success') {
      handleSuccessResponse(cacheWrapper, responseId, sessionPart, resMap);
    }
  }

  /**
   * @description This method is used to insert the data in the cache when platform event fire in case of Error
   * @param cacheWrapper - cache wrapper instance
   * @param responseId - record Id
   * @param sessionPart - session Part of the cache
   * @param resMap - platform event response
   */
  private static void handleErrorResponse(
    CCRMFinancialSummaryWrapper.CacheData cacheWrapper,
    String responseId,
    Cache.SessionPartition sessionPart,
    Map<String, Object> resMap
  ) {
    String summaryType = (String) resMap.get('Summary_Type__c');
    String errorDescription = (String) resMap.get('Error_Description__c');

    switch on summaryType {
      when 'TOTAL_CUSTOMER_BALANCE' {
        cacheWrapper.totalBalanceAck = CCRMConstants.ERROR_RESPONSE;
        Logger.error(errorDescription, responseId);
        Logger.saveLog();
      }
      when 'TERMINALS' {
        cacheWrapper.terminalAck = CCRMConstants.ERROR_RESPONSE;
        Logger.error(errorDescription, responseId);
        Logger.saveLog();
      }
      when else {
        cacheWrapper.assetBalanceAck = CCRMConstants.ERROR_RESPONSE;
        Logger.error(errorDescription, responseId);
        Logger.saveLog();
      }
    }
    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(responseId, JSON.serialize(cacheWrapper));
  }

  /**
   * @description This method is used to insert the data in the cache when platform event fire in case of Sucess
   * @param cacheWrapper - cache wrapper instance
   * @param responseId - record Id
   * @param sessionPart - session Part of the cache
   * @param resMap - platform event response
   */
  private static void handleSuccessResponse(
    CCRMFinancialSummaryWrapper.CacheData cacheWrapper,
    String responseId,
    Cache.SessionPartition sessionPart,
    Map<String, Object> resMap
  ) {
    String summaryType = (String) resMap.get('Summary_Type__c');

    switch on summaryType {
      when 'TOTAL_CUSTOMER_BALANCE' {
        cacheWrapper.totalBalance = (Decimal) resMap.get('Summary__c');
        cacheWrapper.totalBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
      }
      when 'TERMINALS' {
        cacheWrapper.totalMerchantTerminals = (Decimal) resMap.get(
          'Summary__c'
        );
        cacheWrapper.terminalAck = CCRMConstants.SUCCESS_RESPONSE;
      }
      when else {
        cacheWrapper.totalAssetFinanceBalance = (Decimal) resMap.get(
          'Summary__c'
        );
        cacheWrapper.assetBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
      }
    }
    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(responseId, JSON.serialize(cacheWrapper));
  }
}
