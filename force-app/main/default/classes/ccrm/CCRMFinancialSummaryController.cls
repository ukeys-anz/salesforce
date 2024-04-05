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
   * @return CCRMFinancialSummaryWrapper.FinSummaryResponse - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static CCRMFinancialSummaryWrapper.FinSummaryResponse getSummariesByResponseId(
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
   * @return CCRMFinancialSummaryWrapper.FinSummaryResponse - Wrapper that will contains the different financial summaries responses
   */
  @TestVisible
  private static CCRMFinancialSummaryWrapper.FinSummaryResponse getDataFromCache(
    Cache.SessionPartition sessionPart,
    CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    CCRMFinancialSummaryWrapper.FinSummaryResponse finSumRespFromCache = new CCRMFinancialSummaryWrapper.FinSummaryResponse();

    String cachedJson = (String) sessionPart.get(finSumCallout.responseId);
    finSumRespFromCache = (CCRMFinancialSummaryWrapper.FinSummaryResponse) JSON.deserialize(
      cachedJson,
      CCRMFinancialSummaryWrapper.FinSummaryResponse.class
    );
    finSumRespFromCache.responseId = finSumCallout.responseId;
    finSumRespFromCache.cacheAck = CACHE_ACK;
    return finSumRespFromCache;
  }

  /**
   * @description - This method is used to fetch the data by making a callout
   * @param finSumCallout - Instance of Financial Summary Callout containing response Id and the the Api which need to be call
   * @return CCRMFinancialSummaryWrapper.FinSummaryResponse - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static CCRMFinancialSummaryWrapper.FinSummaryResponse getDataFromCallout(
    CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    List<String> capIdsList = new List<String>();
    List<String> capCustomerIdList = new List<String>();
    List<String> accountNumberList = new List<String>();
    CCRMFinancialSummaryWrapper.CacheData cacheWrapper = new CCRMFinancialSummaryWrapper.CacheData();
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    CCRMFinancialSummaryWrapper.FinSummaryResponse finSumRespFromCallout = new CCRMFinancialSummaryWrapper.FinSummaryResponse();
    finSumRespFromCallout.responseId = finSumCallout.responseId;

    capIdsList = getCLGRelatedCustomerIds(finSumRespFromCallout.responseId);

    accountNumberList = retrieveFinancialAccountsByCustomerId(capIdsList);

    if (!capIdsList.isEmpty()) {
      for (String capId : capIdsList) {
        capCustomerIdList.add(capId.split('_')[1]);
      }
    }

    if (finSumCallout.callTotalCustBalanceApi && !accountNumberList.isEmpty()) {
      //Making a callout to get the Total Balance
      //and if accountNumberList is Empty then it will return 'No Available Balance' as an acknowledgement
      finSumRespFromCallout.totalBalanceAck = getTotalBalance(
        finSumRespFromCallout.responseId,
        accountNumberList,
        TOTAL_CUSTOMER_BALANCE_FIELDSET
      );
      cacheWrapper.totalBalanceAck = finSumRespFromCallout.totalBalanceAck;
    }

    if (finSumCallout.callTerminalApi && !capCustomerIdList.isEmpty()) {
      //Making a callout to get the Total Merchant Terminal
      //and if capCustomerIdList is Empty then it will return 'No Available Balance' as an acknowledgement
      finSumRespFromCallout.terminalAck = getTotalMerchantTerminals(
        finSumRespFromCallout.responseId,
        capCustomerIdList,
        TERMINALS_FIELDSET
      );
      cacheWrapper.terminalAck = finSumRespFromCallout.terminalAck;
    }

    if (finSumCallout.callTotalCustBalanceApi && !capCustomerIdList.isEmpty()) {
      //Making a callout to get the Total Asset Finance Balance
      //and if capCustomerIdList is Empty then it will return 'No Available Balance' as an acknowledgement
      finSumRespFromCallout.assetBalanceAck = getTotalAssetFinanceBalance(
        finSumRespFromCallout.responseId,
        capCustomerIdList,
        TOTAL_ASSET_FINANCE_BALANCE_TYPE,
        TOTAL_ASSET_FINANCE_BALANCE_FIELDSET
      );
      cacheWrapper.assetBalanceAck = finSumRespFromCallout.assetBalanceAck;
    }

    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(
      finSumRespFromCallout.responseId,
      JSON.serialize(cacheWrapper)
    );
    return finSumRespFromCallout;
  }

  /**
   * @description - Get legal entity customer Ids related to CLG
   * @param customerId - CLG customer Id
   * @return List<String> List of External Ids
   */
  @TestVisible
  private static List<String> getCLGRelatedCustomerIds(String customerId) {
    List<String> capCustomerIdsList = new List<String>();
    Account accountRec = [
      SELECT Id, External_Id__c, RecordType.DeveloperName
      FROM Account
      WHERE Id = :customerId
      LIMIT 1
    ];
    if (accountRec.RecordType.DeveloperName == 'CLG') {
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
          !capCustomerIdsList.contains(
            aar.FinServ__RelatedAccount__r.External_Id__c
          )
        ) {
          capCustomerIdsList.add(aar.FinServ__RelatedAccount__r.External_Id__c);
        }
      }
      return capCustomerIdsList;
    }
    if (accountRec.External_Id__c != null) {
      capCustomerIdsList.add(accountRec.External_Id__c);
    }
    return capCustomerIdsList;
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
    if (customerIds.IsEmpty()) {
      return accountNumberList;
    }
    try {
      if (
        PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') &&
        PermissionUtils.canQuery('FinServ__FinancialAccount__c')
      ) {
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
          ORDER BY
            FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
        ]) {
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
   * @description : This method is used to make a callout to get the Total Balance
   * @param responseId - Id of the record
   * @param accountNumbers - List of accountNumbers
   * @param fieldSet - Constant keyword to unique Identify the callout
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalBalance(
    String responseId,
    List<String> accountNumbers,
    String fieldSet
  ) {
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
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalMerchantTerminals(
    String responseId,
    List<String> capCustomerIds,
    String fieldSet
  ) {
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
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalAssetFinanceBalance(
    String responseId,
    List<String> capCustomerIds,
    String type,
    String fieldSet
  ) {
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
   * @description This method is used to insert the data in the cache when platform event fire
   * @param response - Platform Event published byu mule
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
    String summaryType = (String) resMap.get('Summary_Type__c');

    if (sessionPart.contains(responseId)) {
      String cachedData = (String) sessionPart.get(responseId);
      cacheWrapper = (CCRMFinancialSummaryWrapper.CacheData) JSON.deserialize(
        cachedData,
        CCRMFinancialSummaryWrapper.CacheData.class
      );
    }

    switch on summaryType {
      when 'TOTAL_CUSTOMER_BALANCE' {
        cacheWrapper.totalBalance = (Decimal) resMap.get('Summary__c');
        cacheWrapper.totalBalanceAck = MULE_RESPONSE;
      }
      when 'TERMINALS' {
        cacheWrapper.totalMerchantTerminals = (Decimal) resMap.get(
          'Summary__c'
        );
        cacheWrapper.terminalAck = MULE_RESPONSE;
      }
      when else {
        cacheWrapper.totalAssetFinanceBalance = (Decimal) resMap.get(
          'Summary__c'
        );
        cacheWrapper.assetBalanceAck = MULE_RESPONSE;
      }
    }
    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(responseId, JSON.serialize(cacheWrapper));
  }
}
