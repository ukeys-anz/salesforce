/**
 * @author Ayushi Gupta
 * @since  07/2023
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
  //Integration test
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
    ExternalObjectQueryBase.ExternalQueryResult result = depositAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'Denis Lai',
      firstRecord.get('AccountName'),
      'Name mismatch'
    );
    Assert.areEqual(
      '3424-909811',
      firstRecord.get('AccountNumber'),
      'Number mismatch'
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
  static void testCreateExternalRecords() {
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    depositAcct.execute(context);
    depositAcct.calloutResponse = new DepositAccountExternalQuery.DepositAccountCalloutResponse();
    ((DepositAccountExternalQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts = new List<DepositAccountExternalQuery.DepositAccountModel>();
    DepositAccountExternalQuery.DepositAccountModel depositModel = new DepositAccountExternalQuery.DepositAccountModel();
    depositModel.accountName = 'Denis Lai';
    depositModel.accountNumber = '3424909811';
    ((DepositAccountExternalQuery.DepositAccountCalloutResponse) depositAcct.calloutResponse)
      .accounts.add(depositModel);
    ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) depositAcct.calloutResponse)
      .customerId = 'CAP-CIS_4011643101';
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

  @isTest
  static void getProductCodeTest() {
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    depositAcct.execute(context);

    DepositAccountExternalQuery.DepositAccountModel accountModel = new DepositAccountExternalQuery.DepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String productCode = depositAcct.getProductCode(accountModel);
    Test.stopTest();
    Assert.areEqual('DDA', productCode, 'Product code mismatch');
  }
  @isTest
  static void getExternalIdTest() {
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap = depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    depositAcct.execute(context);
    DepositAccountExternalQuery.DepositAccountModel accountModel = new DepositAccountExternalQuery.DepositAccountModel();
    accountModel.accountNumber = '3424909811';
    accountModel.accountName = 'Denis Lai';
    accountModel.productCode = 'DDA';
    accountModel.status = 'Active';
    String externalId = depositAcct.getExternalId(accountModel, accountRoleMap);
    Test.stopTest();
    Assert.isFalse(
      externalId.contains('ILS-3424909811'),
      'external id mismatch'
    );
  }

  @isTest
  static void getAccountKeyTest() {
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Map<String, FinServ__FinancialAccountRole__c> accountRoleMap = depositAcct.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    depositAcct.execute(context);
    String accountKey = depositAcct.getAccountKey(
      '3424909811',
      'DDA',
      accountRoleMap
    );
    Test.stopTest();
    Assert.areEqual(
      '4011643101-3424909811|DDA-3424909811',
      accountKey,
      'account Key mismatch'
    );
  }

  @isTest
  static void getPayloadForSingleAccountTest() {
    String result;
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.externalId = 'CAP-CIS_107130129985-234500817|DDA-234500817';
    Test.startTest();
    result = depositAcct.getPayloadForSingleAccount('');
    Test.stopTest();
    Assert.areEqual(
      '{"accountNumber": "DDA-234500817"}',
      result,
      'Payload is empty'
    );
  }

  @isTest
  static void getCAPSummaryAccountsTest() {
    HttpCalloutResponse response;
    ARNCService.FinancialAccountQueryParameters queryParams;
    createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Test.startTest();
    response = depositAcct.getCAPSummaryAccounts(
      new ARNCService(),
      queryParams,
      ''
    );
    Test.stopTest();
    Assert.isFalse(response == null, 'response is blank');
  }

  @isTest
  static void getDetailAccountsTest() {
    HttpCalloutResponse response;
    createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Test.startTest();
    response = depositAcct.getDetailAccounts(
      new ARNCService(),
      '{"accountNumber": "DDA-234500817"}',
      response
    );
    Test.stopTest();
    Assert.isFalse(response == null, 'response is blank');
  }

  @isTest
  static void createDummyFinancialAccountTest() {
    ExternalObjectQueryBase.ExternalQueryResult result;
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.externalId = 'CAP-CIS_107130129985-234500817|DDA-234500817';
    Test.startTest();
    result = depositAcct.createDummyExternalRecord(
      depositAcct.externalId,
      new Map<String, Object>()
    );
    Test.stopTest();
    Assert.isFalse(result == null, 'Failed to create DummyExternalRecord');
  }

  @isTest
  static void isFMOrSsiOrRsvProductTest() {
    String payloadFM = '{"accountNumber": "FM-111269467"}';
    String payloadDDA = '{"accountNumber": "DDA-111269467"}';
    Assert.areEqual(
      true,
      DepositAccountExternalQuery.isFMOrSsiOrRsvProduct(payloadFM),
      'isFMOrSsiOrRsvProduct is not returning correct result for FM'
    );
    Assert.areEqual(
      false,
      DepositAccountExternalQuery.isFMOrSsiOrRsvProduct(payloadDDA),
      'isFMOrSsiOrRsvProduct is not returning correct result for DDA'
    );
  }
  @isTest
  static void testParseFiltersWithParentId() {
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.QueryModeEnum enumMode = depositAcct.parseFilters(
      'CustomerId',
      context.tableSelection
    );
    Test.stopTest();
    Assert.areEqual(
      ExternalObjectQueryBase.QueryModeEnum.RELATED_LIST,
      enumMode,
      'Enum Mode is not related list'
    );
  }
  @isTest
  static void testParseFiltersWithExternalId() {
    Test.setMock(HttpCalloutMock.class, new DepositAccountTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'DepositAccount'
    );
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.QueryModeEnum enumMode = depositAcct.parseFilters(
      'ExternalId',
      context.tableSelection
    );
    Test.stopTest();
    Assert.areEqual(
      ExternalObjectQueryBase.QueryModeEnum.RECORD_DETAIL,
      enumMode,
      'Enum Mode is not record detail'
    );
  }
  @isTest
  static void testGetParentName() {
    DataSource.QueryContext context = createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    Test.startTest();
    String parentName = depositAcct.getParentName(context.tableSelection);
    Test.stopTest();
    Assert.areEqual('CustomerId', parentName, 'Parent is not customer');
  }
  @isTest
  static void displayDummyFinancialAccountTest() {
    createDepositAccountQueryContext();
    DepositAccountExternalQuery depositAcct = new DepositAccountExternalQuery();
    depositAcct.accountNumber = 'SSI-3535555';
    Test.startTest();
    Boolean result = depositAcct.displayDummyRecord();
    Test.stopTest();
    Assert.areEqual(true, result, 'Product Code is not FM or SSI');
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
  @isTest
  static void getFinancialAccountsWhenParentIdIsNotBlankForMLUserTest() {
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(mlUser) {
      Test.startTest();
      FinServ__FinancialAccountRole__c mockFar = getMockedData();
      DataSource.QueryContext context = createDepositAccountQueryContext();
      DepositAccountExternalQuery query = new DepositAccountExternalQuery();
      query.populateData(new List<FinServ__FinancialAccountRole__c>{ mockFar });
      query.execute(context);
      query.calloutResponse = new DepositAccountExternalQuery.DepositAccountCalloutResponse();
      ((DepositAccountExternalQuery.DepositAccountCalloutResponse) query.calloutResponse)
        .accounts = new List<DepositAccountExternalQuery.DepositAccountModel>();
      DepositAccountExternalQuery.DepositAccountModel depositModel = new DepositAccountExternalQuery.DepositAccountModel();
      depositModel.accountName = 'Denis Lai';
      depositModel.accountNumber = '3424909811';

      ((DepositAccountExternalQuery.DepositAccountCalloutResponse) query.calloutResponse)
        .accounts.add(depositModel);
      ((FinancialAccountQueryBase.FinancialAccountCalloutResponse) query.calloutResponse)
        .customerId = 'CAP-CIS_4011643101';
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
}
