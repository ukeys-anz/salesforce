/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of LinkedAccountExternalQuery
 */
@isTest
private class LinkedAccountExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "relatedAccounts": [' +
      '     {' +
      '       "compositeLinkedAccountId": "PTF-10000000038-1",' +
      '       "productCode": "APP",' +
      '       "accountNumber": "708749911",' +
      '        "relateCode": "PSA"' +
      '     }' +
      '   ]' +
      ' }';

    LinkedAccountExternalQuery linkedAcct = new LinkedAccountExternalQuery();
    Test.startTest();
    linkedAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(linkedAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    LinkedAccountExternalQuery linkedAccountQry = new LinkedAccountExternalQuery();
    Test.startTest();
    linkedAccountQry.parseResponse('');
    Test.stopTest();
    Assert.isTrue(
      linkedAccountQry.calloutResponse == null,
      'Response is not null'
    );
  }

  @isTest
  static void testCreateExternalRecords() {
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    LinkedAccountExternalQuery linkedAccountQry = new LinkedAccountExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = linkedAccountQry.execute(
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
      'PTF-10000000038-1',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '708-749-911',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new LinkedAccountQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'LinkedAccount'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class LinkedAccountQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_linkedAccountResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
