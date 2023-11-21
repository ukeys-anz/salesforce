/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Asset Repayment Detail external query test class
 */
@isTest
private class CCRMAssetRepaymentDetailQueryTest {
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
  static void createAssetRepaymentDetailTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMAssetRepaymentDetailQueryTest.CCRMAssetRepaymentDetailTestMock()
    );
    //sync
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'AssetRepaymentDetail'
    );
    CCRMCoreBankingDataSourceConnection aConn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    CCRMAssetRepaymentDetailQuery accountQuery = new CCRMAssetRepaymentDetailQuery();
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
      '2601',
      firstRecord.get('Frequency'),
      'Frequency mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMAssetRepaymentDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetRepaymentDetail');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
