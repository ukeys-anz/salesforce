/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Deposit Account external query test class
 */
@isTest
private class CCRMDepositAccountQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
            Account.SobjectType
          ),
          Account_Key__c = '4011643101-3424909811',
          FinServ__FinancialAccountNumber__c = '3424909811',
          Product_Type__c = 'CAP-CIS:DDA'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '3424-909811' }
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "accountName": "Denis Lai",' +
      '       "accountNumber": "3424909811",' +
      '       "productCode": "DDA",' +
      '       "accountBalance": "50.01",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    depositAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(depositAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateFinancialAccounts() {
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    depositAcct.execute(context);
    depositAcct.calloutResponse = new CCRMDepositAccountQuery.DepositAccountCalloutResponse();
    ((CCRMDepositAccountQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts = new List<CCRMDepositAccountQuery.CCRMDepositAccountModel>();
    CCRMDepositAccountQuery.CCRMDepositAccountModel depositModel = new CCRMDepositAccountQuery.CCRMDepositAccountModel();
    depositModel.accountName = 'Denis Lai';
    depositModel.accountNumber = '3424909811';
    ((CCRMDepositAccountQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts.add(depositModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
  }

  @isTest
  static void createDepositAccountsTest() {
    registerMocks();
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Map<String, Object> firstRecord = result.queryResult[0];
    Assert.areEqual(
      'Denis Lai',
      firstRecord.get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '3424-909811',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }
  @isTest
  static void getProductCodeTest() {
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    depositAcct.execute(context);
    CCRMDepositAccountQuery.CCRMDepositAccountModel accountModel = new CCRMDepositAccountQuery.CCRMDepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String productCode = depositAcct.getProductCode(accountModel);
    Test.stopTest();
    Assert.areEqual('DDA', productCode, 'Product code mismatch');
  }
  @isTest
  static void getExternalIdTest() {
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    depositAcct.execute(context);
    CCRMDepositAccountQuery.CCRMDepositAccountModel accountModel = new CCRMDepositAccountQuery.CCRMDepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String externalId = depositAcct.getExternalId(accountModel);
    Test.stopTest();
    Assert.isFalse(
      externalId.contains('ILS-3424909811'),
      'external id mismatch'
    );
  }

  @isTest
  static void getAccountKeyTest() {
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createDepositAccountContext();
    CCRMDepositAccountQuery depositAcct = new CCRMDepositAccountQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    depositAcct.execute(context);
    String accountKey = depositAcct.getAccountKey('3424909811', 'DDA');
    Test.stopTest();
    Assert.areEqual(
      '4011643101-3424909811|DDA-3424909811',
      accountKey,
      'account Key mismatch'
    );
  }

  @isTest
  static void testPopulateSeasonalLimits() {
    Map<String, Object> row = new Map<String, Object>();
    List<CCRMDepositAccountQuery.SeasonalLimits> seasonalLimitsList = new List<CCRMDepositAccountQuery.SeasonalLimits>();
    CCRMDepositAccountQuery.SeasonalLimits seasonalLimit1 = new CCRMDepositAccountQuery.SeasonalLimits();
    seasonalLimit1.seasonalLimit = 0.0;
    seasonalLimit1.startDate = DateTime.newInstance(2014, 5, 26, 0, 0, 0);
    seasonalLimit1.endDate = DateTime.newInstance(2099, 5, 26, 0, 0, 0);
    seasonalLimitsList.add(seasonalLimit1);

    CCRMDepositAccountQuery.SeasonalLimits seasonalLimit2 = new CCRMDepositAccountQuery.SeasonalLimits();
    seasonalLimit2.seasonalLimit = 0.0;
    seasonalLimit2.startDate = DateTime.newInstance(2015, 5, 26, 0, 0, 0);
    seasonalLimit2.endDate = DateTime.newInstance(2099, 5, 26, 0, 0, 0);
    seasonalLimitsList.add(seasonalLimit2);

    CCRMDepositAccountQuery.SeasonalLimits seasonalLimit3 = new CCRMDepositAccountQuery.SeasonalLimits();
    seasonalLimit3.seasonalLimit = 0.0;
    seasonalLimit3.startDate = null;
    seasonalLimitsList.add(seasonalLimit3);

    Test.startTest();
    CCRMDepositAccountQuery depositQuery = new CCRMDepositAccountQuery();
    depositQuery.populateSeasonalLimits(row, seasonalLimitsList);
    Test.stopTest();
    Assert.areEqual(5, row.size(), 'Not able to populate seasonal Limits');
  }

  @isTest
  static void createDummyFinancialAccountsTest() {
    CCRMDepositAccountQuery depositAccQry = new CCRMDepositAccountQuery();
    system.assertEquals(
      'No further information available',
      depositAccQry.createDummyFinancialAccounts('112233', '111269467')
        .queryResult.get(0)
        .get('AccountName'),
      'createDummyFinancialAccounts is not returning correct result'
    );
  }

  @isTest
  static void displayDummyRecord() {
    String payloadFM = '{"accountNumber": "FM-111269467"}';
    String payloadDDA = '{"accountNumber": "DDA-111269467"}';
    String payloadRSV = '{"accountNumber": "RSV-111269467"}';
    system.assertEquals(
      true,
      CCRMDepositAccountQuery.displayDummyRecord(payloadFM),
      'displayDummyRecord is not returning correct result for FM'
    );
    system.assertEquals(
      false,
      CCRMDepositAccountQuery.displayDummyRecord(payloadDDA),
      'displayDummyRecord is not returning correct result for DDA'
    );
    system.assertEquals(
      true,
      CCRMDepositAccountQuery.displayDummyRecord(payloadRSV),
      'displayDummyRecord is not returning correct result for RSV'
    );
  }

  @isTest
  static void isDepositProductCategoryTest() {
    system.assertEquals(
      true,
      CCRMDepositAccountQuery.isDepositProductCategory('Deposit'),
      'isDepositProductCategory is not returning correct result for Deposit Account'
    );
    system.assertEquals(
      false,
      CCRMDepositAccountQuery.isDepositProductCategory('Loan'),
      'isDepositProductCategory is not returning correct result for non Deposit Account'
    );
  }

  @isTest
  static void extractAccNumberFromPayloadTest() {
    system.assertEquals(
      '111269467',
      CCRMDepositAccountQuery.extractAccNumberFromPayload(
        '{"accountNumber": "FM-111269467"}'
      ),
      'extractAccNumberFromPayload is not returning correct result'
    );
  }
}
