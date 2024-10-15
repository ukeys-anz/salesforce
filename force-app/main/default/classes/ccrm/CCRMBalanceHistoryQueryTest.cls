/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMBalanceHistoryQuery
 */
@isTest
private class CCRMBalanceHistoryQueryTest {
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
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
          Account.SobjectType
        ),
        Account_Key__c = '4011643101-7234567890121234',
        FinServ__FinancialAccountNumber__c = '7234567890121234',
        Product_Type__c = 'CAP-CIS:PCA'
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
      '   "balanceHistory": [' +
      '     {' +
      '       "compositeBalanceHistoryId": "Denis Lai",' +
      '       "month": "August",' +
      '       "year": "2023",' +
      '       "avgBalance": "905.57",' +
      '       "minBalance": "905.57",' +
      '       "maxBalance": "905.57"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMBalanceHistoryQuery balanceHistoryAcct = new CCRMBalanceHistoryQuery();
    balanceHistoryAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      balanceHistoryAcct.calloutResponse == null,
      'Response is not null for Balance history.'
    );
  }

  @isTest
  static void testCreateFinancialAccounts() {
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createBalanceHistoryContext();
    CCRMBalanceHistoryQuery balanceHistoryAcct = new CCRMBalanceHistoryQuery();
    balanceHistoryAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    balanceHistoryAcct.execute(context);
    balanceHistoryAcct.calloutResponse = new CCRMBalanceHistoryQuery.BalanceHistoryCalloutResponse();
    ((CCRMBalanceHistoryQuery.BalanceHistoryCalloutResponse) balanceHistoryAcct.calloutResponse)
      .balanceHistory = new List<CCRMBalanceHistoryQuery.BalanceHistoryModel>();
    CCRMBalanceHistoryQuery.BalanceHistoryModel balanceHistoryModel = new CCRMBalanceHistoryQuery.BalanceHistoryModel();
    balanceHistoryModel.compositeBalanceHistoryId = 'Denis Lai';
    balanceHistoryModel.month = 'August';
    ((CCRMBalanceHistoryQuery.BalanceHistoryCalloutResponse) balanceHistoryAcct.calloutResponse)
      .balanceHistory.add(balanceHistoryModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = balanceHistoryAcct.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
  }

  @isTest
  static void testBalanceHistoryQuery() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createBalanceHistoryContext();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMBalanceHistoryQuery balHistoryQry = new CCRMBalanceHistoryQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = balHistoryQry.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      result.queryResult.size(),
      2,
      'Size of accounts is not 2'
    );
    Map<String, Object> firstRecord = result.queryResult[0];
    System.assertEquals(firstRecord.get('Month'), 'August', 'Month mismatch');
    System.assertEquals(firstRecord.get('Year'), '2023', 'Year mismatch');
  }

  @isTest
  static void getPayloadForCAPChildAccountsTest() {
    String result;
    CCRMBalanceHistoryQuery balHistoryQuery = new CCRMBalanceHistoryQuery();
    balHistoryQuery.parentId = 'CAP-CIS_107130129985-234500817|DDA-234500817';
    Test.startTest();
    result = balHistoryQuery.getPayloadForCAPChildAccounts('');
    Test.stopTest();
    Assert.areEqual(
      '{"accountNumber": "DDA-234500817","pageSize":"null","offSet":"null","fieldSet": "BALANCE_HISTORY"}',
      result,
      'Payload is empty'
    );
  }

  @isTest
  static void createDummyFinancialAccountsTest() {
    system.assertEquals(
      0,
      CCRMBalanceHistoryQuery.createDummyFinancialAccounts('112233')
        .queryResult.size(),
      'createDummyFinancialAccounts is not returning correct result'
    );
  }

  @isTest
  static void testDisplayDummyRecord() {
    String payloadFM = '{"accountNumber": "FM-111269467"}';
    String payloadDDA = '{"accountNumber": "DDA-111269467"}';
    String payloadRSV = '{"accountNumber": "RSV-111269467"}';
    system.assertEquals(
      true,
      CCRMBalanceHistoryQuery.displayDummyRecord(payloadFM),
      'displayDummyRecord is not returning correct result for FM'
    );
    system.assertEquals(
      false,
      CCRMBalanceHistoryQuery.displayDummyRecord(payloadDDA),
      'displayDummyRecord is not returning correct result for DDA'
    );
    system.assertEquals(
      true,
      CCRMBalanceHistoryQuery.displayDummyRecord(payloadRSV),
      'displayDummyRecord is not returning correct result for RSV'
    );
  }

  @isTest
  static void isDepositProductCategoryTest() {
    system.assertEquals(
      true,
      CCRMBalanceHistoryQuery.isDepositProductCategory('Deposit'),
      'isDepositProductCategory is not returning correct result for Deposit Account'
    );
    system.assertEquals(
      false,
      CCRMBalanceHistoryQuery.isDepositProductCategory('Loan'),
      'isDepositProductCategory is not returning correct result for non Deposit Account'
    );
  }

  @isTest
  static void displayDummyAccountDetailsTest() {
    system.assertEquals(
      true,
      CCRMBalanceHistoryQuery.displayDummyAccountDetails('dummyVal', ''),
      'displayDummayFinancialAccount is not returning correct result when parentId is empty'
    );
    system.assertEquals(
      false,
      CCRMBalanceHistoryQuery.displayDummyAccountDetails('', 'dummyVal'),
      'isDepositProductCategory is not returning correct result when externalId is empty'
    );
  }

  @isTest
  static void createDummyFinancialAccountDetailTest() {
    CCRMBalanceHistoryQuery accQuery = new CCRMBalanceHistoryQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult dummyAcc = accQuery.createDummyFinancialAccountDetail(
      'DDA-210568745-2'
    );

    system.assertEquals(
      'No further information available',
      dummyAcc.queryResult.get(0).get('AdditionalInformation'),
      'createDummyFinancialAccounts is not returning correct result'
    );
    system.assertEquals(
      'DDA-210568745-2',
      dummyAcc.queryResult.get(0).get('ExternalId'),
      'createDummyFinancialAccounts is not returning correct result'
    );
  }
}
