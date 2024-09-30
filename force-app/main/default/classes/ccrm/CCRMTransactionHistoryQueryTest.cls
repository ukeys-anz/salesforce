/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Transaction History external query test class
 */
@isTest
private class CCRMTransactionHistoryQueryTest {
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

  @isTest
  static void displayDummayFinancialAccountTest() {
    system.assertEquals(
      true,
      CCRMTransactionHistoryQuery.displayDummayFinancialAccount('dummyVal', ''),
      'displayDummayFinancialAccount is not returning correct result when parentId is empty'
    );
    system.assertEquals(
      false,
      CCRMTransactionHistoryQuery.displayDummayFinancialAccount('', 'dummyVal'),
      'isDepositProductCategory is not returning correct result when externalId is empty'
    );
  }

  @isTest
  static void formatSourceTest() {
    system.assertEquals(
      'Hello World New',
      CCRMTransactionHistoryQuery.formatSource('hElLO_WoRlD_nEW'),
      'formatSource is not returning correct result with given string'
    );
    system.assertEquals(
      '',
      CCRMTransactionHistoryQuery.formatSource(null),
      'formatSource is not returning correct result when null string'
    );
    system.assertEquals(
      '',
      CCRMTransactionHistoryQuery.formatSource(''),
      'formatSource is not returning correct result when empty string'
    );
  }

  @isTest
  static void createDummyFinancialAccountsTest() {
    CCRMTransactionHistoryQuery accQuery = new CCRMTransactionHistoryQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult dummyAcc = accQuery.createDummyFinancialAccounts(
      'DDA-929490053-0-11-0001'
    );

    system.assertEquals(
      'No further information available',
      dummyAcc.queryResult.get(0).get('AdditionalInformation'),
      'createDummyFinancialAccounts is not returning correct result'
    );
    system.assertEquals(
      'DDA-929490053',
      dummyAcc.queryResult.get(0).get('ExternalId'),
      'createDummyFinancialAccounts is not returning correct result'
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
