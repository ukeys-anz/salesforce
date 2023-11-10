/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Transaction History external query test class
 */
@isTest
private class CCRMTransactionHistoryQueryTest {
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
  }

  @isTest
  static void createTransactionHistoryTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMTransactionHistoryQueryTest.CCRMTransactionHistoryTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'TransactionHistory'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMTransactionHistoryQuery accountQuery = new CCRMTransactionHistoryQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.queryResult.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.queryResult[0];
    System.assertEquals(
      8867.81,
      firstRecord.get('RunningBalance'),
      'Running Balance mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMTransactionHistoryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_transactionHistoryResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
