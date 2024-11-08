/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group  Platform
 * @description CardHolder external query test class
 */
@isTest
private class CardHolderExternalQueryTest {
  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CardHolderExternalQueryTest.CardHolderTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CardHolder'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CardHolderExternalQuery accountQuery = new CardHolderExternalQuery();
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
    Assert.areEqual(
      'ANZ TDM PRIVATIZED VALUE',
      firstRecord.get('CardholderName'),
      'CardholderName mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CardHolderTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_cardHolderResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
