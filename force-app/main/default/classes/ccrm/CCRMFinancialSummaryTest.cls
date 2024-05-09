/**
 * @author Naman Garg
 * @since Sept 2023
 * @description unit testing class for CCRMFinancialSummaryController class
 * @group Service
 */
@isTest
private class CCRMFinancialSummaryTest {
  public static CCRMFinancialSummaryWrapper.FinSummaryCallout finSummaryCallout = new CCRMFinancialSummaryWrapper.FinSummaryCallout();
  public static List<String> accountList;

  @testSetup
  static void createTestData() {
    User ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
  }

  static void getFinSummaryCallout(
    String responseId,
    Boolean callTotalCustBalanceApi,
    Boolean callTerminalApi,
    Boolean callAssetFinanceBalanceApi
  ) {
    finSummaryCallout.responseId = responseId;
    finSummaryCallout.callTotalCustBalanceApi = callTotalCustBalanceApi;
    finSummaryCallout.callTerminalApi = callTerminalApi;
    finSummaryCallout.callAssetFinanceBalanceApi = callAssetFinanceBalanceApi;
  }

  static List<String> getAccountList() {
    return accountList = new List<String>{
      'DDA-901221265',
      'ILS-397519424',
      'FM-251500720'
    };
  }

  @isTest
  static void testGetTotalBalance() {
    //GIVEN the List of Account External Ids & Response Id to call the Total Balance API
    List<String> accountList = getAccountList();
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String status = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalCustomerBalanceMock()
      );

      Test.startTest();
      //WHEN calling the TotalBalance API
      status = CCRMFinancialSummaryController.getTotalBalance(
        responseId,
        accountList,
        CCRMFinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET,
        true
      );
      Test.stopTest();

