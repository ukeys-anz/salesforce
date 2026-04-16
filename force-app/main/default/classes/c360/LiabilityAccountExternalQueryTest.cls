/**
 * @author Mildeep Singh
 * @since  11/2025
 * @group Commercial
 * @description Liability Account external query test class
 */
@isTest
private class LiabilityAccountExternalQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CacheFinancialAccountQueryBaseRepository.class
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
          Product_Type__c = 'CACHE:LA'
        ),
        new Map<String, Object>{ 'Account_Number__c' => '3424-909811' }
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CACHE_4011643101'
      )
    );
    return mockFar;
  }

  /**
   * @description create Liability Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createLiabilityAccountQueryContext() {
    Test.setMock(HttpCalloutMock.class, new LiabilityAccountTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'LiabilityAccount'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testisng
   */
  public class LiabilityAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponses
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_liabilityResponse');
      Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(
        jsonBody
      );

      List<Object> acct = (List<Object>) jsonMap.get('accounts');
      Map<String, Object> newAccount = new Map<String, Object>{
        'accountNumber' => '12122324',
        'error' => 'ACCOUNT NOT FOUND'
      };
      acct.add(newAccount);
      jsonMap.put('accounts', acct);
      String jsonBodyFinal = JSON.serialize(jsonMap);

      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'la-success-with-multiple-accounts');
      res.setBody(jsonBodyFinal);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void createLiabilityAccountsTest() {
    registerMocks();
    StaffTokenRequestModel staffModelWrapper = new StaffTokenRequestModel();
    staffModelWrapper.anzTokenType = 'staff';
    staffModelWrapper.apiScopesRequested = 'CCRM_CACHE_360';
    staffModelWrapper.realm = 'system';
    staffModelWrapper.isSecureWafFlow = true;
    String hashedKey = AuthTokenCacheUtil.getHashedKey(
      'forgeJWTToken' + staffModelWrapper.apiScopesRequested
    );
    Cache.Session.put(
      'local.ForgeToken.' + hashedKey,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.startTest();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createLiabilityAccountQueryContext();
    LiabilityAccountExternalQuery liabilityAcct = new LiabilityAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock(
      'getIndustryNamesByCodes',
      new Map<String, String>{ '6220' => 'Test Industry' }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    ExternalObjectQueryBase.ExternalQueryResult result = liabilityAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(5, result.externalRecords.size(), 'Size of accounts is 5');
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'Liability Account 1',
      firstRecord.get('AccountName'),
      'Name should match the account returned from external source'
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
    faRepoMock.mock(
      'getIndustryNamesByCodes',
      new Map<String, String>{ '6220' => 'Test Industry' }
    );
    LiabilityAccountExternalQuery liabilityAcct = new LiabilityAccountExternalQuery();
    DataSource.QueryContext context = createLiabilityAccountQueryContext();
    Test.startTest();
    liabilityAcct.calloutResponse = new LiabilityAccountExternalQuery.LiabilityAccountCalloutResponse();
    ((LiabilityAccountExternalQuery.LiabilityAccountCalloutResponse) liabilityAcct.calloutResponse)
      .accounts = new List<LiabilityAccountModel>();
    LiabilityAccountModel liabilityModel = new LiabilityAccountModel();
    liabilityModel.accountName = 'John Doe';
    liabilityModel.accountNumber = '3424909811';
    liabilityModel.productCode = 'LA';
    liabilityAcct.prepareCallout(context, context.TableSelection);
    ((LiabilityAccountExternalQuery.LiabilityAccountCalloutResponse) liabilityAcct.calloutResponse)
      .accounts.add(liabilityModel);
    ExternalObjectQueryBase.ExternalQueryResult result = liabilityAcct.createExternalRecords(
      liabilityAcct.calloutResponse
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
    registerMocks();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    String responseBody =
      ' {' +
      '   "accounts": [' +
      '     {' +
      '       "accountName": "John Doe",' +
      '       "accountNumber": "3424909811",' +
      '       "productCode": "LA",' +
      '       "accountBalance": "50.01",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    LiabilityAccountExternalQuery liabilityAcct = new LiabilityAccountExternalQuery();
    DataSource.QueryContext context = createLiabilityAccountQueryContext();
    liabilityAcct.prepareCallout(context, context.TableSelection);
    liabilityAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(liabilityAcct.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    Test.startTest();
    LiabilityAccountExternalQuery liabilityAcct = new LiabilityAccountExternalQuery();
    liabilityAcct.parseResponse(null);
    Test.stopTest();
    Assert.isTrue(
      liabilityAcct.calloutResponse == null,
      'Response is not null'
    );
  }
}
