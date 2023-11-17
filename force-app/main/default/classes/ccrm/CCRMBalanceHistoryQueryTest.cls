/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMBalanceHistoryQuery
 */
@isTest
private class CCRMBalanceHistoryQueryTest {
  @TestSetup
  static void createTestData() {
    Id customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('Business_Account')
      .getRecordTypeId();
    Account acct = TestDataFactory.createBusinessRecordTypeAccount(
      '4040r00000E3yPTABB',
      customerRecordTypeId,
      '4040r00000E3yPTABB'
    );
  }

  @isTest
  static void testBalanceHistoryQuery() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMBalanceHistoryQueryTest.CCRMBalanceHistoryQueryTestMock()
    );
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'BalanceHistory'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
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

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMBalanceHistoryQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_balanceHistory');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'balance-history-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
