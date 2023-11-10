/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description CardHolder external query test class
 */
@isTest
private class CCRMCardHolderQueryTest {
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
  static void createCardHolderTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMCardHolderQueryTest.CCRMCardHolderTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'CardHolder'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMCardHolderQuery accountQuery = new CCRMCardHolderQuery();
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
      'ANZ TDM PRIVATIZED VALUE',
      firstRecord.get('CardholderName'),
      'CardholderName mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMCardHolderTestMock implements HttpCalloutMock {
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