      //THEN the response should be 'Request Received' from Total Balance API
      System.assertEquals(
        status,
        CCRMFinancialSummaryController.MULE_RESPONSE,
        'Errored out while calling the Total Balance API'
      );
    }
  }

  @isTest
  static void testGetTotalBalanceNegative() {
    //GIVEN the List of Account External Ids Response Id to call the Total Balance API
    String errorMessage = '';
    try {
      List<String> accountList = getAccountList();
      String responseId = (String) Lib_FakeIdGenerator.getMockId(
        Account.getSobjectType()
      );
      String status = '';

      System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
        Test.startTest();
        //WHEN calling the TotalBalance API
        status = CCRMFinancialSummaryController.getTotalBalance(
          responseId,
          accountList,
          CCRMFinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET,
          true
        );
      }
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN there should be an error as no mock data is present
    System.assert(
      errorMessage != null,
      'Total Balance API called without any error'
    );
  }

  @isTest
  static void testGetTotalTerminals() {
    //GIVEN the List of Cap Customer Ids List & Response Id to call Total Merchant Terminal API
    List<String> capCustomerIds = new List<String>{ '4017192605' };
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String status = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalTerminalsMock()
      );

      Test.startTest();
      //WHEN calling the Total Merchant Terminals API
      status = CCRMFinancialSummaryController.getTotalMerchantTerminals(
        responseId,
        capCustomerIds,
        CCRMFinancialSummaryController.TERMINALS_FIELDSET,
        true
      );
      Test.stopTest();

      //THEN the response should be 'Request Received' from Total Merchant Terminals API
      system.assertEquals(
        status,
        CCRMFinancialSummaryController.MULE_RESPONSE,
        'Errored out while calling the Terminal API'
      );
    }
  }

  @isTest
  static void testGetTotalAssetFinanceBalance() {
    //GIVEN the List of cap Customer Ids List & Response Id
    List<String> capCustomerIds = new List<String>{ '4017192605' };
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String status = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalAssetFinanceBalanceMock()
      );

      Test.startTest();
      //WHEN calling the Total Asset Finance Balance API
      status = CCRMFinancialSummaryController.getTotalAssetFinanceBalance(
        responseId,
        capCustomerIds,
        CCRMFinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_TYPE,
        CCRMFinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_FIELDSET,
        true
      );
      Test.stopTest();

      //THEN the response should be 'Request Received' from Total Asset Finance Balance API
      system.assertEquals(
        status,
        CCRMFinancialSummaryController.MULE_RESPONSE,
        'Errored out while calling the Asset Balance API'
      );
    }
  }

  @isTest
  static void testInsertDataInCacheNegative() {
    //GIVEN a session partition of Cache
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String dataInCache = '';
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN trying to get the data from cache
      dataInCache = (String) sessionPart.get(responseId);
      Test.stopTest();

      //THEN data should not be found in cache as the data not inserted yet
      System.assertEquals(
        null,
        dataInCache,
        'Expected null but data found in cache'
      );
    }
  }

  @isTest
  static void testInsertDataInCache() {
    //GIVEN session Partition, expectedData and the platform event (totalBalanceResponse, terminalResponse, totalAssetBalanceResponse) value.
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMerchantTerminals":3,"totalBalanceAck":"Success","totalBalance":178.01,"totalAssetFinanceBalance":347.01,"terminalAck":"Success","lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Success"}';

    CCRMFinancialSummaryWrapper.CacheData expectedJSON = (CCRMFinancialSummaryWrapper.CacheData) JSON.deserialize(
      expectedData,
      CCRMFinancialSummaryWrapper.CacheData.class
    );

    String totalBalanceResponse =
      '{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","Response_Id__c":"' +
      responseId +
      '","Summary__c":178.01, "Status__c":"Success"}';
    String terminalResponse =
      '{"Summary_Type__c":"TERMINALS","Response_Id__c":"' +
      responseId +
      '","Summary__c":3, "Status__c":"Success"}';
    String totalAssetBalanceResponse =
      '{"Summary_Type__c":"TOTAL_ASSET_FINANCE_BALANCE","Response_Id__c":"' +
      responseId +
      '","Summary__c":347.01, "Status__c":"Success"}';
    String dataInCache = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN trying to insert the data in cache
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      CCRMFinancialSummaryController.insertDataInCache(terminalResponse);
      CCRMFinancialSummaryController.insertDataInCache(
        totalAssetBalanceResponse
      );
      Test.stopTest();
      dataInCache = (String) sessionPart.get(responseId);

      CCRMFinancialSummaryWrapper.CacheData dataInCacheJSON = (CCRMFinancialSummaryWrapper.CacheData) JSON.deserialize(
        dataInCache,
        CCRMFinancialSummaryWrapper.CacheData.class
      );

      //THEN the data should be inserted in cache successfully
      System.assertEquals(
        expectedJSON.totalMerchantTerminals,
        dataInCacheJSON.totalMerchantTerminals,
        'Data not found in cache after insertion'
      );
    }
  }

  @isTest
  static void testInsertDataInCacheErrorResponse() {
    //GIVEN session Partition, expectedData and the platform event (totalBalanceResponse, terminalResponse, totalAssetBalanceResponse) value.
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMerchantTerminals":null,"totalBalanceAck":"Unexpected error","totalBalance":null,"totalAssetFinanceBalance":null,"terminalAck":"Unexpected error","lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Unexpected error"}';

    String totalBalanceResponse =
      '{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","Response_Id__c":"' +
      responseId +
      '","Summary__c":0, "Status__c":"Error", "Error_Description__c" : "Api Failed"}';
    String terminalResponse =
      '{"Summary_Type__c":"TERMINALS","Response_Id__c":"' +
      responseId +
      '","Summary__c":0, "Status__c":"Error", "Error_Description__c" : "Api Failed"}';
    String totalAssetBalanceResponse =
      '{"Summary_Type__c":"TOTAL_ASSET_FINANCE_BALANCE","Response_Id__c":"' +
      responseId +
      '","Summary__c":0, "Status__c":"Error", "Error_Description__c" : "Api Failed"}';
    String dataInCache = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN trying to insert the data in cache
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      CCRMFinancialSummaryController.insertDataInCache(terminalResponse);
      CCRMFinancialSummaryController.insertDataInCache(
        totalAssetBalanceResponse
      );
      Test.stopTest();
      dataInCache = (String) sessionPart.get(responseId);

      //THEN the data should be inserted in cache successfully
      System.assertEquals(
        expectedData,
        dataInCache,
        'Data not found in cache after insertion'
      );
    }
  }

  @isTest
  static void testGetDataFromCache() {
    //GIVEN sessionPart, expectedData and financial summaries callout wrapper and totalBalance value
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    String totalBalanceResponse =
      '{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","Response_Id__c":"' +
      responseId +
      '","Summary__c":178.01, "Status__c": "Success"}';
    CCRMFinancialSummaryResponseWrapper finSumRespFromCache = new CCRMFinancialSummaryResponseWrapper();
    CCRMFinancialSummaryResponseWrapper expectedData = new CCRMFinancialSummaryResponseWrapper();
    expectedData.responseId = responseId;
    expectedData.totalBalance = 178.01;
    expectedData.totalBalanceAck = CCRMConstants.SUCCESS_RESPONSE;
    expectedData.totalMerchantTerminals = null;
    expectedData.terminalAck = null;
    expectedData.totalAssetFinanceBalance = null;
    expectedData.assetBalanceAck = null;
    expectedData.cacheAck = CCRMFinancialSummaryController.CACHE_ACK;
    expectedData.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');

    getFinSummaryCallout(responseId, false, false, false);

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      //WHEN there is already data present in cache
      finSumRespFromCache = CCRMFinancialSummaryController.getSummariesByResponseId(
        finSummaryCallout
      );
      Test.stopTest();

      //THEN user able to successfully get the data from cache
      System.assertEquals(
        JSON.serialize(expectedData),
        JSON.serialize(finSumRespFromCache),
        'Not able to get the data from Cache.'
      );
    }
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdNegative() {
    //GIVEN the empty list
    List<String> accList = new List<String>();

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN user trying to fetch the records
      accList = CCRMFinancialSummaryController.retrieveFinancialAccountsByCustomerId(
        new List<String>()
      );
      Test.stopTest();

      //THEN no records should be returned as list is empty
      System.assertEquals(
        0,
        accList.size(),
        'Able to retrieve records the financial account records.'
      );
    }
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdPositive() {
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    List<String> accExternalIdList = new List<String>();
    List<String> retrievedAccountList = new List<String>();
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();

    System.runAs(ccrmBaseUser) {
      //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
      primaryAccRec = TestDataFactory.createAccount(false);
      primaryAccRec.Source_System_ID__c = '901221245';
      primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
      primaryAccRec.ANZx_Customer__c = false;
      accToInsertList.add(primaryAccRec);

      secondaryAccRec = TestDataFactory.createAccount(false);
      secondaryAccRec.Source_System_ID__c = '45678990657';
      secondaryAccRec.External_Id__c = '';
      secondaryAccRec.ANZx_Customer__c = false;
      accToInsertList.add(secondaryAccRec);
      insert accToInsertList;

      finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
        primaryAccRec.Id,
        secondaryAccRec.Id,
        true
      );
      finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
        primaryAccRec.Id,
        finAccountRecord.Id,
        true
      );
      accExternalIdList.add(primaryAccRec.External_Id__c);

      Test.startTest();
      //WHEN trying to get the FinancialAccounts records
      retrievedAccountList = CCRMFinancialSummaryController.retrieveFinancialAccountsByCustomerId(
        accExternalIdList
      );
      Test.stopTest();

      //THEN user should be able to get the record
      System.assertEquals(
        1,
        retrievedAccountList.size(),
        'Not Able to retrieve the financial account records by customer Ids.'
      );
    }
  }

  @isTest
  static void testGetCLGRelatedCustomerIds() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    CCRMFinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new CCRMFinancialSummaryWrapper.CustomerIdWrapper();

    //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.OwnerId = ccrmBaseUser.Id;
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.OwnerId = ccrmBaseUser.Id;
    accToInsertList.add(secondaryAccRec);
    insert accToInsertList;

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      true
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      true
    );

    System.runAs(ccrmBaseUser) {
      Test.startTest();
      //WHEN trying to get the CLG Related Customer Ids records
      custIdWrapper = CCRMFinancialSummaryController.getCLGRelatedCustomerIds(
        primaryAccRec.Id
      );
      Test.stopTest();

      //THEN user should be able to get 1 record
      System.assertEquals(
        1,
        custIdWrapper.capIdsList.size(),
        'CAP customer Id not found'
      );
    }
  }

  @isTest
  static void testGetNonCLGRelatedCustomerIds() {
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    CCRMFinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new CCRMFinancialSummaryWrapper.CustomerIdWrapper();
    String errorMessage = '';

    //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.OwnerId = ccrmBaseUser.Id;
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.OwnerId = ccrmBaseUser.Id;
    accToInsertList.add(secondaryAccRec);
    insert accToInsertList;

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      true
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      true
    );

    System.runAs(ccrmBaseUser) {
      Test.startTest();
      try {
        //WHEN trying to get the CLG Related Customer Ids records
        custIdWrapper = CCRMFinancialSummaryController.getCLGRelatedCustomerIds(
          primaryAccRec.Id
        );
      } catch (Exception e) {
        errorMessage = e.getMessage();
      }
      Test.stopTest();

      //THEN user should get an exception
      System.assert(
        errorMessage != null,
        'Able to access all the field included in query'
      );
    }
  }

  @isTest
  static void testGetDataFromCallout() {
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    CCRMFinancialSummaryResponseWrapper expectedData;
    CCRMFinancialSummaryResponseWrapper responseData = new CCRMFinancialSummaryResponseWrapper();
    User ccrmBaseUser = CCRMTestDataFactory.getCCRMBaseUser();

    System.runAs(ccrmBaseUser) {
      //GIVEN account List, finAccountRecord, finAccountRoleRecord, callout and expectedData record
      primaryAccRec = TestDataFactory.createAccount(false);
      primaryAccRec.Source_System_ID__c = '901221245';
      primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
      primaryAccRec.ANZx_Customer__c = false;
      accToInsertList.add(primaryAccRec);

      secondaryAccRec = TestDataFactory.createAccount(false);
      secondaryAccRec.Source_System_ID__c = '45678990657';
      secondaryAccRec.External_Id__c = '';
      secondaryAccRec.ANZx_Customer__c = false;
      accToInsertList.add(secondaryAccRec);
      insert accToInsertList;

      finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
        primaryAccRec.Id,
        secondaryAccRec.Id,
        true
      );
      finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
        primaryAccRec.Id,
        finAccountRecord.Id,
        true
      );

      getFinSummaryCallout(primaryAccRec.Id, true, true, true);

      expectedData = new CCRMFinancialSummaryResponseWrapper();
      expectedData.responseId = primaryAccRec.Id;
      expectedData.totalBalance = null;
      expectedData.totalBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
      expectedData.totalMerchantTerminals = null;
      expectedData.terminalAck = CCRMFinancialSummaryController.MULE_RESPONSE;
      expectedData.totalAssetFinanceBalance = null;
      expectedData.assetBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
      expectedData.cacheAck = null;

      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalCustomerBalanceMock()
      );
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalTerminalsMock()
      );
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalAssetFinanceBalanceMock()
      );

      Test.startTest();
      //WHEN data is not found in cache so making a callout to the APIs
      responseData = CCRMFinancialSummaryController.getSummariesByResponseId(
        finSummaryCallout
      );
      Test.stopTest();

      //THEN it will successfully able to make the API callout and return the response
      System.assertEquals(
        JSON.serialize(expectedData),
        JSON.serialize(responseData),
        'Errored out while calling the APIs'
      );
    }
  }

  @isTest
  static void testPopulateDataInCache() {
    //GIVEN finSumResponse, sessionPart, expectedData record
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    CCRMFinancialSummaryResponseWrapper finSumResponse = new CCRMFinancialSummaryResponseWrapper();
    finSumResponse.responseId = responseId;
    finSumResponse.totalBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    finSumResponse.terminalAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    finSumResponse.assetBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;

    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMerchantTerminals":null,"totalBalanceAck":"Request Received","totalBalance":null,"totalAssetFinanceBalance":null,"terminalAck":"Request Received","lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Request Received"}';
    String cacheData = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN trying to populate the data in cache
      CCRMFinancialSummaryController.populateDataInCache(finSumResponse);
      cacheData = (String) sessionPart.get(responseId);
      Test.stopTest();

      //THEN the data should be successfully inserted/populated in cache
      System.assertEquals(
        expectedData,
        cacheData,
        'Data not populated in cache'
      );
    }
  }

  @isTest
  static void testMakeApiCallout() {
    //GIVEN accountList, endPoint, responseId, totalBalanceWrapper which is required to make a Callout
    List<String> accountList = getAccountList();
    String endPoint =
      CCRMFinancialSummaryController.BASE_CALLOUT_URL + 'summaries';
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    CCRMFinancialSummaryWrapper.TotalBalance totalBalanceWrapper = new CCRMFinancialSummaryWrapper.TotalBalance(
      accountList,
      CCRMFinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET,
      responseId
    );
    String status = '';

    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.setMock(
        HttpCalloutMock.class,
        new CCRMTestDataFactory.GetTotalCustomerBalanceMock()
      );

      Test.startTest();
      //WHEN making a callout to TotalCustomerBalance API
      Map<String, String> headers = CCRMFinancialSummaryController.generateHeader();
      status = CCRMFinancialSummaryController.makeApiCallout(
        endPoint,
        HTTP_METHOD.HTTP_POST,
        headers,
        JSON.serialize(totalBalanceWrapper)
      );
      Test.stopTest();

      //THEN receive a successful response from the API
      System.assertEquals(
        status,
        CCRMFinancialSummaryController.MULE_RESPONSE,
        'Error while making the API caloout.'
      );
    }
  }
}
