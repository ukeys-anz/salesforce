/**
 * @author Naman Garg
 * @since Sept 2023
 * @description unit testing class for CCRMFinancialSummaryController class
 * @group Service
 */
@isTest
private class CCRMFinancialSummaryTest {
  @testSetup
  static void createTestData() {
    User ccrmBaseUser;
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
      TestUtil.assignPermissionSets(
        new List<String>{ 'MLCRM_Base' },
        new List<User>{ ccrmBaseUser }
      );
    }

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      List<Account> accToInsertList = new List<Account>();
      Account primaryAccRec = TestDataFactory.createAccount(false);
      primaryAccRec.Source_System_ID__c = '901221245';
      primaryAccRec.External_Id__c = 'CAP-CIS_4017192605';
      primaryAccRec.OwnerId = ccrmBaseUser.Id;
      accToInsertList.add(primaryAccRec);

      Account secondaryAccRec = TestDataFactory.createAccount(false);
      secondaryAccRec.Source_System_ID__c = '45678990657';
      secondaryAccRec.External_Id__c = '';
      secondaryAccRec.OwnerId = ccrmBaseUser.Id;
      accToInsertList.add(secondaryAccRec);
      insert accToInsertList;

      FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c(
        RecordTypeId = CCRMConstants.FA_RT_ID,
        Product_Type__c = 'CAP-CIS:DDA',
        FinServ__PrimaryOwner__c = primaryAccRec.Id,
        FinServ__JointOwner__c = secondaryAccRec.Id,
        OwnerId = ccrmBaseUser.Id
      );
      insert finAccountRecord;

