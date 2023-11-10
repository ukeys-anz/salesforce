/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Merchant Facility external query test class
 */
@isTest
private class CCRMMerchantFacilityQueryTest {
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
  static void createMerchantFacilityTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMMerchantFacilityQueryTest.CCRMMerchantFacilityTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'MerchantFacility'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMMerchantFacilityQuery accountQuery = new CCRMMerchantFacilityQuery();
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
      'AFTERPAY TOUCH GROUP LIMITED',
      firstRecord.get('TradingName'),
      'Name mismatch'
    );
    System.assertEquals(
      '489290006',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMMerchantFacilityTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_merchantFacilityResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
