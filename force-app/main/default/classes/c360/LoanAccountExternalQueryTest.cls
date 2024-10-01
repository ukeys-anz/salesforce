/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group platform
 * @description Loan Account external query test class
 */
@isTest
private class LoanAccountExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c createMockData(
    String accountKey,
    String accountNum,
    String accountNumFormat
  ) {
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = accId,
          Account_Key__c = accountKey,
          FinServ__FinancialAccountNumber__c = accountNum,
          Product_Type__c = 'CAP-CIS:ILS'
        ),
        new Map<String, Object>{ 'Account_Number__c' => accountNumFormat }
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
      '       "accountName": "Buck Hattie",' +
      '       "accountNumber": "503456793",' +
      '       "productCode": "ILS",' +
      '       "accountBalance": "5000000.47",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    LoanAccountExternalQuery loanAcct = new LoanAccountExternalQuery();
    loanAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(loanAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    Test.startTest();
    LoanAccountExternalQuery loanAcct = new LoanAccountExternalQuery();
    loanAcct.parseResponse('');
    Test.stopTest();
    Assert.isTrue(loanAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-503456793',
      '503456793',
      '5034-56793'
    );
    DataSource.QueryContext context = createLoanAccountQueryContext();
    LoanAccountExternalQuery loanAcct = new LoanAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    loanAcct.execute(context);
    loanAcct.calloutResponse = new LoanAccountExternalQuery.LoanAccountCalloutResponse();
    ((LoanAccountExternalQuery.LoanAccountCalloutResponse) loanAcct.calloutResponse)
      .accounts = new List<LoanAccountExternalQuery.LoanAccountModel>();
    LoanAccountExternalQuery.LoanAccountModel loanModel = new LoanAccountExternalQuery.LoanAccountModel();
    loanModel.accountName = 'Buck Hattie';
    loanModel.accountNumber = '503456793';
    ((LoanAccountExternalQuery.LoanAccountCalloutResponse) loanAcct.calloutResponse)
      .accounts.add(loanModel);
    ExternalObjectQueryBase.ExternalQueryResult result = loanAcct.createExternalRecords(
      loanAcct.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void createLoanAccountsSummaryTest() {
    registerMocks();
    Test.startTest();

    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-503456793',
      '503456793',
      '5034-56793'
    );

    DataSource.QueryContext context = createLoanAccountQueryContext();
    LoanAccountExternalQuery loanAcct = new LoanAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = loanAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'Buck Hattie',
      result.externalRecords[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '5034-56793',
      result.externalRecords[0].get('AccountNumber'),
      'Account number mismatch'
    );
  }

  @isTest
  static void createLoanAccountsDetailTest() {
    registerMocks();
    Test.startTest();

    //Setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = createMockData(
      '4011643101-391102388',
      '391102388',
      '3911-02388'
    );

    DataSource.QueryContext context = createLoanAccountDetailContext();
    LoanAccountExternalQuery loanAcct = new LoanAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithAcctNum',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = loanAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'REDDY',
      result.externalRecords[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '3911-02388',
      result.externalRecords[0].get('AccountNumber'),
      'Account number mismatch'
    );
  }
  @isTest
  static void retrieveIndustryCodeAndDescriptionTest() {
    registerMocks();
    Test.startTest();
    Id newIndustryID = Lib_FakeIdGenerator.getMockId(
      Schema.Industry__c.getSObjectType()
    );
    Industry__c industry = new Industry__c(
      Id = newIndustryID,
      Code__c = '0111',
      Name = 'PLANT NURSERIES'
    );
    faRepoMock.mock('getIndustryCodeAndDescription', industry);
    LoanAccountExternalQuery financiaBase = new LoanAccountExternalQuery();
    String industryValue = financiaBase.retrieveIndustryCodeAndDescription(
      '0111'
    );
    Test.stopTest();
    Assert.areEqual(
      '0111 - PLANT NURSERIES',
      industryValue,
      'retrieveIndustryCodeAndDescription is not working properly'
    );
  }
  @isTest
  static void getFinancialAccountsWhenParentIdIsNotBlankForMLUserTest() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      registerMocks();
      Test.startTest();
      FinServ__FinancialAccountRole__c mockFar = createMockData(
        '4011643101-503456793',
        '503456793',
        '5034-56793'
      );
      DataSource.QueryContext context = createLoanAccountQueryContext();
      LoanAccountExternalQuery query = new LoanAccountExternalQuery();
      faRepoMock.mock(
        'getFinancialAccountsWithCustomerId',
        new List<FinServ__FinancialAccountRole__c>{ mockFar }
      );
      query.execute(context);
      query.calloutResponse = new LoanAccountExternalQuery.LoanAccountCalloutResponse();
      ((LoanAccountExternalQuery.LoanAccountCalloutResponse) query.calloutResponse)
        .accounts = new List<LoanAccountExternalQuery.LoanAccountModel>();
      LoanAccountExternalQuery.LoanAccountModel loanModel = new LoanAccountExternalQuery.LoanAccountModel();
      loanModel.accountName = 'Buck Hattie';
      loanModel.accountNumber = '503456793';

      ((LoanAccountExternalQuery.LoanAccountCalloutResponse) query.calloutResponse)
        .accounts.add(loanModel);
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
  }

  /**
   * @description create Loan Account Query Context and set mock response
   * @return queryContext
   */
  private static DataSource.QueryContext createLoanAccountQueryContext() {
    Test.setMock(HttpCalloutMock.class, new LoanAccountSummaryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'LoanAccount'
    );
    return context;
  }

  /**
   * @description create Loan Account Query Context and set mock response
   * @return DataSource.QueryContext
   */
  private static DataSource.QueryContext createLoanAccountDetailContext() {
    Test.setMock(HttpCalloutMock.class, new LoanAccountDetailTestMock());
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'LoanAccount'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class LoanAccountSummaryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_loanAccountResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'ils-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class LoanAccountDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_loanDetailResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'ils-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
