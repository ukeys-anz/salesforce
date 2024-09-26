/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Term Deposit external query test class
 */
@isTest
private class TermDepositExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
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

    TermDepositExternalQuery query = new TermDepositExternalQuery();
    query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    query.execute(context);

    query.calloutResponse = new TermDepositExternalQuery.TermAccountCalloutResponse();
    ((TermDepositExternalQuery.TermAccountCalloutResponse) query.calloutResponse)
      .accounts = new List<TermDepositExternalQuery.TermDepositModel>();
    TermDepositExternalQuery.TermDepositModel termModel = new TermDepositExternalQuery.TermDepositModel();
    termModel.accountName = 'Denis Lai';
    termModel.accountNumber = '403456789';
    ((TermDepositExternalQuery.TermAccountCalloutResponse) query.calloutResponse)
      .accounts.add(termModel);
    ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) query.calloutResponse)
      .customerId = 'CAP-CIS_4011643101';
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void createTermDepositAccountsTest() {
    registerMocks();
    Test.startTest();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = query.execute(context);
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'Denis Lai',
      result.externalRecords[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '4034-56789',
      result.externalRecords[0].get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  @isTest
  static void getProductCodeTest() {
    registerMocks();
    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
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
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
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
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
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
    DataSource.QueryContext context = createTermDepositQueryContext();
    TermDepositExternalQuery query = new TermDepositExternalQuery();
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
  /**
   * @description create Term Deposit Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createTermDepositQueryContext() {
    Test.setMock(HttpCalloutMock.class, new TermDepositTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'TermDeposit'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class TermDepositTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_termDepositResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}