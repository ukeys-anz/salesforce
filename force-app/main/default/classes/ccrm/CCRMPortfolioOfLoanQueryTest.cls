/**
 * @author Hitesh W
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMPortfolioOfLoanQuery
 */
@isTest
private class CCRMPortfolioOfLoanQueryTest {
  /**
   * @description setupMethod to create data
   */
  @TestSetup
  static void createTestData() {
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business_Account')
      .getRecordTypeId();
    Account acct = TestDataFactory.createBusinessRecordTypeAccount(
      'CAP-CIS_4011643101',
      customerRecordTypeId,
      '4011643101'
    );

    Id bankingRecordTypeId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    FinServ__FinancialAccount__c finAccount = TestDataFactory.createC360FinancialAccount(
      bankingRecordTypeId,
      'CAP-CIS:PTF',
      acct.Id,
      '4011643101-431214465',
      '431214465'
    );
    if (finAccount.Id != null) {
      FinServ__FinancialAccountRole__c finRole = [
        SELECT Id, FinServ__FinancialAccount__c, Role_Type__c
        FROM FinServ__FinancialAccountRole__c
        WHERE FinServ__FinancialAccount__c = :finAccount.Id
        LIMIT 1
      ];
      finRole.Role_Type__c = 'PRI';
      update finRole;
    }
  }

  /**
   * @description test method for CCRMPortfolioOfLoanQuery Class
   */
  @isTest
  static void testPortfortfolioQuery() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMPortfolioOfLoanQueryTest.CCRMPortfolioOfLoanQueryTestMock()
    );
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'PortfolioOfLoan'
    );
    conn.query(context);
    CCRMPortfolioOfLoanQuery accountQuery = new CCRMPortfolioOfLoanQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRec = result.queryResult[0];
    system.assertEquals(
      'PTF',
      (string) firstRec.get('ProductCode'),
      'Product code mismatch'
    );
    system.assertEquals(
      'RAJESWARAN SOLUTIONS PTY LTD',
      (string) firstRec.get('AccountName'),
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
