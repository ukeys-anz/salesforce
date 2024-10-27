/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description IG external query test class
 */

@isTest
private class IndemnityGuaranteeExternalQueryTest {
  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      '{' +
      '    "accounts": [' +
      '      {' +
      '        "compositeAccountNumber": "4011643101-72455201101",' +
      '        "accountNumber": "72455201101",' +
      '        "accountLimit": "10454",' +
      '        "status": "APPROVED"' +
      '      }' +
      '    ],' +
      '    "nextPageId": null' +
      '  }';

    IndemnityGuaranteeExternalQuery accountExternalQuery = new IndemnityGuaranteeExternalQuery();
    accountExternalQuery.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      accountExternalQuery.calloutResponse == null,
      'Response is null'
    );
  }

  @isTest
  static void createExternalRecordsTest() {
    DataSource.QueryContext context = createQueryContext();
    IndemnityGuaranteeExternalQuery accountQuery = new IndemnityGuaranteeExternalQuery();
    Test.startTest();
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
      '7245-520-1101',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
    );
  }

  /**
   * @description create IG Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new IndemnityGuaranteeTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'IndemnityGuarantee'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class IndemnityGuaranteeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_IGResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
