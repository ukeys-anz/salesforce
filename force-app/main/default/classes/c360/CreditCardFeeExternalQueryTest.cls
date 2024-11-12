/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group Platform
 * @description Test class of CreditCardFeeExternalQuery
 */
@isTest
private class CreditCardFeeExternalQueryTest {
  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CreditCardFeeExternalQueryTest.CreditCardFeeTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CreditCardFee'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CreditCardFeeExternalQuery accountQuery = new CreditCardFeeExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(15, firstRecord.get('FeeAmount'), 'FeeAmount mismatch');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreditCardFeeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_creditCardFeeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
