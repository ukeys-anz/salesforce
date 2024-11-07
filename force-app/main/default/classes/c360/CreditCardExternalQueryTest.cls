/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platform
 * @description Credit card Account external query test class
 */
@isTest
private class CreditCardExternalQueryTest {
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
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
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

    DataSource.QueryContext context = createCreditCardContext();
    CreditCardExternalQuery cardAccount = new CreditCardExternalQuery();
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
      'Tom Hanks',
      result.externalRecords[0].get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '7234-5678-9012-1234',
      result.externalRecords[0].get('AccountNumber'),
      'Name mismatch'
    );
    Assert.areEqual(
      'A - Agent',
      result.externalRecords[0].get('BlockCode1'),
      'block code should be A - Agent!'
    );
    Assert.areEqual(
      'B - Bankrupt',
      result.externalRecords[0].get('BlockCode2'),
      'block code should be B - Bankrupt!'
    );
  }

  @isTest
  static void getProductCodeTest() {
    registerMocks();
    Test.startTest();
    String accId = (String) Lib_FakeIdGenerator.getMockId(
      Account.getSobjectType()
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());

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

    DataSource.QueryContext context = createCreditCardContext();
    CreditCardExternalQuery cardAccount = new CreditCardExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    cardAccount.execute(context);
    CreditCardExternalQuery.CreditCardModel cardModel = new CreditCardExternalQuery.CreditCardModel();
    cardModel.accountNumber = '7234567890121234';
    cardModel.accountName = 'Tom Hanks';
    cardModel.productCode = 'PCA';
    cardModel.status = 'Active';
    String productCode = cardAccount.getProductCode(cardModel);
    Test.stopTest();
    Assert.areEqual('PCA', productCode, 'Product code mismatch');
  }

  /**
   * @description Create Credit Card test context
   * @name createDepositAccountContext
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createCreditCardContext() {
    Test.setMock(HttpCalloutMock.class, new CreditCardQueryTestMock());
    //sync
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      null
    );
    conn.sync();
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'CreditCard'
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
  public class CreditCardQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_creditCardResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'pcb-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
