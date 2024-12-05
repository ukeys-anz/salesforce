/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of GuaranteeFeeDetailExternalQuery
 */
@isTest
private class GuaranteeFeeDetailExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "guaranteesFees": [' +
      '     {' +
      '       "compositeGuaranteesFeeId": "4020018249-72466661701-29618-0",' +
      '       "feeType": "IGFEE",' +
      '       "feePercentage": "0",' +
      '       "feeAmount": "0",' +
      '       "feeFrequency": "YR",' +
      '       "feeChargeAccount": "250823253"' +
      '     }' +
      '   ]' +
      ' }';

    GuaranteeFeeDetailExternalQuery query = new GuaranteeFeeDetailExternalQuery();
    Test.startTest();
    query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void createExternalRecordsTest() {
    DataSource.QueryContext context = createGuaranteeFeeDetailContext();
    GuaranteeFeeDetailExternalQuery query = new GuaranteeFeeDetailExternalQuery();
    query.execute(context);

    query.calloutResponse = new GuaranteeFeeDetailExternalQuery.GuaranteeFeeCalloutResponse();
    ((GuaranteeFeeDetailExternalQuery.GuaranteeFeeCalloutResponse) query.calloutResponse)
      .guaranteesFees = new List<GuaranteeFeeDetailExternalQuery.GuaranteeFeeModel>();
    GuaranteeFeeDetailExternalQuery.GuaranteeFeeModel feeModel = new GuaranteeFeeDetailExternalQuery.GuaranteeFeeModel();
    feeModel.compositeGuaranteesFeeId = '4020018249-72466661701-29618-0';
    feeModel.feeType = 'IGFEE';
    ((GuaranteeFeeDetailExternalQuery.GuaranteeFeeCalloutResponse) query.calloutResponse)
      .guaranteesFees.add(feeModel);
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void createGuaranteeFeeDetailTest() {
    DataSource.QueryContext context = createGuaranteeFeeDetailContext();
    GuaranteeFeeDetailExternalQuery accountQuery = new GuaranteeFeeDetailExternalQuery();
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
    Assert.areEqual('IGFEE', firstRecord.get('FeeType'), 'FeeType mismatch');
  }

  @isTest
  static void getPayloadForGuaranteeFeeSummaryAccountsTest() {
    String result;
    GuaranteeFeeDetailExternalQuery accountQuery = new GuaranteeFeeDetailExternalQuery();
    FinancialAccountExternalQueryHelper externalQueryHelper = new FinancialAccountExternalQueryHelper();
    accountQuery.parentId = '4020018249-72466661701-29618';
    accountQuery.parentField = 'ActiveGuaranteeId';
    Test.startTest();
    result = externalQueryHelper.getPayloadForGuaranteeFeeSummaryAccounts(
      '',
      accountQuery.prepareInfoWrapper()
    );
    Test.stopTest();
    Assert.areEqual(
      '{"compositeGuaranteesId": "4020018249-72466661701-29618","fieldSet": "GUARANTEES_FEES"}',
      result,
      'Payload is empty'
    );
  }

  /**
   * @description Create guarantee fee detail context for API
   * @name createGuaranteeFeeDetailContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createGuaranteeFeeDetailContext() {
    Test.setMock(HttpCalloutMock.class, new GuaranteeFeeDetailTestMock());

    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'GuaranteeFeeDetail'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class GuaranteeFeeDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_guaranteeFeeResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
