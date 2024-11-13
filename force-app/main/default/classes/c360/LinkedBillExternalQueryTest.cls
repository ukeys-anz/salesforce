/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of LinkedBillExternalQuery
 */
@isTest
private class LinkedBillExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "bills": [' +
      '     {' +
      '       "compositeBillId": "4017192605-OL72362139602-PIF5HDRG",' +
      '       "billType": "Commercial Bill - Variable",' +
      '       "billReferenceNo": "PIF5HDRG",' +
      '       "billAmount": "1475000.000",' +
      '       "billSwapReferencePercentage": "0.000638210000000",' +
      '       "billRollOverDate": "2022-03-16T00:00:00"' +
      '     }' +
      '   ]' +
      ' }';

    LinkedBillExternalQuery linkedBill = new LinkedBillExternalQuery();
    Test.startTest();
    linkedBill.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(linkedBill.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    LinkedBillExternalQuery linkedBill = new LinkedBillExternalQuery();
    Test.startTest();
    linkedBill.parseResponse('');
    Test.stopTest();
    Assert.isTrue(linkedBill.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    LinkedBillExternalQuery linkedBill = new LinkedBillExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = linkedBill.execute(
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
      'Commercial Bill - Variable',
      firstRecord.get('BillType'),
      'BillType mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new LinkedBillQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'LinkedBill'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class LinkedBillQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_linkedBillResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
