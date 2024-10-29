/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of InactiveIndemnityGuaranteeExternalQuery
 */
@isTest
private class InactiveIGExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '     "indemnityGuarantees": [' +
      '       {' +
      '         "compositeGuaranteesId": "4020018249-72466661701-32011",' +
      '         "id": "32011",' +
      '         "status": "EXPIRE",' +
      '         "startDate": "2011-11-11",' +
      '         "expiryDate": "2015-11-11",' +
      '         "purpose": "FIN",' +
      '         "remainingFaceValue": "6636.03"' +
      '       }' +
      '     ]' +
      '   }';

    InactiveIndemnityGuaranteeExternalQuery accountExternalQuery = new InactiveIndemnityGuaranteeExternalQuery();
    Test.startTest();
    accountExternalQuery.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      accountExternalQuery.calloutResponse == null,
      'Response is null'
    );
  }

  @isTest
  static void createExternalRecordsTest() {
    DataSource.QueryContext context = createInactiveIndemnityGuaranteeContext();
    InactiveIndemnityGuaranteeExternalQuery accountQuery = new InactiveIndemnityGuaranteeExternalQuery();

    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.externalRecords.size(), 'Size of accounts is 1');
    Assert.areEqual(
      'FIN',
      result.externalRecords[0].get('PurposeCode'),
      'PurposeCode matched'
    );
  }

  /**
   * @description InactiveIndemnityGuarantee test context
   * @name createInactiveIndemnityGuaranteeContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createInactiveIndemnityGuaranteeContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new InactiveIndemnityGuaranteeQueryTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'InactiveIndemnityGuarantee'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class InactiveIndemnityGuaranteeQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_inactiveIGResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
