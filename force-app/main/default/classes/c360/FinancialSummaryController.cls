/**
 * @author : Naman Garg
 * @description : This class is used to display the Financial Summaries.
 * @since : Aug 2023
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class FinancialSummaryController {
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
    'CAP-CIS:RSV',
    'CAP-CIS:ILS',
    'CAP-CIS:PCA',
    'CAP-CIS:CDA'
  };

  private static final FinancialAccountQueryBaseRepository FA_REPOSITORY = (FinancialAccountQueryBaseRepository) Lib_InstanceProvider.forType(
    FinancialAccountQueryBaseRepository.class
  );
  private static final FinancialSummaryRepository FS_REPOSITORY = (FinancialSummaryRepository) Lib_InstanceProvider.forType(
    FinancialSummaryRepository.class
  );

  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
  );
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
  @TestVisible
  private static final String TOTAL_CUSTOMER_LIMIT = 'TOTAL_CUSTOMER_LIMIT';

  /**
   * @description - This method is used to fetch the summaries values from the cache and if no values present then it will
   * 			   make a callout to mule to get the Financial Summaries result
   * @param finSumCallout - FinancialSummaryWrapper.FinSummaryCallout contains the responseId and the the Api which need to be call
   * @return FinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static FinancialSummaryResponseWrapper getSummariesByResponseId(
    FinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    Cache.SessionPartition sessionPart = DataPartitionUtil.dataPartition;
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
   * @return FinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @TestVisible
  private static FinancialSummaryResponseWrapper getDataFromCache(
    Cache.SessionPartition sessionPart,
    FinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    FinancialSummaryResponseWrapper finSumRespFromCache = new FinancialSummaryResponseWrapper();

    String cachedJson = (String) sessionPart.get(finSumCallout.responseId);
    finSumRespFromCache = (FinancialSummaryResponseWrapper) JSON.deserialize(
      cachedJson,
      FinancialSummaryResponseWrapper.class
    );
    finSumRespFromCache.responseId = finSumCallout.responseId;
    finSumRespFromCache.cacheAck = CACHE_ACK;
    return finSumRespFromCache;
  }

  /**
   * @description - This method is used to fetch the data by making a callout
   * @param finSumCallout - Instance of Financial Summary Callout containing response Id and the the Api which need to be call
   * @return FinancialSummaryResponseWrapper - Wrapper that will contains the different financial summaries responses
   */
  @AuraEnabled
  public static FinancialSummaryResponseWrapper getDataFromCallout(
    FinancialSummaryWrapper.FinSummaryCallout finSumCallout
  ) {
    Set<String> accountNumberList = new Set<String>();
    FinancialSummaryResponseWrapper finSumRespFromCallout = new FinancialSummaryResponseWrapper();
    FinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new FinancialSummaryWrapper.CustomerIdWrapper();

    finSumRespFromCallout.responseId = finSumCallout.responseId;
    custIdWrapper = getCLGRelatedCustomerIds(finSumRespFromCallout.responseId);
    accountNumberList = retrieveFinancialAccountsByCustomerId(
      custIdWrapper.capIdsList
    );
    accountNumberList = removeEncryptedPca(accountNumberList);
    //Making a callout to get the Total Balance
    //and if accountNumberList is Empty then it will return 'No Available Balance' as an acknowledgement
    finSumRespFromCallout.totalBalanceAck = getTotalBalance(
      finSumRespFromCallout.responseId,
      accountNumberList,
      TOTAL_CUSTOMER_BALANCE_FIELDSET,
      finSumCallout.callTotalCustBalanceApi
    );

    //TotalDebitBalance and TotalCreditBalance will have same acknowledgement as TotalBalance
    finSumRespFromCallout.totalDebitBalanceAck = finSumRespFromCallout.totalBalanceAck;
    finSumRespFromCallout.totalCreditBalanceAck = finSumRespFromCallout.totalBalanceAck;

    //Making a callout to get the Total Asset Finance Balance
    //and if capCustomerIdList is Empty then it will return 'No Available Balance' as an acknowledgement
    finSumRespFromCallout.assetBalanceAck = getTotalAssetFinanceBalance(
      finSumRespFromCallout.responseId,
      custIdWrapper.capIdsModifiedList,
      TOTAL_ASSET_FINANCE_BALANCE_TYPE,
      TOTAL_ASSET_FINANCE_BALANCE_FIELDSET,
      finSumCallout.callAssetFinanceBalanceApi
    );

    try {
      //Making a callout to get the Total Limits
      finSumRespFromCallout.totalLimitAck = getTotalLimts(
        finSumRespFromCallout.responseId,
        accountNumberList,
        TOTAL_CUSTOMER_LIMIT,
        finSumCallout.callTotalLimitsApi
      );

      populateDataInCache(finSumRespFromCallout);
    } catch (Exception ex) {
      finSumRespFromCallout.totalLimitAck = null;
    }

    return finSumRespFromCallout;
  }

  /**
   * @description - Get legal entity customer Ids related to CLG
   * @param customerId - CLG customer Id
   * @return List<String> List of External Ids
   */
  @TestVisible
  private static FinancialSummaryWrapper.CustomerIdWrapper getCLGRelatedCustomerIds(
    String customerId
  ) {
    FinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new FinancialSummaryWrapper.CustomerIdWrapper();
    String capId = '';
    Set<String> capIdSet = new Set<String>();

    Account accountRec = FS_REPOSITORY.getAccountById(customerId);
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
      for (
        FinServ__AccountAccountRelation__c aar : FS_REPOSITORY.getActiveClgAccAccRelations(
          customerId
        )
      ) {
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
  private static Set<String> retrieveFinancialAccountsByCustomerId(
    List<String> customerIds
  ) {
    Set<String> accountNumberList = new Set<String>();
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
      List<FinServ__FinancialAccountRole__c> listOfFinancialAccountRoles = FA_REPOSITORY.getFinancialAccountsWithCustomerId(
        new Set<String>(customerIds),
        ARNC_FINANCIAL_ACCOUNT_RECORDTYPE_NAME,
        productTypes,
        roleTypes
      );
      for (
        FinServ__FinancialAccountRole__c faRole : listOfFinancialAccountRoles
      ) {
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
    Set<String> accountNumbers,
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

    FinancialSummaryWrapper.TotalBalance totalBalanceWrapper = new FinancialSummaryWrapper.TotalBalance(
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

    FinancialSummaryWrapper.TerminalAndTotalAsset assetFinanceWrapper = new FinancialSummaryWrapper.TerminalAndTotalAsset(
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
    headers.put('Authorization', 'Bearer ' + ARNCService.generateJWTToken());
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
    FinancialSummaryResponseWrapper finSumResponse
  ) {
    FinancialSummaryWrapper.CacheData cacheWrapper = new FinancialSummaryWrapper.CacheData();
    Cache.SessionPartition sessionPart = DataPartitionUtil.dataPartition;
    if (finSumResponse.totalBalanceAck != null) {
      cacheWrapper.totalBalanceAck = finSumResponse.totalBalanceAck;
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
    Cache.SessionPartition sessionPart = DataPartitionUtil.dataPartition;
    Map<String, String> resMap = prepareResponseMap(response);
    Map<String, String> summaryMap = prepareSummaryMap(
      resMap.get('Summary__c')
    );
    resMap.putAll(summaryMap);
    String responseId = (String) resMap.get('Response_Id__c');
    String status = (String) resMap.get('Status__c');
    FinancialSummaryWrapper.CacheData cacheWrapper = prepareCacheWrapper(
      responseId
    );

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
    FinancialSummaryWrapper.CacheData cacheWrapper,
    String responseId,
    Cache.SessionPartition sessionPart,
    Map<String, Object> resMap
  ) {
    String errorDescription = (String) resMap.get('Error_Description__c');

    if (resMap.containsKey('TOTAL_CUSTOMER_BALANCE')) {
      cacheWrapper.totalBalanceAck = CCRMConstants.ERROR_RESPONSE;
      cacheWrapper.totalCreditBalanceAck = CCRMConstants.ERROR_RESPONSE;
      cacheWrapper.totalDebitBalanceAck = CCRMConstants.ERROR_RESPONSE;
    }

    if (resMap.containsKey('TOTAL_ASSET_FINANCE_BALANCE')) {
      cacheWrapper.assetBalanceAck = CCRMConstants.ERROR_RESPONSE;
    }
    if (resMap.containsKey('TOTAL_CUSTOMER_LIMIT')) {
      cacheWrapper.totalLimitAck = CCRMConstants.ERROR_RESPONSE;
    }

    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(responseId, JSON.serialize(cacheWrapper));
    Logger.error(errorDescription, responseId);
    Logger.saveLog();
  }

  /**
   * @description This method create CacheWrapper from CustomerId and SessionPart
   * @param responseId - Customer Id
   * @return cacheWrapper - cachedWrapper
   */
  @TestVisible
  private static FinancialSummaryWrapper.CacheData prepareCacheWrapper(
    String responseId
  ) {
    FinancialSummaryWrapper.CacheData cacheWrapper = new FinancialSummaryWrapper.CacheData();
    Cache.SessionPartition sessionPart = DataPartitionUtil.dataPartition;
    if (sessionPart.contains(responseId)) {
      String cachedData = (String) sessionPart.get(responseId);
      cacheWrapper = (FinancialSummaryWrapper.CacheData) JSON.deserialize(
        cachedData,
        FinancialSummaryWrapper.CacheData.class
      );
    }
    return cacheWrapper;
  }

  /**
   * @description This method is used to insert the data in the cache when platform event fire in case of Sucess
   * @param cacheWrapper - cache wrapper instance
   * @param responseId - record Id
   * @param sessionPart - session Part of the cache
   * @param resMap - platform event response
   */
  private static void handleSuccessResponse(
    FinancialSummaryWrapper.CacheData cacheWrapper,
    String responseId,
    Cache.SessionPartition sessionPart,
    Map<String, Object> resMap
  ) {
    if (resMap.containsKey('TOTAL_CUSTOMER_BALANCE')) {
      cacheWrapper.totalBalance = Decimal.valueOf(
        (string) resMap.get('TOTAL_CUSTOMER_BALANCE')
      );
      cacheWrapper.totalBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
      cacheWrapper.totalDebitBalance = Decimal.valueOf(
        (string) resMap.get('TOTAL_DEBIT_BALANCE')
      );
      cacheWrapper.totalDebitBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
      cacheWrapper.totalCreditBalance = Decimal.valueOf(
        (string) resMap.get('TOTAL_CREDIT_BALANCE')
      );
      cacheWrapper.totalCreditBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
    }
    if (resMap.containsKey('TOTAL_ASSET_FINANCE_BALANCE')) {
      cacheWrapper.totalAssetFinanceBalance = Decimal.valueOf(
        (string) resMap.get('TOTAL_ASSET_FINANCE_BALANCE')
      );
      cacheWrapper.assetBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
    }
    if (resMap.containsKey('TOTAL_CUSTOMER_LIMIT')) {
      cacheWrapper.totalLimitValue = Decimal.valueOf(
        (string) resMap.get('TOTAL_CUSTOMER_LIMIT')
      );
      cacheWrapper.totalLimitAck = CCRMConstants.SUCCESS_RESPONSE;
    }
    cacheWrapper.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');
    sessionPart.put(responseId, JSON.serialize(cacheWrapper));
  }

  /**
   * @description This method will convert JSON Response to a Map.
   * @param response - response value. Ex - {"Response_Id__c": "0019h000009g1TxAAI","Status__c": "Success","Summary__c":" {"items": ["subType": "TOTAL_CREDIT_BALANCE","subTypeValue" : 0}]}"}
   * @return responseMap - parsedMap of Response.
   */
  @TestVisible
  private static Map<String, String> prepareResponseMap(String response) {
    Map<String, String> responseMap = new Map<String, String>();
    Map<String, Object> eventMap = (Map<String, Object>) JSON.deserializeUntyped(
      response
    );

    if (eventMap.containsKey('Error_Description__c')) {
      responseMap.put(
        'Error_Description__c',
        (String) eventMap.get('Error_Description__c')
      );
    }
    responseMap.put('Status__c', (String) eventMap.get('Status__c'));
    responseMap.put('Response_Id__c', (String) eventMap.get('Response_Id__c'));
    responseMap.put('Summary__c', (String) eventMap.get('Summary__c'));
    return responseMap;
  }

  /**
   * @description This method will convert JSON Summary to a Map.
   * @param summary - response value. Ex - {"Summary__c":" {"items": ["subType": "TOTAL_CREDIT_BALANCE","subTypeValue" : 0}]}"}
   * @return summaryMap - parsedMap of Response.
   */
  @TestVisible
  private static Map<String, String> prepareSummaryMap(String summary) {
    Map<String, Object> parsedMap = (Map<String, Object>) JSON.deserializeUntyped(
      summary
    );
    List<Object> items = (List<Object>) parsedMap.get('items');
    Map<String, String> summaryMap = new Map<String, String>();
    for (Object item : items) {
      Map<String, Object> itemMap = (Map<String, Object>) item;
      summaryMap.put(
        (string) itemMap.get('subType'),
        String.valueof(itemMap.get('subTypeValue'))
      );
    }
    return summaryMap;
  }

  /**
   * @description This method provides List of Financial_Summary_Setting__mdt Metadata Records
   * @return wrapFinancialSummary wrapper of summary setting and user profile records
   */
  @AuraEnabled(cacheable=true)
  public static wrapFinancialSummary getFinSummaryMetadata() {
    Id strCurrentUserId = userinfo.getuserid();
    Map<Id, User> mapOfUser = USER_REPOSITORY.getUserMapFromUserIds(
      new Set<Id>{ strCurrentUserId }
    );
    wrapFinancialSummary objWrapper = new wrapFinancialSummary();
    objWrapper.lstOfSymmarySetting = FS_REPOSITORY.getFinSummaryMetadata();
    objWrapper.strCurrentUserProfileName = mapOfUser.get(strCurrentUserId)
      .Profile.Name;
    return objWrapper;
  }
  /**
   * @description This clas is used to wrap of financial summary setting and user profile records
   */
  public class WrapFinancialSummary {
    /**
     * @description list of financial summary setting records
     */
    @AuraEnabled
    public List<Financial_Summary_Setting__mdt> lstOfSymmarySetting {
      get;
      set;
    }
    /**
     * @description variable to store ciurrent user profile name
     */
    @AuraEnabled
    public String strCurrentUserProfileName { get; set; }
  }

  /**
   * @description This method is used to make a callout to get the Total Merchant Terminals
   * @param responseId - Id of the record
   * @param accountNumbers - List of accountNumbers
   * @param fieldSet - Constant keyword to unique Identify the callout
   * @param callTotalLimitsApi - true if we need to call this API
   * @return String - callout response
   */
  @TestVisible
  private static String getTotalLimts(
    String responseId,
    Set<String> accountNumbers,
    String fieldSet,
    Boolean callTotalLimitsApi
  ) {
    if (accountNumbers.isEmpty()) {
      return CCRMConstants.NO_AVAILABLE_BALANCE;
    }

    if (!callTotalLimitsApi) {
      return null;
    }

    Map<String, String> headers = generateHeader();
    String endPoint = BASE_CALLOUT_URL + 'summaries';

    FinancialSummaryWrapper.TotalLimits totalLimitsWrapper = new FinancialSummaryWrapper.TotalLimits(
      accountNumbers,
      fieldSet,
      responseId
    );

    try {
      return makeApiCallout(
        endPoint,
        HTTP_METHOD.HTTP_POST,
        headers,
        JSON.serialize(totalLimitsWrapper)
      );
    } catch (Exception ex) {
      Logger.error(ex.getMessage());
      Logger.saveLog();
      return CCRMConstants.ERROR_RESPONSE;
    }
  }

  /**
   * @description This method removed PCAs having encrypted account number
   * @param accountNumberList - set of accountNumbers
   * @return wrapFinancialSummary wrapper of summary setting and user profile records
   */
  @TestVisible
  private static Set<String> removeEncryptedPca(Set<String> accountNumberList) {
    Set<String> filteredAccNumbers = new Set<String>();
    for (String accNo : accountNumberList) {
      if (
        !accNo.contains('PCA-') || (accNo.substringAfter('PCA-').isNumeric())
      ) {
        filteredAccNumbers.add(accNo);
      }
    }
    return filteredAccNumbers;
  }
}
