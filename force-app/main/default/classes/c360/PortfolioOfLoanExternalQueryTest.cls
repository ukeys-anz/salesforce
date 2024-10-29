/**
 * @author Hitesh W
 * @since  09/2023
 * @group Platform
 * @description Test Class for PortfolioOfLoanExternalQuery
 */
@isTest
private class PortfolioOfLoanExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  /**
   * @description test method for PortfolioOfLoanExternalQuery Class
   */
  @isTest
  static void testPortfolioQuery() {
    registerMocks();
    Test.startTest();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    faRepoMock.mock(
      'getCustomerUsingExternalIdAndRtName',
      new List<Account>()
    );

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-431214465',
        FinServ__FinancialAccountNumber__c = '431214465',
        Product_Type__c = 'CAP-CIS:PTF'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );

    Test.setMock(
      HttpCalloutMock.class,
      new PortfolioOfLoanExternalQueryTest.PortfolioOfLoanExternalQueryTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'PortfolioOfLoan'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    PortfolioOfLoanExternalQuery accountQuery = new PortfolioOfLoanExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'PTF',
      result.externalRecords[0].get('ProductCode'),
      'Product code mismatch'
    );
    Assert.areEqual(
      'RAJESWARAN SOLUTIONS PTY LTD',
      result.externalRecords[0].get('AccountName'),
      'Account Name mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class PortfolioOfLoanExternalQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response for PortfolioOfLoanExternalQuery
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_ptfResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
