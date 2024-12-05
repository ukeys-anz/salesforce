/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Test class for Active Indemnity Guarantee external query class
 */
@isTest
private class ActiveIGExternalQueryTest {
  @isTest
  static void createExternalRecordsTest() {
    DataSource.QueryContext context = createQueryContext();
    ActiveIndemnityGuaranteeExternalQuery accountQuery = new ActiveIndemnityGuaranteeExternalQuery();

    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    assert.areEqual(1, result.externalRecords.size(), 'Size of accounts is 1');
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      '{' +
      '    "indemnityGuarantees": [' +
      '      {' +
      '        "compositeAccountNumber": "4020018249-72466661701",' +
      '        "compositeGuaranteesId": "4020018249-72466661701-29618",' +
      '        "id": "29618",' +
      '        "status": "ACTIVE",' +
      '        "startDate": "2011-11-11",' +
      '        "expiryDate": "2015-11-11",' +
      '        "purpose": "FIN",' +
      '        "remainingFaceValue": "6636.03"' +
      '      }' +
      '    ]' +
      '  }';

    ActiveIndemnityGuaranteeExternalQuery accountExternalQuery = new ActiveIndemnityGuaranteeExternalQuery();
    accountExternalQuery.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      accountExternalQuery.calloutResponse == null,
      'Response is null'
    );
  }

  @isTest
  static void getPayloadForEBDChildAccountsTest() {
    String result;
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    ActiveIndemnityGuaranteeExternalQuery accountQuery = new ActiveIndemnityGuaranteeExternalQuery();
    accountQuery.parentId = '4022196691-72344723601';
    accountQuery.parentField = 'GuaranteeId';
    Test.startTest();
    result = externalQueryHelper.getPayloadForEBDChildAccounts(
      result,
      accountQuery.prepareInfoWrapper()
    );
    Test.stopTest();
    Assert.areEqual(
      '{"compositeAccountNumber": "4022196691-72344723601","fieldSet": "ACTIVE_GUARANTEES"}',
      result,
      'compositeAccountNumber is not populated as parentField is set to CustomerId'
    );
  }

  /**
   * @description create Deposit Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new ActiveIndemnityGuaranteeQueryTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'ActiveIndemnityGuarantee'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class ActiveIndemnityGuaranteeQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_activeIGResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
