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

  private static Set<String> productTypes = new Set<String>();
  private static List<String> accountNumberList = new List<String>();
  private static Set<String> capCustomerIdsSet = new Set<String>();
  private static Map<String, FinServ__FinancialAccount__c> accountMap = new Map<String, FinServ__FinancialAccount__c>();
  private static Map<String, FinServ__FinancialAccountRole__c> accountRoleMap = new Map<String, FinServ__FinancialAccountRole__c>();
  private static final String BASE_CALLOUT_URL = Label.Financial_Account_Endpoint;
  private static final String TOTAL_CUSTOMER_BALANCE_FIELDSET = 'TOTAL_CUSTOMER_BALANCE';
  private static final String TERMINALS_FIELDSET = 'TERMINALS';
  private static final String TOTAL_ASSET_FINANCE_BALANCE_FIELDSET = 'TOTAL_ASSET_FINANCE_BALANCE';
  private static final String TOTAL_ASSET_FINANCE_BALANCE_TYPE = 'BOTH';
  private static final String MULE_RESPONSE = 'Request Received';

  /**
   * @description : This method is used to make a callout to get the Total Balance.
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

    CCRMBalanceWrapper customerBalanceWrap = new CCRMBalanceWrapper();
    customerBalanceWrap.accounts = accountNumbers;
    customerBalanceWrap.fieldSet = fieldSet;
    customerBalanceWrap.responseId = responseId;

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(customerBalanceWrap)
    );
  }

  /**
   * @description This method is used to make a callout to get the Total Merchant Terminals.
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

    CCRMTerminalTotalAssetWrapper terminalWrap = new CCRMTerminalTotalAssetWrapper();
    terminalWrap.capCustomerIds = capCustomerIds;
    terminalWrap.fieldSet = fieldSet;
    terminalWrap.responseId = responseId;

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(terminalWrap)
    );
  }

  /**
   * @description This method is used to make a callout to get the Total Asset Finance Balance.
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

    CCRMTerminalTotalAssetWrapper totalAssetWrap = new CCRMTerminalTotalAssetWrapper();
    totalAssetWrap.capCustomerIds = capCustomerIds;
    totalAssetWrap.type = type;
    totalAssetWrap.fieldSet = fieldSet;
    totalAssetWrap.responseId = responseId;

    return makeApiCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(totalAssetWrap)
    );
  }

  /**
   * @description : This method is used to make a callout to get the Financial Summaries.
   * @param endPoint - endpoint to which we have to make a callout.
   * @param method - Http Method name.
   * @param headers - header.
   * @param requestObj - body of the request.
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
   * @description This method is used to generate Header
   * @return Map<String, String> return the header in form of key-value pair.
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
    headers.put(
      'Authorization',
      'Bearer ' + CCRMARNCService.generateJWTToken()
    );
    return headers;
  }

  /**
   * @description Retrieves list of financial accounts related to a customer via financial account role relationship (FAR)
   * @param customerIds the FAR related customer external Id
   */
  private static void retrieveFinancialAccountsByCustomerId(
    Set<String> customerIds
  ) {
    if (customerIds.isEmpty()) {
      return;
    }

    if (
      PermissionUtils.canQuery('FinServ__FinancialAccountRole__c') &&
      PermissionUtils.canQuery('FinServ__FinancialAccount__c')
    ) {
      List<FinServ__FinancialAccountRole__c> faRoles = [
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
          //AND FinServ__FinancialAccount__r.Product_Type__c IN :productTypes
          AND Role_Type__c IN :roleTypes.keyset()
        ORDER BY FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      ];
      for (FinServ__FinancialAccountRole__c faRole : faRoles) {
        accountNumberList.add(
          faRole.FinServ__FinancialAccount__r.Product_Type__c.right(3)
            .remove(':') +
          '-' +
          faRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
        );
      }
    }
  }

  /**
   * @description get legal entity customer Ids related to CLG
   * @param customerId CLG customer Id
   * @return Set<String> Set of customer Ids
   */
  private static Set<String> getCLGRelatedCustomerIds(String customerId) {
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
      ]) {
        capCustomerIdsSet.add(aar.FinServ__RelatedAccount__r.External_Id__c);
      }
    } else {
      capCustomerIdsSet.add(accountRec.External_Id__c);
    }
    return capCustomerIdsSet;
  }

  /**
   * @description This method is used to fetch the summaries values from the cache and if no values present then it will
   * 			   make a callout to mule to get the Financial Summaries result.
   * @param responseId - Id of the record
   * @return CCRMFinancialSummaryWrapper - Wrapper that will contains the different financial summaries responses.
   */
  @AuraEnabled
  public static CCRMFinancialSummaryWrapper getSummariesByResponseId(
    String responseId
  ) {
    CCRMFinancialSummaryWrapper finSumWrap = new CCRMFinancialSummaryWrapper();
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    if (sessionPart.contains(responseId)) {
      String cachedData = (String) sessionPart.get(responseId);
      Map<String, Object> cacheObj = (Map<String, Object>) JSON.deserializeUnTyped(
        cachedData
      );
      finSumWrap.responseId = responseId;
      finSumWrap.totalBalance = (Decimal) cacheObj.get('totalBalance');
      finSumWrap.totalMerchantTerminals = (Decimal) cacheObj.get(
        'totalMerchantTerminals'
      );
      finSumWrap.totalAssetFinanceBalance = (Decimal) cacheObj.get(
        'totalAssetFinanceBalance'
      );
      finSumWrap.lastSummaryUpdateDate = (String) cacheObj.get(
        'lastSummaryUpdateDate'
      );
    } else {
      Set<String> customerIds = getCLGRelatedCustomerIds(responseId);
      retrieveFinancialAccountsByCustomerId(customerIds);
      String totalBalanceResponse = getTotalBalance(
        responseId,
        accountNumberList,
        TOTAL_CUSTOMER_BALANCE_FIELDSET
      );
      String terminalResponse = getTotalMerchantTerminals(
        responseId,
        new List<String>{ capCustomerIdsSet.iterator().next().split('_')[1] },
        TERMINALS_FIELDSET
      );
      String totalAssetBalanceResponse = getTotalAssetFinanceBalance(
        responseId,
        new List<String>{ capCustomerIdsSet.iterator().next().split('_')[1] },
        TOTAL_ASSET_FINANCE_BALANCE_TYPE,
        TOTAL_ASSET_FINANCE_BALANCE_FIELDSET
      );
      if (
        totalBalanceResponse == MULE_RESPONSE &&
        terminalResponse == MULE_RESPONSE &&
        totalAssetBalanceResponse == MULE_RESPONSE
      ) {
        finSumWrap.acknowledgement = 'Request sent';
      }
    }
    return finSumWrap;
  }

  /**
   * @description This method is used to insert the data in the cache.
   * @param response - Platform Event published byu mule.
   */
  @AuraEnabled
  public static void insertDataInCache(String response) {
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    CacheWrapper cacheWrap = new CacheWrapper();
    Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );
    Map<String, Object> dataMap = (Map<String, Object>) resMap.get('data');
    Map<String, Object> payloadMap = (Map<String, Object>) dataMap.get(
      'payload'
    );
    String responseId = (String) payloadMap.get('Response_Id__c');
    String summaryType = (String) payloadMap.get('Summary_Type__c');

    if (sessionPart.contains(responseId)) {
      String cachedData = (String) sessionPart.get(responseId);
      Map<String, Object> cacheObj = (Map<String, Object>) JSON.deserializeUnTyped(
        cachedData
      );
      cacheWrap.totalBalance = (summaryType == TOTAL_CUSTOMER_BALANCE_FIELDSET)
        ? (Decimal) payloadMap.get('Summary__c')
        : (Decimal) cacheObj.get('totalBalance');
      cacheWrap.totalMerchantTerminals = (summaryType == TERMINALS_FIELDSET)
        ? (Decimal) payloadMap.get('Summary__c')
        : (Decimal) cacheObj.get('totalMerchantTerminals');
      cacheWrap.totalAssetFinanceBalance = (summaryType ==
        TOTAL_ASSET_FINANCE_BALANCE_FIELDSET)
        ? (Decimal) payloadMap.get('Summary__c')
        : (Decimal) cacheObj.get('totalAssetFinanceBalance');
      cacheWrap.lastSummaryUpdateDate = DateTime.now()
        .format('dd/MM/yyyy hh:mm a');
      sessionPart.put(responseId, JSON.serialize(cacheWrap));
    } else {
      if (summaryType == TOTAL_CUSTOMER_BALANCE_FIELDSET) {
        cacheWrap.totalBalance = (Decimal) payloadMap.get('Summary__c');
      } else if (summaryType == TERMINALS_FIELDSET) {
        cacheWrap.totalMerchantTerminals = (Decimal) payloadMap.get(
          'Summary__c'
        );
      } else if (summaryType == TOTAL_ASSET_FINANCE_BALANCE_FIELDSET) {
        cacheWrap.totalAssetFinanceBalance = (Decimal) payloadMap.get(
          'Summary__c'
        );
      }
      cacheWrap.lastSummaryUpdateDate = DateTime.now()
        .format('dd/MM/yyyy hh:mm a');
      sessionPart.put(responseId, JSON.serialize(cacheWrap));
    }
  }

  /**
   * @description This method is used to make a respective callout to mule if any values of financial summaries is missing.
   * @param responseId - Id of the record.
   * @param callTotalCustomerBalanceApi - true if calling this api.
   * @param callTerminalApi - true if calling this api.
   * @param callTotalAssetBalanceApi - true if calling this api.
   */
  @AuraEnabled
  public static void summariesCallout(
    String responseId,
    Boolean callTotalCustomerBalanceApi,
    Boolean callTerminalApi,
    Boolean callTotalAssetBalanceApi
  ) {
    Set<String> customerIds = getCLGRelatedCustomerIds(responseId);
    if (callTotalCustomerBalanceApi) {
      retrieveFinancialAccountsByCustomerId(customerIds);
      String totalBalanceResponse = getTotalBalance(
        responseId,
        accountNumberList,
        TOTAL_CUSTOMER_BALANCE_FIELDSET
      );
    }
    if (callTerminalApi) {
      String terminalResponse = getTotalMerchantTerminals(
        responseId,
        new List<String>{ capCustomerIdsSet.iterator().next().split('_')[1] },
        TERMINALS_FIELDSET
      );
    }
    if (callTotalAssetBalanceApi) {
      String totalAssetBalanceResponse = getTotalAssetFinanceBalance(
        responseId,
        new List<String>{ capCustomerIdsSet.iterator().next().split('_')[1] },
        TOTAL_ASSET_FINANCE_BALANCE_TYPE,
        TOTAL_ASSET_FINANCE_BALANCE_FIELDSET
      );
    }
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CCRMBalanceWrapper wrapper class to create Total Customer Balance response
   * @name CCRMBalanceWrapper
   */
  public class CCRMBalanceWrapper {
    public List<String> accounts = new List<String>();
    public String fieldSet;
    public String responseId;
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CCRMTerminalTotalAssetWrapper wrapper class to create Terminal and Total Asset Balance response
   * @name CCRMTerminalTotalAssetWrapper
   */
  public class CCRMTerminalTotalAssetWrapper {
    public List<String> capCustomerIds = new List<String>();
    public String type;
    public String fieldSet;
    public String responseId;
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CCRMFinancialSummaryWrapper wrapper class to get the response published by mule.
   * @name CCRMFinancialSummaryWrapper
   */
  public class CCRMFinancialSummaryWrapper {
    @AuraEnabled
    public String responseId;
    @AuraEnabled
    public Decimal totalBalance;
    @AuraEnabled
    public Decimal totalMerchantTerminals;
    @AuraEnabled
    public Decimal totalAssetFinanceBalance;
    @AuraEnabled
    public String lastSummaryUpdateDate;
    @AuraEnabled
    public String acknowledgement;
  }

  /**
   * @author Naman Garg
   * @group CCRM (Commercial CRM)
   * @description CacheWrapper wrapper class to insert the data in cache.
   * @name CacheWrapper
   */
  public class CacheWrapper {
    @AuraEnabled
    public Decimal totalBalance;
    @AuraEnabled
    public Decimal totalMerchantTerminals;
    @AuraEnabled
    public Decimal totalAssetFinanceBalance;
    @AuraEnabled
    public String lastSummaryUpdateDate;
  }
}
