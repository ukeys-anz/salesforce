/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description CCRMAssetFinanceELSExternalQuery test class
 */
@isTest
private class AssetFinanceELSExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    Test.startTest();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-7234567890121234',
        FinServ__FinancialAccountNumber__c = '7234567890121234',
        Product_Type__c = 'CAP-CIS:PCA'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );

    DataSource.QueryContext context = createAssetFinanceELSContext();
    AssetFinanceELSExternalQuery cardAccount = new AssetFinanceELSExternalQuery();
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    ExternalObjectQueryBase.ExternalQueryResult result = cardAccount.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Assert.areEqual(
      '431214465',
      result.externalRecords[0].get('AccountNumber'),
      'Name mismatch'
    );
  }

  /**
   * @description Create Credit Card test context
   * @name createDepositAccountContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createAssetFinanceELSContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new AssetFinanceELSExternalQueryTestMock()
    );
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AssetFinanceELS'
    );
    CoreBankingDataSourceConnection aConn = new CoreBankingDataSourceConnection(
      null
    );
    aConn.query(context);
    return context;
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class AssetFinanceELSExternalQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response for CCRMAssetFinanceELSQuery
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetFinanceELS');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'asset-fin-els');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
