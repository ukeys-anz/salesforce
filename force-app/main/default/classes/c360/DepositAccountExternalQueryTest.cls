/**
 * @author Ian Huang
 * @since  07/2025
 * @group Platform
 * @description Deposit Account external query test class
 */
@isTest
private class DepositAccountExternalQueryTest {
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

  /**
   * @description create Deposit Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createDepositAccountQueryContext() {
    Test.setMock(HttpCalloutMock.class, new DepositAccountTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'DepositAccount'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testisng
   */
  public class DepositAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponses
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

  @isTest
  static void createDepositAccountsTest() {
    registerMocks();
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    ExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(2, result.externalRecords.size(), 'Size of accounts is 2');
    Map<String, Object> firstRecord = result.externalRecords[0];
    Map<String, Object> secondRecord = result.externalRecords[1];
    Assert.areEqual(
      'VAALEPU CORP. NOMINEES TR',
      firstRecord.get('AccountName'),
      'Name should match the account returned from external source'
    );
    Assert.areEqual(
      'Error: 1212-12324 ACCOUNT NOT FOUND',
      secondRecord.get('AccountName'),
      'Account not found error as Account is deleted from sources'
    );
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    Test.startTest();
    depositAcct.calloutResponse = new DepositAccountExternalQuery.DepositAccountCalloutResponse();
    ((DepositAccountExternalQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts = new List<DepositAccountExternalQuery.DepositAccountModel>();
    DepositAccountExternalQuery.DepositAccountModel depositModel = new DepositAccountExternalQuery.DepositAccountModel();
    depositModel.accountName = 'Denis Lai';
    depositModel.accountNumber = '3424909811';
    depositModel.productCode = 'DDA';
    depositAcct.prepareCallout(context, context.TableSelection);
    ((DepositAccountExternalQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts.add(depositModel);
    ExternalObjectQueryBase.ExternalQueryResult result = depositAcct.createExternalRecords(
      depositAcct.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void testParseResponse() {
    Test.startTest();
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "accountName": "Denis Lai",' +
      '       "accountNumber": "3424909811",' +
      '       "productCode": "DDA",' +
      '       "accountBalance": "50.01",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(depositAcct.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    Test.startTest();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.parseResponse('');
    Test.stopTest();
    Assert.isTrue(depositAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testPopulateSeasonalLimits() {
    Map<String, Object> row = new Map<String, Object>();
    List<DepositAccountExternalQuery.SeasonalLimits> seasonalLimits = new List<DepositAccountExternalQuery.SeasonalLimits>();
    seasonalLimits.add(
      new DepositAccountExternalQuery.SeasonalLimits(
        1.0,
        DateTime.newInstance(2014, 5, 26, 0, 0, 0),
        DateTime.newInstance(2099, 5, 26, 0, 0, 0)
      )
    );
    seasonalLimits.add(
      new DepositAccountExternalQuery.SeasonalLimits(
        2.0,
        DateTime.newInstance(2015, 5, 26, 0, 0, 0),
        DateTime.newInstance(2099, 5, 26, 0, 0, 0)
      )
    );
    seasonalLimits.add(
      new DepositAccountExternalQuery.SeasonalLimits(3.0, null, null)
    );

    Test.startTest();
    DepositAccountExternalQuery depositQuery = new DepositAccountExternalQuery();
    row = depositQuery.populateSeasonalLimits(row, seasonalLimits);
    Test.stopTest();
    Assert.areEqual(5, row.size(), 'Size of SeasonalLimits is not 5');
  }
}
