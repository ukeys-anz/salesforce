/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMAssetFinanceAMBITQuery
 */
@isTest
private class CCRMAssetFinanceAMBITQueryTest {
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
  }

  /**
   * @description test method for CCRMAssetFinanceELSQuery Class
   */
  @isTest
  static void testAssetFinELSQuery() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new CCRMAssetFinanceAMBITQueryTest.CCRMAssetFinanceAMBITQueryTestMock()
    );
    CCRMCoreBankingDataSourceConnection conn = new CCRMCoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    DataSource.QueryContext context = CCRMQueryContextMock.createQueryContext(
      'AssetFinanceAMBIT'
    );
    conn.query(context);
    CCRMAssetFinanceAMBITQuery assetFinQry = new CCRMAssetFinanceAMBITQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = assetFinQry.execute(
      context
    );
    Test.stopTest();
    System.assertEquals(
      result.queryResult.size(),
      1,
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRec = result.queryResult[0];
    system.assertEquals(
      '*D E QUARRY SOLUTIONS',
      (string) firstRec.get('AccountName'),
      'Name mismatch'
    );
    system.assertEquals(
      'AMB050',
      (string) firstRec.get('ProductCode'),
      'Product code mismatch'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMAssetFinanceAMBITQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response for CCRMAssetFinanceELSQuery
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetFinanceAMBIT');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
