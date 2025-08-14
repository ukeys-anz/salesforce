/**
 * @author Naman Garg
 * @since Sept 2023
 * @description unit testing class for FinancialSummaryController class
 * @group Service
 */
@isTest
private class FinancialSummaryControllerTest {
  public static FinancialSummaryWrapper.FinSummaryCallout finSummaryCallout = new FinancialSummaryWrapper.FinSummaryCallout();
  public static Set<String> accountList;
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider fsRepoMock;

  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
    fsRepoMock = Lib_MockProvider.forType(FinancialSummaryRepository.class);
  }

  static void getFinSummaryCallout(
    String responseId,
    Boolean callTotalCustBalanceApi,
    Boolean callAssetFinanceBalanceApi,
    Boolean callTotalLimitsApi,
    Boolean callMortageLendingApi
  ) {
    finSummaryCallout.responseId = responseId;
    finSummaryCallout.callTotalCustBalanceApi = callTotalCustBalanceApi;
    finSummaryCallout.callAssetFinanceBalanceApi = callAssetFinanceBalanceApi;
    finSummaryCallout.callTotalLimitsApi = callTotalLimitsApi;
    finSummaryCallout.callMortageLendingApi = callMortageLendingApi;
  }

  static Set<String> getAccountList() {
    return accountList = new Set<String>{
      'DDA-901221265',
      'ILS-397519424',
      'FM-251500720'
    };
  }

  @isTest
  static void testGetTotalBalance() {
    //GIVEN the List of Account External Ids & Response Id to call the Total Balance API
    Set<String> accountList = getAccountList();
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String status = '';
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalCustomerBalanceMock()
    );

    Test.startTest();
    //WHEN calling the TotalBalance API
    status = FinancialSummaryController.getTotalBalance(
      responseId,
      accountList,
      FinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET,
      true
    );
    Test.stopTest();

    //THEN the response should be 'Request Received' from Total Balance API
    Assert.areEqual(
      status,
      FinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Total Balance API'
    );
  }

  @isTest
  static void testGetTotalCustomerLimits() {
    //GIVEN the List of Account External Ids & Response Id to call the Total Limit API
    Set<String> accountList = getAccountList();
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String status = '';
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalCustomerBalanceMock()
    );

    Test.startTest();
    //WHEN calling the TotalLimit API
    status = FinancialSummaryController.getTotalLimts(
      responseId,
      accountList,
      FinancialSummaryController.TOTAL_CUSTOMER_LIMIT,
      true
    );
    Test.stopTest();

    //THEN the response should be 'Request Received' from Total Limit API
    Assert.areEqual(
      status,
      FinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Total Balance API'
    );
  }

  @isTest
  static void testGetTotalMortageLending() {
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      AuthTokenCacheUtil.getHashedKey('forgeJWTToken' + '' + 'DCRM_FinSummary'),
      AuthServiceTest.IDTESTVALUE
    );
    String status = '';
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalMortageLendingMock()
    );

    Test.startTest();
    status = FinancialSummaryController.getTotalMortageLending(
      responseId,
      new Set<String>{ '12345678' },
      FinancialSummaryController.TOTAL_MORTAGE_LENDING,
      true
    );
    Test.stopTest();

    //Response should be 'Request Received'
    Assert.areEqual(
      status,
      FinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Total Balance API'
    );
  }

  @isTest
  static void testGetTotalBalanceNegative() {
    //GIVEN the List of Account External Ids Response Id to call the Total Balance API
    String errorMessage = '';
    try {
      Set<String> accountList = getAccountList();
      String responseId = (String) Lib_FakeIdGenerator.getMockId(
        Account.SobjectType
      );
      String status = '';

      Test.startTest();
      //WHEN calling the TotalBalance API
      status = FinancialSummaryController.getTotalBalance(
        responseId,
        accountList,
        FinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET,
        true
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN there should be an error as no mock data is present
    Assert.isTrue(
      errorMessage != null,
      'Total Balance API called without any error'
    );
  }

  @isTest
  static void testGetTotalAssetFinanceBalance() {
    //GIVEN the List of cap Customer Ids List & Response Id
    List<String> capCustomerIds = new List<String>{ '4017192605' };
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String status = '';

    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalAssetFinanceBalanceMock()
    );

    Test.startTest();
    //WHEN calling the Total Asset Finance Balance API
    status = FinancialSummaryController.getTotalAssetFinanceBalance(
      responseId,
      capCustomerIds,
      FinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_TYPE,
      FinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_FIELDSET,
      true
    );
    Test.stopTest();

    //THEN the response should be 'Request Received' from Total Asset Finance Balance API
    Assert.areEqual(
      status,
      FinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Asset Balance API'
    );
  }

  @isTest
  static void testInsertDataInCacheNegative() {
    //GIVEN a session partition of Cache
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String dataInCache = '';
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );

    Test.startTest();
    //WHEN trying to get the data from cache
    dataInCache = (String) sessionPart.get(responseId);
    Test.stopTest();

    //THEN data should not be found in cache as the data not inserted yet
    Assert.areEqual(null, dataInCache, 'Expected null but data found in cache');
  }

  @isTest
  static void testInsertDataInCache() {
    //GIVEN session Partition, expectedData and the platform event (totalBalanceResponse, totalAssetBalanceResponse) value.
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalBalanceAck":"Success","totalBalance":178.01,"totalAssetFinanceBalance":347.01,"lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Success"}';

    FinancialSummaryWrapper.CacheData expectedJSON = (FinancialSummaryWrapper.CacheData) JSON.deserialize(
      expectedData,
      FinancialSummaryWrapper.CacheData.class
    );

    String totalBalanceResponse =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Success","Summary__c":"' +
      '{\\"items\\":[{\\"subType\\":\\"TOTAL_CUSTOMER_BALANCE\\",\\"subTypeValue\\":\\"178.01\\"},' +
      '{\\"subType\\":\\"TOTAL_DEBIT_BALANCE\\",\\"subTypeValue\\":\\"180\\"},' +
      '{\\"subType\\":\\"TOTAL_CREDIT_BALANCE\\",\\"subTypeValue\\":\\"181\\"}]}"}';

    String totalAssetBalanceResponse =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Success","Summary__c":"{\\"items\\":[{\\"subType\\":\\"TOTAL_ASSET_FINANCE_BALANCE\\",\\"subTypeValue\\":\\"347.01\\"}]}"}';

    String dataInCache = '';

    Test.startTest();
    //WHEN trying to insert the data in cache
    FinancialSummaryController.insertDataInCache(totalBalanceResponse);
    FinancialSummaryController.insertDataInCache(totalAssetBalanceResponse);
    Test.stopTest();
    dataInCache = (String) sessionPart.get(responseId);

    FinancialSummaryWrapper.CacheData dataInCacheJSON = (FinancialSummaryWrapper.CacheData) JSON.deserialize(
      dataInCache,
      FinancialSummaryWrapper.CacheData.class
    );

    //THEN the data should be inserted in cache successfully
    Assert.areEqual(
      expectedJSON.totalBalance,
      dataInCacheJSON.totalBalance,
      'Data not found in cache after insertion'
    );
  }

  @isTest
  static void testInsertDataInCacheErrorResponse() {
    //GIVEN session Partition, expectedData and the platform event (totalBalanceResponse, totalAssetBalanceResponse) value.
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMortageLendingValue":null,"totalMortageLendingAck":null,"totalLimitValue":null,"totalLimitAck":null,"totalDebitBalanceAck":"Unexpected error","totalDebitBalance":null,"totalCreditBalanceAck":"Unexpected error","totalCreditBalance":null,"totalBalanceAck":"Unexpected error","totalBalance":null,"totalAssetFinanceBalance":null,"lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Unexpected error"}';

    String totalBalanceResponse =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Error","Error_Description__c":"Api Failed","Summary__c":"' +
      '{\\"items\\":[{\\"subType\\":\\"TOTAL_CUSTOMER_BALANCE\\",\\"subTypeValue\\":\\"0\\"},' +
      '{\\"subType\\":\\"TOTAL_DEBIT_BALANCE\\",\\"subTypeValue\\":\\"0\\"},' +
      '{\\"subType\\":\\"TOTAL_CREDIT_BALANCE\\",\\"subTypeValue\\":\\"0\\"}]}"}';

    String totalAssetBalanceResponse =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Error","Error_Description__c":"Api Failed","Summary__c":"{\\"items\\":[{\\"subType\\":\\"TOTAL_ASSET_FINANCE_BALANCE\\",\\"subTypeValue\\":\\"0\\"}]}"}';

    String dataInCache = '';

    Test.startTest();
    //WHEN trying to insert the data in cache
    FinancialSummaryController.insertDataInCache(totalBalanceResponse);
    FinancialSummaryController.insertDataInCache(totalAssetBalanceResponse);
    Test.stopTest();
    dataInCache = (String) sessionPart.get(responseId);

    //THEN the data should be inserted in cache successfully
    Assert.areEqual(
      expectedData,
      dataInCache,
      'Data not found in cache after insertion'
    );
  }

  @isTest
  static void testGetDataFromCache() {
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );

    String totalBalanceResponse =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Success","Summary__c":"{\\"items\\":[{\\"subType\\":\\"TERMINALS\\",\\"subTypeValue\\":\\"800\\"}]}"}';
    FinancialSummaryResponseWrapper finSumRespFromCache = new FinancialSummaryResponseWrapper();
    FinancialSummaryResponseWrapper expectedData = new FinancialSummaryResponseWrapper();
    expectedData.responseId = responseId;
    expectedData.totalBalance = null;
    expectedData.totalBalanceAck = null;
    expectedData.totalAssetFinanceBalance = null;
    expectedData.assetBalanceAck = null;
    expectedData.cacheAck = FinancialSummaryController.CACHE_ACK;
    expectedData.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');

    getFinSummaryCallout(responseId, false, false, false, false);

    Test.startTest();
    FinancialSummaryController.insertDataInCache(totalBalanceResponse);
    //WHEN there is already data present in cache
    finSumRespFromCache = FinancialSummaryController.getSummariesByResponseId(
      finSummaryCallout
    );
    Test.stopTest();

    //THEN user able to successfully get the data from cache
    Assert.areEqual(
      JSON.serialize(expectedData),
      JSON.serialize(finSumRespFromCache),
      'Not able to get the data from Cache.'
    );
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdNegative() {
    //GIVEN the empty list
    Set<String> accList = new Set<String>();
    Test.startTest();
    //WHEN user trying to fetch the records
    accList = FinancialSummaryController.retrieveFinancialAccountsByCustomerId(
      new List<String>()
    );
    Test.stopTest();

    //THEN no records should be returned as list is empty
    Assert.areEqual(
      0,
      accList.size(),
      'Able to retrieve records the financial account records.'
    );
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdPositive() {
    registerMocks();
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    List<String> accExternalIdList = new List<String>();
    Set<String> retrievedAccountSet = new Set<String>();

    //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.ANZx_Customer__c = false;
    primaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.ANZx_Customer__c = false;
    secondaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(secondaryAccRec);

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      false
    );
    finAccountRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      false
    );
    finAccountRoleRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SobjectType
    );
    accExternalIdList.add(primaryAccRec.External_Id__c);

    finAccountRoleRecord.FinServ__FinancialAccount__r = finAccountRecord;
    finAccountRoleRecord.FinServ__RelatedAccount__r = primaryAccRec;
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ finAccountRoleRecord }
    );

    Test.startTest();
    //WHEN trying to get the FinancialAccounts records
    retrievedAccountSet = FinancialSummaryController.retrieveFinancialAccountsByCustomerId(
      accExternalIdList
    );
    Test.stopTest();

    //THEN user should be able to get the record
    Assert.areEqual(
      1,
      retrievedAccountSet.size(),
      'Not Able to retrieve the financial account records by customer Ids.'
    );
  }

  @isTest
  static void testGetCLGRelatedCustomerIds() {
    registerMocks();
    String userId = (String) Lib_FakeIdGenerator.getMockId(User.SobjectType);
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    FinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new FinancialSummaryWrapper.CustomerIdWrapper();

    //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.OwnerId = userId;
    primaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.OwnerId = userId;
    secondaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(secondaryAccRec);

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      false
    );
    finAccountRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      false
    );
    finAccountRoleRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SobjectType
    );

    fsRepoMock.mock('getAccountById', primaryAccRec);

    fsRepoMock.mock(
      'getActiveClgAccAccRelations',
      new List<FinServ__FinancialAccountRole__c>{ finAccountRoleRecord }
    );

    Test.startTest();
    //WHEN trying to get the CLG Related Customer Ids records
    custIdWrapper = FinancialSummaryController.getCLGRelatedCustomerIds(
      primaryAccRec.Id
    );
    Test.stopTest();

    //THEN user should be able to get 1 record
    Assert.areEqual(
      1,
      custIdWrapper.capIdsList.size(),
      'CAP customer Id not found'
    );
  }

  @isTest
  static void testGetNonCLGRelatedCustomerIds() {
    String userId = (String) Lib_FakeIdGenerator.getMockId(User.SobjectType);
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    FinancialSummaryWrapper.CustomerIdWrapper custIdWrapper = new FinancialSummaryWrapper.CustomerIdWrapper();
    String errorMessage = '';

    //GIVEN Primary & Secondary Account Record, FinServ__FinancialAccount__c & FinServ__FinancialAccountRole__c record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.OwnerId = userId;
    primaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.RecordTypeId = CCRMConstants.ACCOUNT_CLG_RT_ID;
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.OwnerId = userId;
    secondaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(secondaryAccRec);

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      false
    );
    finAccountRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      false
    );
    finAccountRoleRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SobjectType
    );

    Test.startTest();
    try {
      //WHEN trying to get the CLG Related Customer Ids records
      custIdWrapper = FinancialSummaryController.getCLGRelatedCustomerIds(
        primaryAccRec.Id
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN user should get an exception
    Assert.isTrue(
      errorMessage != null,
      'Able to access all the field included in query'
    );
  }

  @isTest
  static void testGetDataFromCallout() {
    registerMocks();
    Account primaryAccRec = new Account();
    Account secondaryAccRec = new Account();
    List<Account> accToInsertList = new List<Account>();
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c();
    FinancialSummaryResponseWrapper expectedData;
    FinancialSummaryResponseWrapper responseData = new FinancialSummaryResponseWrapper();

    //GIVEN account List, finAccountRecord, finAccountRoleRecord, callout and expectedData record
    primaryAccRec = TestDataFactory.createAccount(false);
    primaryAccRec.Source_System_ID__c = '901221245';
    primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
    primaryAccRec.ANZx_Customer__c = false;
    primaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(primaryAccRec);

    secondaryAccRec = TestDataFactory.createAccount(false);
    secondaryAccRec.Source_System_ID__c = '45678990657';
    secondaryAccRec.External_Id__c = '';
    secondaryAccRec.ANZx_Customer__c = false;
    secondaryAccRec.Id = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    accToInsertList.add(secondaryAccRec);

    finAccountRecord = CCRMTestDataFactory.createFinancialAccount(
      primaryAccRec.Id,
      secondaryAccRec.Id,
      false
    );
    finAccountRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    finAccountRoleRecord = CCRMTestDataFactory.createFinancialAccountRole(
      primaryAccRec.Id,
      finAccountRecord.Id,
      false
    );
    finAccountRecord.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );

    getFinSummaryCallout(primaryAccRec.Id, true, true, true, false);

    expectedData = new FinancialSummaryResponseWrapper();
    expectedData.responseId = primaryAccRec.Id;
    expectedData.totalBalance = null;
    expectedData.totalBalanceAck = FinancialSummaryController.MULE_RESPONSE;
    expectedData.totalDebitBalanceAck = FinancialSummaryController.MULE_RESPONSE;
    expectedData.totalCreditBalanceAck = FinancialSummaryController.MULE_RESPONSE;
    expectedData.totalAssetFinanceBalance = null;
    expectedData.assetBalanceAck = FinancialSummaryController.MULE_RESPONSE;
    expectedData.cacheAck = null;
    expectedData.totalLimitValue = null;
    expectedData.totalLimitAck = FinancialSummaryController.MULE_RESPONSE;

    fsRepoMock.mock('getAccountById', primaryAccRec);
    fsRepoMock.mock(
      'getActiveClgAccAccRelations',
      new List<FinServ__FinancialAccountRole__c>{ finAccountRoleRecord }
    );

    finAccountRoleRecord.FinServ__FinancialAccount__r = finAccountRecord;
    finAccountRoleRecord.FinServ__RelatedAccount__r = primaryAccRec;
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ finAccountRoleRecord }
    );

    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalCustomerBalanceMock()
    );
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalTerminalsMock()
    );
    Test.setMock(
      HttpCalloutMock.class,
      new FinancialSummaryServiceMock.GetTotalAssetFinanceBalanceMock()
    );

    Test.startTest();
    //WHEN data is not found in cache so making a callout to the APIs
    responseData = FinancialSummaryController.getSummariesByResponseId(
      finSummaryCallout
    );
    Test.stopTest();

    //THEN it will successfully able to make the API callout and return the response
    Assert.areEqual(
      JSON.serialize(expectedData),
      JSON.serialize(responseData),
      'Errored out while calling the APIs'
    );
  }

  @isTest
  static void testPopulateDataInCache() {
    //GIVEN finSumResponse, sessionPart, expectedData record
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    FinancialSummaryResponseWrapper finSumResponse = new FinancialSummaryResponseWrapper();
    finSumResponse.responseId = responseId;
    finSumResponse.totalBalanceAck = FinancialSummaryController.MULE_RESPONSE;
    finSumResponse.assetBalanceAck = FinancialSummaryController.MULE_RESPONSE;

    Cache.SessionPartition sessionPart = Cache.Session.getPartition(
      'local.DataPartition'
    );
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMortageLendingValue":null,"totalMortageLendingAck":null,"totalLimitValue":null,"totalLimitAck":null,"totalDebitBalanceAck":null,"totalDebitBalance":null,"totalCreditBalanceAck":null,"totalCreditBalance":null,"totalBalanceAck":"Request Received","totalBalance":null,"totalAssetFinanceBalance":null,"lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Request Received"}';

    String cacheData = '';

    Test.startTest();
    //WHEN trying to populate the data in cache
    FinancialSummaryController.populateDataInCache(finSumResponse);
    cacheData = (String) sessionPart.get(responseId);
    Test.stopTest();

    //THEN the data should be successfully inserted/populated in cache
    Assert.areEqual(expectedData, cacheData, 'Data not populated in cache');
  }

  @isTest
  static void prepareResponseMapTest() {
    String responseId = (String) Lib_FakeIdGenerator.getMockId(
      Account.SobjectType
    );
    String response =
      '{"Response_Id__c":"' +
      responseId +
      '","Status__c":"Success","Summary__c":"' +
      '{\\"items\\":[{\\"subType\\":\\"TOTAL_CUSTOMER_BALANCE\\",\\"subTypeValue\\":\\"100\\"},' +
      '{\\"subType\\":\\"TOTAL_DEBIT_BALANCE\\",\\"subTypeValue\\":\\"200\\"},' +
      '{\\"subType\\":\\"TOTAL_CREDIT_BALANCE\\",\\"subTypeValue\\":\\"300\\"},' +
      '{\\"subType\\":\\"TERMINALS\\",\\"subTypeValue\\":\\"400\\"},' +
      '{\\"subType\\":\\"TOTAL_ASSET_FINANCE_BALANCE\\",\\"subTypeValue\\":\\"500\\"}' +
      ']}"}';

    Map<String, Object> responseMap = FinancialSummaryController.prepareResponseMap(
      response
    );
    Assert.areEqual(
      'Success',
      (string) responseMap.get('Status__c'),
      'prepareResponseMap is not returning correct status'
    );
    Assert.areEqual(
      responseId,
      (string) responseMap.get('Response_Id__c'),
      'prepareResponseMap is not returning correct ResponseId'
    );
  }

  @isTest
  static void prepareSummaryMapTest() {
    String response = '{"Status__c":"Success","Summary__c":"{\\"items\\":[{\\"subType\\":\\"TERMINALS\\",\\"subTypeValue\\":\\"3\\"}]}"}';
    Map<String, Object> responseMap = FinancialSummaryController.prepareSummaryMap(
      (string) ((Map<String, Object>) JSON.deserializeUntyped(response))
        .get('Summary__c')
    );
    Assert.areEqual(
      3,
      Decimal.valueOf((string) responseMap.get('TERMINALS')),
      'prepareSummaryMapTest is showing correct output'
    );
  }

  @isTest
  static void testGetFinSummaryMetadata() {
    registerMocks();
    List<Financial_Summary_Setting__mdt> metadataRecords = new List<Financial_Summary_Setting__mdt>();
    metadataRecords.add(
      new Financial_Summary_Setting__mdt(
        Active__c = true,
        Summary_Name__c = 'Total Customer Balance',
        User_Profile__c = 'ANZ ML Standard User; ANZ CCRM Standard User'
      )
    );
    metadataRecords.add(
      new Financial_Summary_Setting__mdt(
        Active__c = true,
        Summary_Name__c = 'Total Debit Balance',
        User_Profile__c = 'ANZ ML Standard User'
      )
    );
    fsRepoMock.mock('getFinSummaryMetadata', metadataRecords);
    Test.startTest();
    FinancialSummaryController.wrapFinancialSummary mockedRecords = FinancialSummaryController.getFinSummaryMetadata();
    Assert.areEqual(
      2,
      mockedRecords.lstOfSymmarySetting.size(),
      'getFinSummaryMetadata is not Returning correct list'
    );
    Test.stopTest();
  }

  @isTest
  static void testRemoveEncryptedPca() {
    Set<String> setOfAccountNumbers = new Set<String>{
      'DDA-12345',
      'ILS-6789',
      'PCA-abcd123',
      'PCA-4567'
    };
    Set<String> filteredAccountNumbers = FinancialSummaryController.removeEncryptedPca(
      setOfAccountNumbers
    );
    Assert.isTrue(
      filteredAccountNumbers.size() == setOfAccountNumbers.size() - 1,
      'removeEncryptedPca is not removing encrypted pca'
    );
    Assert.isFalse(
      filteredAccountNumbers.contains('PCA-abcd123'),
      'removeEncryptedPca is removing wrong number'
    );
  }

  @isTest
  static void getFinancialSummaryDetailsTest() {
    HttpCalloutResponse resSuccess = new HttpCalloutResponse();
    resSuccess.successful = true;
    resSuccess.statusCode = 200;
    resSuccess.body = '{"status": "SUCCESS"}';

    HttpCalloutResponse resException = new HttpCalloutResponse();
    resException.successful = true;
    resException.statusCode = 200;
    resException.body = 'Success';
    Test.startTest();
    String statusSuccess = FinancialSummaryController.getFinancialSummaryDetails(
      resSuccess
    );
    String statusException = FinancialSummaryController.getFinancialSummaryDetails(
      resException
    );
    Test.stopTest();
    Assert.areEqual('SUCCESS', statusSuccess, 'Expected status to be SUCCESS');
    Assert.areEqual(
      'Unexpected error',
      statusException,
      'Expected status to be Unexpected Error'
    );
  }
}
