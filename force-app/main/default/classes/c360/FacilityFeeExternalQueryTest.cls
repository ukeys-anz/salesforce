/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class for FacilityFeeExternalQuery
 */
@isTest
private class FacilityFeeExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "facilityFees": [' +
      '     {' +
      '       "compositeFacilityFeeId": "4020018249-72466661701-0",' +
      '       "feeType": "COMFE",' +
      '       "feePercentage": "1.3",' +
      '       "feeAmount": "50.01",' +
      '       "feeFrequency": "YR",' +
      '       "feeChargeAccount": "250823253"' +
      '     }' +
      '   ]' +
      ' }';

    FacilityFeeExternalQuery query = new FacilityFeeExternalQuery();
    Test.startTest();
    query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void createFacilitiesTest() {
    DataSource.QueryContext context = createFacilityFeeQueryContext();
    FacilityFeeExternalQuery feeAcct = new FacilityFeeExternalQuery();

    feeAcct.execute(context);
    feeAcct.calloutResponse = new FacilityFeeExternalQuery.FacilityFeeCalloutResponse();
    ((FacilityFeeExternalQuery.FacilityFeeCalloutResponse) FeeAcct.calloutResponse)
      .facilityFees = new List<FacilityFeeExternalQuery.FacilityFeeModel>();
    FacilityFeeExternalQuery.FacilityFeeModel feeModel = new FacilityFeeExternalQuery.FacilityFeeModel();
    feeModel.compositeFacilityFeeId = '4020018249-72466661701-0';
    feeModel.feeType = 'COMFE';
    feeModel.feeFrequency = 'YR';
    feeModel.feeChargeAccount = '250823253';
    feeModel.nextDueDate = DateTime.newInstance(1997, 1, 31, 7, 8, 16);
    ((FacilityFeeExternalQuery.FacilityFeeCalloutResponse) feeAcct.calloutResponse)
      .facilityFees.add(feeModel);
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = feeAcct.createExternalRecords(
      feeAcct.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      'YR',
      result.externalRecords[0].get('Frequency'),
      'Frequency mismatch'
    );
    Assert.areEqual(
      '2508-23253',
      result.externalRecords[0].get('FeeChargeAccount'),
      'Fee charge account should be 2508-23253'
    );
    Assert.areEqual(
      '30/01/1997',
      result.externalRecords[0].get('NextDueDate'),
      'Next due date should be 30/01/1997'
    );
  }

  /**
   * @description create Deposit Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createFacilityFeeQueryContext() {
    Test.setMock(HttpCalloutMock.class, new FacilityFeeQueryTestMock());

    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'FacilityFee'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class FacilityFeeQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_facilityFeeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
