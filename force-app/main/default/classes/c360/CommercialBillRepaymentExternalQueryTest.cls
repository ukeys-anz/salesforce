/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of CommercialBillRepaymentExternalQuery
 */
@isTest
private class CommercialBillRepaymentExternalQueryTest {
  /**
   * @description create HTTP mock response for testing
   */
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "repayments": [' +
      '     {' +
      '       "compositeAccountRepaymentId": "4017192605-OL72362139602-0",' +
      '       "scheduledBillReductionAmount": "25000.000",' +
      '   	  "scheduledStartDate": "2019-01-23T00:00:00",' +
      '   	  "scheduledEndDate": "2019-01-23T00:00:00"' +
      '     }' +
      '   ]' +
      ' }';
    Test.startTest();
    CommercialBillRepaymentExternalQuery query = new CommercialBillRepaymentExternalQuery();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testCreateFinancialAccounts() {
    CommercialBillRepaymentExternalQuery query = new CommercialBillRepaymentExternalQuery();
    query.calloutResponse = new CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse();
    ((CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse) query.calloutResponse)
      .repayments = new List<CommercialBillRepaymentExternalQuery.RepaymentDetailModel>();
    CommercialBillRepaymentExternalQuery.RepaymentDetailModel repayModel = new CommercialBillRepaymentExternalQuery.RepaymentDetailModel();
    repayModel.compositeAccountRepaymentId = '4017192605-OL72362139602-4';
    repayModel.scheduledBillReductionAmount = 25000.000;
    ((CommercialBillRepaymentExternalQuery.RepaymentDetailCalloutResponse) query.calloutResponse)
      .repayments.add(repayModel);
      
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
 
}
