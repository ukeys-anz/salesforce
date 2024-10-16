/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Term Deposit external query test class
 */
@isTest
private class CCRMTermDepositQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id finAccountId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SobjectType
    );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccount__c mockFinAccount = (FinServ__FinancialAccount__c) TestUtil.setFields(
      new FinServ__FinancialAccount__c(
        Id = finAccountId,
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-403456789',
        FinServ__FinancialAccountNumber__c = '403456789',
        Product_Type__c = 'CAP-CIS:CDA',
        Source_System_Status_Display__c = 'Open'
      ),
      new Map<String, Object>{
        'Product_Code_Display__c' => 'DDA',
        'Product_Name_Display__c' => 'Monthly Interest Account',
        'Account_Number__c' => '4034-56789'
      }
    );
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = mockFinAccount,
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
      '       "accountNumber": "403456789",' +
      '       "productCode": "CDA",' +
      '       "accountBalance": "50.01",' +
      '       "accountLimit": "1000",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateFinancialAccounts() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    query.calloutResponse = new CCRMTermDepositQuery.TermAccountCalloutResponse();
    ((CCRMTermDepositQuery.TermAccountCalloutResponse) query.calloutResponse)
      .accounts = new List<CCRMTermDepositQuery.CCRMTermDepositModel>();
    CCRMTermDepositQuery.CCRMTermDepositModel termModel = new CCRMTermDepositQuery.CCRMTermDepositModel();
    termModel.accountName = 'Denis Lai';
    termModel.accountNumber = '403456789';
    ((CCRMTermDepositQuery.TermAccountCalloutResponse) query.calloutResponse)
      .accounts.add(termModel);
    CCRMExternalObjectQueryBase.ExternalQueryResult result = query.createFinancialAccounts();
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
  }

  @isTest
  static void createTermDepositAccountsTest() {
    registerMocks();
    Test.startTest();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = query.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.queryResult.size(), 'Size of accounts is not 1');
    Assert.areEqual(
      'Denis Lai',
      result.queryResult[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '4034-56789',
      result.queryResult[0].get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  @isTest
  static void getProductCodeTest() {
    registerMocks();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    Test.startTest();
    string prodCode = query.getProductCode('403456789');
    Test.stopTest();
    Assert.areEqual('DDA', prodCode, 'Product code matches');
  }

  @isTest
  static void getProductNameTest() {
    registerMocks();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    Test.startTest();
    string productName = query.getProductName(
      mockFar.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
    );
    Test.stopTest();
    Assert.areEqual(
      'Monthly Interest Account',
      productName,
      'Product Name Matched'
    );
  }

  @isTest
  static void getSourceSystemStatusTest() {
    registerMocks();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    Test.startTest();
    String sourcestatus = query.getSourceSystemStatus(
      mockFar.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
    );
    Test.stopTest();
    Assert.areEqual('Open', sourcestatus, 'Source system status is matched');
  }

  @isTest
  static void getFinStatusTest() {
    registerMocks();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = CCRMTestDataFactory.createTermDepositContext();
    CCRMTermDepositQuery query = new CCRMTermDepositQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    query.execute(context);
    Test.startTest();
    String accountStatus = query.getFinStatus(
      mockFar.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
    );
    Test.stopTest();
    Assert.areEqual('Active', accountStatus, 'Account status is active');
  }
}
