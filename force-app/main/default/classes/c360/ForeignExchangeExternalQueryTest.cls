/**
 * @author Ian Huang
 * @since  10/2024
 * @group platform
 * @description Foreign Exchange external query test class
 */
@isTest
private class ForeignExchangeExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "compositeAccountNumber": "42343243-72362139602",' +
      '       "accountNumber": "72362139602",' +
      '       "balanceAmount": "300000.00",' +
      '       "currencyCode": "USD",' +
      '       "interestRate": "15.00",' +
      '       "midanzCustId": "Customer123",' +
      '       "productCode": "FCA",' +
      '       "productDescription": "Foreign Exchange Account",' +
      '       "status": "Z"' +
      '     }' +
      '   ]' +
      ' }';

    ForeignExchangeExternalQuery query = new ForeignExchangeExternalQuery();
    Test.startTest();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();

    List<ForeignExchangeExternalQuery.ForeignExchangeModel> accounts = ((ForeignExchangeExternalQuery.ForeignExchangeCalloutResponse) query.calloutResponse)
      .accounts;
    Assert.areEqual(1, accounts.size(), 'ForeignExchange Response is empty.');
    Assert.areEqual(
      '42343243-72362139602',
      accounts[0].compositeAccountNumber,
      'FCA compositeAccountNumber mismatch'
    );
    Assert.areEqual(
      '72362139602',
      accounts[0].accountNumber,
      'FCA Account number mismatch'
    );
    Assert.areEqual(300000, accounts[0].balanceAmount, 'FCA balance mismatch');
    Assert.areEqual(
      'USD',
      accounts[0].currencyCode,
      'FCA currencyCode mismatch'
    );
    Assert.areEqual(15, accounts[0].interestRate, 'FCA interestRate mismatch');
    Assert.areEqual(
      'Customer123',
      accounts[0].midanzCustId,
      'FCA midANZCustomer mismatch'
    );
    Assert.areEqual('FCA', accounts[0].productCode, 'FCA productCode mismatch');
    Assert.areEqual(
      'Foreign Exchange Account',
      accounts[0].productDescription,
      'FCA productName mismatch'
    );
    Assert.areEqual('Z', accounts[0].status, 'FCA sourceSystemStatus mismatch');
  }

  @isTest
  static void testNullResponse() {
    ForeignExchangeExternalQuery query = new ForeignExchangeExternalQuery();

    Test.startTest();
    query.calloutResponse = query.parseResponse('');
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      query.calloutResponse,
      'ForeignExchange Response should be empty.'
    );
    Assert.areEqual(
      0,
      result.externalRecords.size(),
      'Size of accounts is not 0'
    );
  }

  @isTest
  static void createForeignExchangeTest() {
    ForeignExchangeExternalQuery query = new ForeignExchangeExternalQuery();

    query.calloutResponse = new ForeignExchangeExternalQuery.ForeignExchangeCalloutResponse();
    ((ForeignExchangeExternalQuery.ForeignExchangeCalloutResponse) query.calloutResponse)
      .accounts = new List<ForeignExchangeExternalQuery.ForeignExchangeModel>();
    ForeignExchangeExternalQuery.ForeignExchangeModel fcaModel = new ForeignExchangeExternalQuery.ForeignExchangeModel();
    fcaModel.compositeAccountNumber = '42343243-72362139602';
    fcaModel.accountNumber = '72362139602';
    fcaModel.productCode = 'FCA';
    fcaModel.balanceAmount = 100000.00;
    fcaModel.status = 'Z';
    ((ForeignExchangeExternalQuery.ForeignExchangeCalloutResponse) query.calloutResponse)
      .accounts.add(fcaModel);

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
      '42343243-72362139602',
      result.externalRecords[0].get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '7236-213-9602',
      result.externalRecords[0].get('AccountNumber'),
      'Account number mismatch'
    );
    Assert.areEqual(
      'FCA',
      result.externalRecords[0].get('ProductCode'),
      'ProductCode mismatch'
    );
    Assert.areEqual(
      100000.00,
      result.externalRecords[0].get('Balance'),
      'BalanceAmount mismatch'
    );
    Assert.areEqual(
      'Active',
      result.externalRecords[0].get('SourceSystemStatus'),
      'Status mismatch'
    );
  }
}
