/**
 * @author Hitesh
 * @since  09/2024
 * @group Platform
 * @description Transaction History external query test class
 */
@isTest
private class TransactionHistoryExternalQueryTest {
  @isTest
  static void createTransactionHistoryTest() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new TransactionHistoryTestMock());
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();

    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'TransactionHistory'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);

    TransactionHistoryExternalQuery accountQuery = new TransactionHistoryExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
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
      TransactionHistoryExternalQuery.displayDummayFinancialAccount(
        'dummyVal',
        ''
      ),
      'displayDummayFinancialAccount is not returning correct result when parentId is empty'
    );
    system.assertEquals(
      false,
      TransactionHistoryExternalQuery.displayDummayFinancialAccount(
        '',
        'dummyVal'
      ),
      'isDepositProductCategory is not returning correct result when externalId is empty'
    );
  }

  @isTest
  static void formatSourceTest() {
    system.assertEquals(
      'Hello World New',
      TransactionHistoryExternalQuery.formatSource('hElLO_WoRlD_nEW'),
      'formatSource is not returning correct result with given string'
    );
    system.assertEquals(
      '',
      TransactionHistoryExternalQuery.formatSource(null),
      'formatSource is not returning correct result when null string'
    );
    system.assertEquals(
      '',
      TransactionHistoryExternalQuery.formatSource(''),
      'formatSource is not returning correct result when empty string'
    );
  }

  @isTest
  static void createDummyFinancialAccountsTest() {
    TransactionHistoryExternalQuery accQuery = new TransactionHistoryExternalQuery();
    system.assertEquals(
      'DDA-929490053',
      accQuery.createDummyExternalRecord(
          'DDA-929490053-0-11-0001',
          new Map<String, Object>()
        )
        .externalRecords.get(0)
        .get('ExternalId'),
      'createDummyFinancialAccounts is not returning correct result'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class TransactionHistoryTestMock implements HttpCalloutMock {
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