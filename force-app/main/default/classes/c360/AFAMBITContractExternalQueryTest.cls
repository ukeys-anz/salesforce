/**
 * @author Ayushi Gupta
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AFAMBITContractExternalQuery
 */
@isTest
private class AFAMBITContractExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "contracts": [' +
      '     {' +
      '       "contractNumber": "190",' +
      '       "accountNumber": "24",' +
      '       "status": "End - Terminated",' +
      '       "dateOpened": "2014-10-22T00:00:00",' +
      '       "expiryDate": "2018-10-22T00:00:00",' +
      '       "termsInMonth": "4 Months",' +
      '       "termsInYear": "0 Years",' +
      '       "amountFinanced": 468012.18,' +
      '       "govtGuarantee": "YES",' +
      '       "productCode": "AMB050",' +
      '       "facilityDesc": "Chattel Mortgage Fixed Rate",' +
      '       "interestType": "Fixed",' +
      '       "interestRate": 6.53127482,' +
      '       "compositeCreditLineId": "1011137670-24-190"' +
      '     }' +
      '   ]' +
      ' }';

    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    contract.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(contract.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    contract.parseResponse('');
    Test.stopTest();
    Assert.isTrue(contract.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    DataSource.QueryContext context = createQueryContext();
    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = contract.execute(
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
      '1011137670-24-190',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '24',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AFAMBITContractQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'Contract'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITContractQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_contract');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
