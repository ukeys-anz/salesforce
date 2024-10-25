/**
 * @author Hitesh W
 * @since  08/2023
 * @group  (Commercial CRM)
 * @description Test Class for BalanceHistoryExternalQuery
 */
@isTest
public class BalanceHistoryExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = Lib_FakeIdGenerator.getMockId(
          Account.SobjectType
        ),
        Account_Key__c = '4011643101-7234567890121234',
        FinServ__FinancialAccountNumber__c = '7234567890121234',
        Product_Type__c = 'CAP-CIS:PCA'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "balanceHistory": [' +
      '     {' +
      '       "compositeBalanceHistoryId": "Denis Lai",' +
      '       "month": "August",' +
      '       "year": "2023",' +
      '       "avgBalance": "905.57",' +
      '       "minBalance": "905.57",' +
      '       "maxBalance": "905.57"' +
      '     }' +
      '   ]' +
      ' }';

    BalanceHistoryExternalQuery balanceHistoryAcct = new BalanceHistoryExternalQuery();
    balanceHistoryAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(
      balanceHistoryAcct.calloutResponse == null,
      'Response is not null for Balance history.'
    );
  }

  @isTest
  static void testBalanceHistoryQuery() {
    registerMocks();
    Test.startTest();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createBalanceHistoryQueryContext();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock(
      'getCustomerUsingExternalIdAndRtName',
      new List<Account>()
    );
    BalanceHistoryExternalQuery balHistoryQry = new BalanceHistoryExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = balHistoryQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      result.externalRecords.size(),
      2,
      'Size of accounts is not 2'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(firstRecord.get('Month'), 'August', 'Month mismatch');
    Assert.areEqual(firstRecord.get('Year'), '2023', 'Year mismatch');
  }

  @isTest
  static void createDummyAccountRequiredTest() {
    String payloadFM = '{"accountNumber": "FM-111269467"}';
    String payloadDDA = '{"accountNumber": "DDA-111269467"}';
    String payloadRSV = '{"accountNumber": "RSV-111269467"}';
    Assert.areEqual(
      true,
      BalanceHistoryExternalQuery.isFMOrSsiOrRsvProduct(payloadFM),
      'BalanceHistoryQuery is not returning correct result for FM'
    );
    Assert.areEqual(
      false,
      BalanceHistoryExternalQuery.isFMOrSsiOrRsvProduct(payloadDDA),
      'BalanceHistoryQuery is not returning correct result for DDA'
    );
    Assert.areEqual(
      true,
      BalanceHistoryExternalQuery.isFMOrSsiOrRsvProduct(payloadRSV),
      'BalanceHistoryQuery is not returning correct result for RSV'
    );
  }

  @isTest
  static void displayDummyAccountDetailsTest() {
    Assert.areEqual(
      true,
      BalanceHistoryExternalQuery.displayDummyAccountDetails('dummyVal', ''),
      'displayDummayFinancialAccount is not returning correct result when parentId is empty'
    );
    Assert.areEqual(
      false,
      BalanceHistoryExternalQuery.displayDummyAccountDetails('', 'dummyVal'),
      'isDepositProductCategory is not returning correct result when externalId is empty'
    );
  }

  @isTest
  static void createDummyFinancialAccountDetailTest() {
    BalanceHistoryExternalQuery accQuery = new BalanceHistoryExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult dummyAcc = accQuery.createDummyFinancialAccountDetail(
      'DDA-210568745-2'
    );

    Assert.areEqual(
      'No further information available',
      dummyAcc.ExternalRecords.get(0).get('AdditionalInformation'),
      'createDummyFinancialAccounts is not returning correct result'
    );
    Assert.areEqual(
      'DDA-210568745-2',
      dummyAcc.ExternalRecords.get(0).get('ExternalId'),
      'createDummyFinancialAccounts is not returning correct result'
    );
  }

  /**
   * @description create mock QueryContext for testing
   * @return DataSource.QueryContext mock queryContext
   */
  public static DataSource.QueryContext createBalanceHistoryQueryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new BalanceHistoryExternalQueryTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'BalanceHistory'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class BalanceHistoryExternalQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_balanceHistory');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'balance-history-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
