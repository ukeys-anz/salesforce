/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AssetFinanceAMBITExternalQuery
 */
@isTest
private class AssetFinanceAMBITExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "productCode": "AMB050",' +
      '       "status": "Quote Expired",' +
      '       "originalAmountFinanced": "440000.0000",' +
      '       "accountName": "D E QUARRY SOLUTIONS",' +
      '       "contractNumber": "4020632171",' +
      '       "compositeAccountNumber": "4020632171-122185",' +
      '       "govtGuarantee": "YES",' +
      '       "interestRate": "6.110000000000"' +
      '     }' +
      '   ]' +
      ' }';

    AssetFinanceAMBITExternalQuery assetFin = new AssetFinanceAMBITExternalQuery();
    Test.startTest();
    assetFin.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(assetFin.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AssetFinanceAMBITExternalQuery assetFin = new AssetFinanceAMBITExternalQuery();
    Test.startTest();
    assetFin.parseResponse('');
    Test.stopTest();
    Assert.isTrue(assetFin.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    AssetFinanceAMBITExternalQuery assetFin = new AssetFinanceAMBITExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = assetFin.execute(
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
      '4020632171-122185',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '4020632171',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AssetFinanceAMBITQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AssetFinanceAMBIT'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AssetFinanceAMBITQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
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