      FinServ__FinancialAccountRole__c finAccountRoleRecord = new FinServ__FinancialAccountRole__c(
        FinServ__RelatedAccount__c = primaryAccRec.Id,
        FinServ__Active__c = true,
        FinServ__FinancialAccount__c = finAccountRecord.Id,
        Role_Type__c = 'BCC',
        RecordTypeId = CCRMConstants.FAR_RT_ID
      );
      insert finAccountRoleRecord;
    }
  }

  @isTest
  static void testGetTotalBalance() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.GetTotalCustomerBalanceMock()
    );

    List<String> accountList = new List<String>{
      'DDA-901221265',
      'ILS-397519424',
      'FM-251500720'
    };
    String responseId = '0019h000009g1TxAAI';
    String status = CCRMFinancialSummaryController.getTotalBalance(
      responseId,
      accountList,
      CCRMFinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET
    );
    Test.stopTest();
    system.assertEquals(
      status,
      CCRMFinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Total Balance API'
    );
  }

  @isTest
  static void testGetTotalBalanceNegative() {
    String errorMessage = '';
    Test.startTest();
    try {
      List<String> accountList = new List<String>{
        'DDA-901221265',
        'ILS-397519424',
        'FM-251500720'
      };
      String responseId = '0019h000009g1TxAAI';
      String status = CCRMFinancialSummaryController.getTotalBalance(
        responseId,
        accountList,
        CCRMFinancialSummaryController.TOTAL_CUSTOMER_BALANCE_FIELDSET
      );
    } catch (Exception e) {
      errorMessage = e.getMessage();
    }
    Test.stopTest();
    System.assert(
      errorMessage != null,
      'Total Balance API called without any error'
    );
  }

  @isTest
  static void testGetTotalTerminals() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.GetTotalTerminalsMock()
    );

    List<String> capCustomerIds = new List<String>{ '4017192605' };
    String responseId = '0019h000009g1TxAAI';
    String status = CCRMFinancialSummaryController.getTotalMerchantTerminals(
      responseId,
      capCustomerIds,
      CCRMFinancialSummaryController.TERMINALS_FIELDSET
    );
    Test.stopTest();
    system.assertEquals(
      status,
      CCRMFinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Terminal API'
    );
  }

  @isTest
  static void testGetTotalAssetFinanceBalance() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTestDataFactory.GetTotalAssetFinanceBalanceMock()
    );

    List<String> capCustomerIds = new List<String>{ '4017192605' };
    String responseId = '0019h000009g1TxAAI';
    String status = CCRMFinancialSummaryController.getTotalAssetFinanceBalance(
      responseId,
      capCustomerIds,
      CCRMFinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_TYPE,
      CCRMFinancialSummaryController.TOTAL_ASSET_FINANCE_BALANCE_FIELDSET
    );
    Test.stopTest();
    system.assertEquals(
      status,
      CCRMFinancialSummaryController.MULE_RESPONSE,
      'Errored out while calling the Asset Balance API'
    );
  }

  @isTest
  static void testInsertDataInCache() {
    String currentDateTime = DateTime.now().format('dd/MM/yyyy hh:mm a');
    String expectedData =
      '{"totalMerchantTerminals":3,"totalBalanceAck":"Request Received","totalBalance":178.01,"totalAssetFinanceBalance":347.01,"terminalAck":"Request Received","lastSummaryUpdateDate":"' +
      currentDateTime +
      '","assetBalanceAck":"Request Received"}';
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );

      String dataInCache = (String) sessionPart.get('0019h000009g1TxAAI');
      System.assertEquals(
        null,
        dataInCache,
        'Expected null but data found in cache'
      );

      String totalBalanceResponse = '{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","Response_Id__c":"0019h000009g1TxAAI","Summary__c":178.01}';
      String terminalResponse = '{"Summary_Type__c":"TERMINALS","Response_Id__c":"0019h000009g1TxAAI","Summary__c":3}';
      String totalAssetBalanceResponse = '{"Summary_Type__c":"TOTAL_ASSET_FINANCE_BALANCE","Response_Id__c":"0019h000009g1TxAAI","Summary__c":347.01}';

      Test.startTest();
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      CCRMFinancialSummaryController.insertDataInCache(terminalResponse);
      CCRMFinancialSummaryController.insertDataInCache(
        totalAssetBalanceResponse
      );
      Test.stopTest();
      dataInCache = (String) sessionPart.get('0019h000009g1TxAAI');
      System.assertEquals(
        expectedData,
        dataInCache,
        'Data not found in cache after insertion'
      );
    }
  }

  @isTest
  static void testGetDataFromCache() {
    CCRMFinancialSummaryWrapper.FinSummaryResponse expectedData = new CCRMFinancialSummaryWrapper.FinSummaryResponse();
    expectedData.responseId = '0019h000009g1TxAAI';
    expectedData.totalBalance = 178.01;
    expectedData.totalBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    expectedData.totalMerchantTerminals = null;
    expectedData.terminalAck = CCRMConstants.NO_AVAILABLE_BALANCE;
    expectedData.totalAssetFinanceBalance = null;
    expectedData.assetBalanceAck = CCRMConstants.NO_AVAILABLE_BALANCE;
    expectedData.cacheAck = CCRMFinancialSummaryController.CACHE_ACK;
    expectedData.lastSummaryUpdateDate = DateTime.now()
      .format('dd/MM/yyyy hh:mm a');

    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Cache.SessionPartition sessionPart = Cache.Session.getPartition(
        'local.DataPartition'
      );
      CCRMFinancialSummaryWrapper.FinSummaryCallout finSumCallout = new CCRMFinancialSummaryWrapper.FinSummaryCallout();
      finSumCallout.responseId = '0019h000009g1TxAAI';
      finSumCallout.callTotalCustBalanceApi = false;
      finSumCallout.callTerminalApi = false;
      finSumCallout.callAssetFinanceBalanceApi = false;
      String totalBalanceResponse = '{"Summary_Type__c":"TOTAL_CUSTOMER_BALANCE","Response_Id__c":"0019h000009g1TxAAI","Summary__c":178.01}';
      Test.startTest();
      CCRMFinancialSummaryController.insertDataInCache(totalBalanceResponse);
      CCRMFinancialSummaryWrapper.FinSummaryResponse finSumRespFromCache = CCRMFinancialSummaryController.getDataFromCache(
        sessionPart,
        finSumCallout
      );
      Test.stopTest();
      System.assertEquals(
        JSON.serialize(expectedData),
        JSON.serialize(finSumRespFromCache),
        'Not able to get the data from Cache.'
      );
    }
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdNegative() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    List<String> accList = new List<String>();
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      accList = CCRMFinancialSummaryController.retrieveFinancialAccountsByCustomerId(
        new List<String>()
      );
      Test.stopTest();
      System.assertEquals(
        0,
        accList.size(),
        'Able to retrieve records the financial account records.'
      );
    }
  }

  @isTest
  static void testRetrieveFinancialAccountsByCustomerIdPositive() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    Account accRec = [
      SELECT Id, External_Id__c
      FROM Account
      WHERE External_Id__c = 'CAP-CIS_4017192605'
      LIMIT 1
    ];
    List<String> accList = new List<String>{ accRec.External_Id__c };
    List<String> accRetrievedList = new List<String>();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Test.startTest();
      accRetrievedList = CCRMFinancialSummaryController.retrieveFinancialAccountsByCustomerId(
        accList
      );
      Test.stopTest();
      System.assertEquals(
        1,
        accRetrievedList.size(),
        'Not Able to retrieve the financial account records by customer Ids.'
      );
    }
  }

  @isTest
  static void testGetCLGRelatedCustomerIds() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    Account accRec = [
      SELECT Id, External_Id__c
      FROM Account
      WHERE External_Id__c = 'CAP-CIS_4017192605'
      LIMIT 1
    ];
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      List<String> capCustomerIdsList = CCRMFinancialSummaryController.getCLGRelatedCustomerIds(
        accRec.Id
      );
      Test.stopTest();
      System.assertEquals(
        1,
        capCustomerIdsList.size(),
        'CAP customer Id not found'
      );
    }
  }

  @isTest
  static void testGetDataFromCallout() {
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
    Account accRec = [
      SELECT Id, External_Id__c
      FROM Account
      WHERE External_Id__c = 'CAP-CIS_4017192605'
      LIMIT 1
    ];
    CCRMFinancialSummaryWrapper.FinSummaryCallout calloutData = new CCRMFinancialSummaryWrapper.FinSummaryCallout();
    calloutData.responseId = accRec.Id;
    calloutData.callTotalCustBalanceApi = true;
    calloutData.callTerminalApi = true;
    calloutData.callAssetFinanceBalanceApi = true;

    CCRMFinancialSummaryWrapper.FinSummaryResponse expectedData = new CCRMFinancialSummaryWrapper.FinSummaryResponse();
    expectedData.responseId = accRec.Id;
    expectedData.totalBalance = null;
    expectedData.totalBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    expectedData.totalMerchantTerminals = null;
    expectedData.terminalAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    expectedData.totalAssetFinanceBalance = null;
    expectedData.assetBalanceAck = CCRMFinancialSummaryController.MULE_RESPONSE;
    expectedData.cacheAck = null;
    expectedData.lastSummaryUpdateDate = null;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      Test.startTest();
      CCRMFinancialSummaryWrapper.FinSummaryResponse responseData = CCRMFinancialSummaryController.getSummariesByResponseId(
        calloutData
      );
      Test.stopTest();
      System.assertEquals(
        JSON.serialize(expectedData),
        JSON.serialize(responseData),
        'Errored out while calling the APIs'
      );
    }
  }
}
