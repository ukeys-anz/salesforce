/**
 * @author Ian Huang
 * @since  12/2024
 * @group platform
 * @description Trade Finance external query test class
 */
@isTest
private class TradeFinanceExternalQueryTest {
  @isTest
  static void testPrepareCallout() {
    TradeFinanceExternalQuery query = new TradeFinanceExternalQuery();
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'TradeFinance'
    );
    Test.startTest();
    FinancialAccountEntities.FinancialAccountCalloutRequest request = (FinancialAccountEntities.FinancialAccountCalloutRequest) query.prepareCallout(
      context,
      context.tableSelection
    );
    Test.stopTest();

    Assert.areEqual(
      'tradefinance-otl',
      request.productCategory,
      'productCategory mismatch'
    );
    Assert.areEqual(
      'tradefinance-otl-accounts',
      request.getEndpoint(),
      'Endpoint mismatch'
    );
    Assert.areEqual(
      '{"pageSize":"11","offSet":"0","capCustomerIds":["4011643101"]}',
      request.getPayload(),
      'Payload mismatch'
    );
    Assert.areEqual(true, request.isSummaryRequest(), 'QueryMode mismatch');
  }

  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "compositeAccountNumber": "42343243-72362139602",' +
      '       "accountNumber": "72362139602",' +
      '       "capAccountLimit": "300000.00",' +
      '       "currencyCode": "USD",' +
      '       "interestRate": "10.00",' +
      '       "originalLimit": "15000.00",' +
      '       "expiryDate": "2024-11-25",' +
      '       "OLLAccountNumber": "7246221122303",' +
      '       "productCode": "OTL",' +
      '       "productDescription": "Trade Finance Account",' +
      '       "sequenceNumber": "1",' +
      '       "subProductCode": "OTL-123",' +
      '       "term": "24"' +
      '     }' +
      '   ]' +
      ' }';

    TradeFinanceExternalQuery query = new TradeFinanceExternalQuery();
    Test.startTest();
    query.calloutResponse = query.parseResponse(responseBody);
    Test.stopTest();

    List<TradeFinanceExternalQuery.TradeFinanceModel> accounts = ((TradeFinanceExternalQuery.TradeFinanceCalloutResponse) query.calloutResponse)
      .accounts;
    Assert.areEqual(1, accounts.size(), 'TradeFinance Response is empty.');
    Assert.areEqual(
      '42343243-72362139602',
      accounts[0].compositeAccountNumber,
      'TradeFinance compositeAccountNumber mismatch'
    );
    Assert.areEqual(
      '72362139602',
      accounts[0].accountNumber,
      'TradeFinance Account number mismatch'
    );
    Assert.areEqual(
      300000,
      accounts[0].capAccountLimit,
      'TradeFinance capLimit mismatch'
    );
    Assert.areEqual(
      'USD',
      accounts[0].currencyCode,
      'TradeFinance currencyCode mismatch'
    );
    Assert.areEqual(
      10,
      accounts[0].interestRate,
      'TradeFinance interestRate mismatch'
    );
    Assert.areEqual(
      15000,
      accounts[0].originalLimit,
      'TradeFinance limit mismatch'
    );
    Assert.areEqual(
      Datetime.newInstance(2024, 11, 25).date(),
      accounts[0].expiryDate,
      'TradeFinance limitExpiry mismatch'
    );
    Assert.areEqual(
      '7246221122303',
      accounts[0].OLLAccountNumber,
      'TradeFinance OLLAccountNumber mismatch'
    );
    Assert.areEqual(
      'OTL',
      accounts[0].productCode,
      'TradeFinance productCode mismatch'
    );
    Assert.areEqual(
      'Trade Finance Account',
      accounts[0].productDescription,
      'TradeFinance productDescription mismatch'
    );
    Assert.areEqual(24, accounts[0].term, 'TradeFinance Term mismatch');
  }

  @isTest
  static void testNullResponse() {
    TradeFinanceExternalQuery query = new TradeFinanceExternalQuery();

    Test.startTest();
    query.calloutResponse = query.parseResponse('');
    ExternalObjectQueryBase.ExternalQueryResult result = query.createExternalRecords(
      query.calloutResponse
    );
    Test.stopTest();

    Assert.areEqual(
      null,
      query.calloutResponse,
      'TradeFinance Response should be empty.'
    );
    Assert.areEqual(
      0,
      result.externalRecords.size(),
      'Size of accounts is not 0'
    );
  }

  @isTest
  static void createTradeFinanceTest() {
    TradeFinanceExternalQuery query = new TradeFinanceExternalQuery();

    query.calloutResponse = new TradeFinanceExternalQuery.TradeFinanceCalloutResponse();
    ((TradeFinanceExternalQuery.TradeFinanceCalloutResponse) query.calloutResponse)
      .accounts = new List<TradeFinanceExternalQuery.TradeFinanceModel>();
    TradeFinanceExternalQuery.TradeFinanceModel tfModel = new TradeFinanceExternalQuery.TradeFinanceModel();
    tfModel.compositeAccountNumber = '42343243-72362139602';
    tfModel.accountNumber = 'TLP29284324032';
    tfModel.ollAccountNumber = '7246221122303';
    tfModel.productCode = 'OTL';
    tfModel.originalLimit = 200000.00;
    tfModel.capAccountLimit = 500000.00;
    tfModel.expiryDate = Datetime.newInstance(2024, 11, 30).date();
    tfModel.InterestRate = 10.01;
    tfModel.term = 36;
    ((TradeFinanceExternalQuery.TradeFinanceCalloutResponse) query.calloutResponse)
      .accounts.add(tfModel);

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
      'TLP29284324032',
      result.externalRecords[0].get('AccountNumber'),
      'Account number mismatch'
    );
    Assert.areEqual(
      '7246221122303',
      result.externalRecords[0].get('OLLAccountNumber'),
      'OLL Account number mismatch'
    );
    Assert.areEqual(
      'OTL',
      result.externalRecords[0].get('ProductCode'),
      'ProductCode mismatch'
    );
    Assert.areEqual(
      200000.00,
      result.externalRecords[0].get('Limit'),
      'Limit mismatch'
    );
    Assert.areEqual(
      500000.00,
      result.externalRecords[0].get('CAPLimit'),
      'capAccountLimit mismatch'
    );
    Assert.areEqual(
      Datetime.newInstance(2024, 11, 30).date(),
      result.externalRecords[0].get('LimitExpiry'),
      'LimitExpiry mismatch'
    );
    Assert.areEqual(
      10.01,
      result.externalRecords[0].get('InterestRate'),
      'InterestRate mismatch'
    );
    Assert.areEqual(36, result.externalRecords[0].get('Term'), 'Term mismatch');
  }
}
