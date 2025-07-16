/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group Platfrom
 * @description Salesforce connect custom adaptor connection test class
 */
@isTest
private class CoreBankingDataSourceConnectionTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }
  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = (FinServ__FinancialAccount__c) TestUtil.setFields(
        new FinServ__FinancialAccount__c(
          Name = 'Test',
          FinServ__Status__c = 'Active',
          FinServ__FinancialAccountType__c = 'Savings',
          FinServ__PrimaryOwner__c = accId,
          Account_Key__c = '4011643101-3424909811',
          FinServ__FinancialAccountNumber__c = '3424909811',
          Product_Type__c = 'CAP-CIS:DDA'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '3424-909811' }
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  @isTest
  static void testSync() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    List<DataSource.Table> result = conn.sync();
    Test.stopTest();
    Assert.areEqual(result, null, 'Result is not null');
  }

  @isTest
  static void testQuery() {
    registerMocks();
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    Test.setMock(HttpCalloutMock.class, new DepositAccountTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'DepositAccount'
    );
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    DataSource.TableResult result = conn.query(context);
    Test.stopTest();
    Assert.areEqual(result.success, true, 'Error');
    Assert.areEqual(result.tableName, 'DepositAccount', 'Error');
  }

  @isTest
  static void testQueryWithInvalidTableName() {
    DataSource.ConnectionParams connectionParams = new DataSource.ConnectionParams();
    connectionParams.principalType = DataSource.IdentityType.ANONYMOUS;
    connectionParams.protocol = DataSource.AuthenticationProtocol.NONE;
    CoreBankingDataSourceConnection conn = new CoreBankingDataSourceConnection(
      connectionParams
    );
    Test.startTest();
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'Deposit'
    );
    String exceptionMessage;
    try {
      conn.query(context);
    } catch (Exception e) {
      exceptionMessage = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      exceptionMessage,
      'Unsupported External Object : Deposit',
      'Error'
    );
  }
  /**
   * @description create HTTP mock response for testing
   */
  public class DepositAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_depositResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
