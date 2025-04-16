/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Commercial Bill external query test class
 */
@isTest
private class CommercialBillExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "compositeAccountNumber": "4017192605-OL72362139602-0",' +
      '       "accountNumber": "OL72362139602",' +
      '       "status": "ACTIVE"' +
      '     }' +
      '   ]' +
      ' }';

    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    Test.startTest();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(query.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void createCommercialBillTest() {
    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    query.calloutResponse = new CommercialBillExternalQuery.CommercialBillCalloutResponse();
    ((CommercialBillExternalQuery.CommercialBillCalloutResponse) query.calloutResponse)
      .accounts = new List<CommercialBillExternalQuery.CommercialBillModel>();
    CommercialBillExternalQuery.CommercialBillModel cBModel = new CommercialBillExternalQuery.CommercialBillModel();
    cBModel.compositeAccountNumber = '4017192605-OL72362139602-4';
    cBModel.accountNumber = 'OL72362139602';
    ((CommercialBillExternalQuery.CommercialBillCalloutResponse) query.calloutResponse)
      .accounts.add(cBModel);
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
    Assert.areEqual(
      'OL72362139602',
      result.externalRecords[0].get('AccountNumber'),
      'Number mismatch'
    );
  }

  @isTest
  static void testGetCustomerIdAsExternalId() {
    String parentId;
    String compositeAccountNumber = '4017192605-OL72362139602';
    String customerId;
    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    Test.startTest();
    customerId = query.getCustomerId(parentId, compositeAccountNumber);
    Test.stopTest();
    Assert.areEqual(
      'CAP-CIS_4017192605',
      customerId,
      'Not able to fetch customerId'
    );
  }

  @isTest
  static void testGetCustomerIdAsParentId() {
    String parentId = '72362139602';
    String compositeAccountNumber = '4017192605-OL72362139602';
    String customerId;
    CommercialBillExternalQuery query = new CommercialBillExternalQuery();
    Test.startTest();
    customerId = query.getCustomerId(parentId, compositeAccountNumber);
    Test.stopTest();
    Assert.areEqual(parentId, customerId, 'Not able to fetch customerId');
  }

}
