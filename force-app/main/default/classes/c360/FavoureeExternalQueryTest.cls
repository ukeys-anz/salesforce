/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test Class for FavoureeExternalQuery
 */
@isTest
private class FavoureeExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "guaranteesFavourees": [' +
      '     {' +
      '       "compositeGuaranteesFavoureesId": "4020018249-72466661701-29618-0",' +
      '       "name": "test",' +
      '       "abn": "DDA"' +
      '     }' +
      '   ]' +
      ' }';

    FavoureeExternalQuery favoureeAcct = new FavoureeExternalQuery();
    Test.startTest();
    favoureeAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      favoureeAcct.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    FavoureeExternalQuery favQry = new FavoureeExternalQuery();
    Test.startTest();
    favQry.parseResponse('');
    Test.stopTest();
    Assert.isTrue(favQry.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    FavoureeExternalQuery favQry = new FavoureeExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = favQry.execute(
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
      '4020018249-72466661701-29618-0',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual('test', firstRecord.get('Name'), 'Name mismatch');
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new FavoureeQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'Favouree'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class FavoureeQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_favoureeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'balance-history-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
