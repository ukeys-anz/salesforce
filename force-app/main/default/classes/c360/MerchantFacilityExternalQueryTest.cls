/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Merchant Facility external query test class
 */
@isTest
private class MerchantFacilityExternalQueryTest {
  @isTest
  static void createExternalRecordsTest() {
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    MerchantFacilityExternalQuery accountQuery = new MerchantFacilityExternalQuery();
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
      'AFTERPAY TOUCH GROUP LIMITED',
      firstRecord.get('TradingName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '489290006',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }
    
  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "tradingName": "AFTERPAY TOUCH GROUP LIMITED",' +
      '       "accountNumber": "489290006",' +
      '       "merchantTerminals": "5",' +
      '       "merchantId": "1234567"' +
      '     }' +
      '   ]' +
      ' }';

    MerchantFacilityExternalQuery accounytExternalQuery = new MerchantFacilityExternalQuery();
    accounytExternalQuery.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(accounytExternalQuery.calloutResponse == null, 'Response is null');
  }  
    
  /**
   * @description create Deposit Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new MerchantFacilityTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'MerchantFacility'
    );
    return context;
  }  

  /**
   * @description create HTTP mock response for testing
   */
  public class MerchantFacilityTestMock implements HttpCalloutMock {
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