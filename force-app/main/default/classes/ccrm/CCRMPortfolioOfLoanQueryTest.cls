/**
 * @author Hitesh W
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMPortfolioOfLoanQuery
 */
@isTest
private class CCRMPortfolioOfLoanQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  /**
   * @description test method for CCRMPortfolioOfLoanQuery Class
   */
  @isTest
  static void testPortfolioQuery() {
    registerMocks();
    Test.startTest();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
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
      new CCRMPortfolioOfLoanQueryTest.CCRMPortfolioOfLoanQueryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'PortfolioOfLoan'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMPortfolioOfLoanQuery accountQuery = new CCRMPortfolioOfLoanQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    system.assertEquals(
      'PTF',
      result.queryResult[0].get('ProductCode'),
      'Product code mismatch'
    );
    System.assertEquals(
      'RAJESWARAN SOLUTIONS PTY LTD',
      result.queryResult[0].get('AccountName'),
      'Account Name mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMPortfolioOfLoanQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response for CCRMPortfolioOfLoanQuery
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
