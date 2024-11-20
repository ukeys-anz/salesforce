/**
 * @author Ian Huang
 * @since  10/2024
 * @group platform
 * @description Foreign Exchange Deal external query test class
 */
@isTest
private class ForeignExchangeDealExternalQueryTest {
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "compositeAccountNumber": "42343243-72362139602",' +
      '       "dealNumber": "72362139602",' +
      '       "askPrice": "1000.00",' +
      '       "askPriceCurrency": "USD",' +
      '       "bidPrice": "1500.00",' +
      '       "bidPriceCurrency": "AUD",' +
      '       "dealDate": "2024-10-25",' +
      '       "valueDate": "2024-10-28"' +
      '     }' +
      '   ]' +
      ' }';

    ForeignExchangeDealExternalQuery query = new ForeignExchangeDealExternalQuery();
    Test.startTest();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();

    List<ForeignExchangeDealExternalQuery.ForeignExchangeDealModel> accounts = ((ForeignExchangeDealExternalQuery.ForeignExchangeDealCalloutResponse) query.calloutResponse)
      .accounts;
    Assert.areEqual(
      1,
      accounts.size(),
      'ForeignExchangeDeal Response is empty.'
    );
    Assert.areEqual(
      '42343243-72362139602',
      accounts[0].compositeAccountNumber,
      'Deal compositeAccountNumber mismatch'
    );
    Assert.areEqual(
      '72362139602',
      accounts[0].dealNumber,
      'Deal number mismatch'
    );
    Assert.areEqual(
      'USD',
      accounts[0].askPriceCurrency,
      'Deal askPriceCurrency mismatch'
    );
    Assert.areEqual(1000, accounts[0].askPrice, 'Deal askPrice mismatch');
    Assert.areEqual(
      'AUD',
      accounts[0].bidPriceCurrency,
      'Deal bidPriceCurrency mismatch'
    );
    Assert.areEqual(1500, accounts[0].bidPrice, 'Deal bidPrice mismatch');
    Assert.areEqual(
      Datetime.newInstance(2024, 10, 25).date(),
      accounts[0].dealDate,
      'Deal dealDate mismatch'
    );
    Assert.areEqual(
      Datetime.newInstance(2024, 10, 28).date(),
      accounts[0].valueDate,
      'Deal valueDate mismatch'
    );
  }

  @isTest
  static void testNullResponse() {
    ForeignExchangeDealExternalQuery query = new ForeignExchangeDealExternalQuery();

    Test.startTest();
    query.calloutResponse = query.parseResponse('');
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      query.calloutResponse,
      'ForeignExchangeDeal Response should be empty.'
    );
    Assert.areEqual(0, result.externalRecords.size(), 'Size of deals is not 0');
  }

  @isTest
  static void createForeignExchangeTest() {
    ForeignExchangeDealExternalQuery query = new ForeignExchangeDealExternalQuery();

    query.calloutResponse = new ForeignExchangeDealExternalQuery.ForeignExchangeDealCalloutResponse();
    ((ForeignExchangeDealExternalQuery.ForeignExchangeDealCalloutResponse) query.calloutResponse)
      .accounts = new List<ForeignExchangeDealExternalQuery.ForeignExchangeDealModel>();
    ForeignExchangeDealExternalQuery.ForeignExchangeDealModel dealModel = new ForeignExchangeDealExternalQuery.ForeignExchangeDealModel();
    dealModel.compositeAccountNumber = '42343243-72362139602';
    dealModel.dealNumber = '72362139602';
    dealModel.askPrice = 100000.00;
    dealModel.askPriceCurrency = 'USD';
    dealModel.bidPrice = 150000.00;
    dealModel.bidPriceCurrency = 'AUD';
    dealModel.dealDate = Datetime.newInstance(2024, 10, 26).date();
    dealModel.valueDate = Datetime.newInstance(2024, 10, 29).date();

    ((ForeignExchangeDealExternalQuery.ForeignExchangeDealCalloutResponse) query.calloutResponse)
      .accounts.add(dealModel);

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
      'Deal ExternalId mismatch'
    );
    Assert.areEqual(
      '72362139602',
      result.externalRecords[0].get('DealNumber'),
      'Deal number mismatch'
    );
    Assert.areEqual(
      100000.00,
      result.externalRecords[0].get('AskAmount'),
      'Deal AskPrice mismatch'
    );
    Assert.areEqual(
      'USD',
      result.externalRecords[0].get('AskCurrency'),
      'Deal AskPriceCurrency mismatch'
    );
    Assert.areEqual(
      150000.00,
      result.externalRecords[0].get('BidAmount'),
      'Deal BidPrice mismatch'
    );
    Assert.areEqual(
      'AUD',
      result.externalRecords[0].get('BidCurrency'),
      'Deal BidPriceCurrency mismatch'
    );
    Assert.areEqual(
      Datetime.newInstance(2024, 10, 26).date(),
      result.externalRecords[0].get('DealDate'),
      'Deal DealDate mismatch'
    );
    Assert.areEqual(
      Datetime.newInstance(2024, 10, 29).date(),
      result.externalRecords[0].get('ValueDate'),
      'Deal ValueDate mismatch'
    );
  }
}
