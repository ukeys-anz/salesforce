/**
 * @author Prahlad Bhadani
 * @since  11/2025
 * @group Platform
 * @description Demand Account external query test class
 */
@isTest
private class DemandAccountExternalQueryTest {
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
          Product_Type__c = 'CACHE:DDA'
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
   * @description create Demand Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createDemandAccountQueryContext() {
    Test.setMock(HttpCalloutMock.class, new DemandAccountTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'DemandAccount'
    );
    return context;
  }

  /**
   * @description create Loan Account Query Context and set mock response
   * @return DataSource.QueryContext
   */
  private static DataSource.QueryContext createDemandAccountDetailContext() {
    Test.setMock(HttpCalloutMock.class, new DemandAccountDetailTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'DemandAccount'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testisng
   */
  public class DemandAccountTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponses
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_demandResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-multiple-accounts');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class DemandAccountDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_demandDetailResponse');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-single-account');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  @isTest
  static void createDemandAccountsTest() {
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
    DataSource.QueryContext context = createDemandAccountQueryContext();
    DemandAccountExternalQuery demandAcct = new DemandAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    ExternalObjectQueryBase.ExternalQueryResult result = demandAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(4, result.externalRecords.size(), 'Size of accounts is 4');
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'Business Transaction Account',
      firstRecord.get('AccountName'),
      'Name should match the account returned from external source'
    );
  }

  @isTest
  static void createDemandAccountDetailTest() {
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
    DataSource.QueryContext context = createDemandAccountDetailContext();
    DemandAccountExternalQuery demandAcct = new DemandAccountExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithAcctNum',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    ExternalObjectQueryBase.ExternalQueryResult result = demandAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.externalRecords.size(), 'Size of accounts is 1');
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'High Interest Savings Account',
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
    DemandAccountExternalQuery demandAcct = new DemandAccountExternalQuery();
    DataSource.QueryContext context = createDemandAccountQueryContext();
    Test.startTest();
    demandAcct.calloutResponse = new DemandAccountExternalQuery.DemandAccountCalloutResponse();
    ((DemandAccountExternalQuery.DemandAccountCalloutResponse) demandAcct.calloutResponse)
      .accounts = new List<DemandAccountModel>();
    DemandAccountModel demandModel = new DemandAccountModel();
    demandModel.accountName = 'Denis Lai';
    demandModel.accountNumber = '3424909811';
    demandModel.productCode = 'DDA';
    demandAcct.prepareCallout(context, context.TableSelection);
    ((DemandAccountExternalQuery.DemandAccountCalloutResponse) demandAcct.calloutResponse)
      .accounts.add(demandModel);
    ExternalObjectQueryBase.ExternalQueryResult result = demandAcct.createExternalRecords(
      demandAcct.calloutResponse
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
      '       "accountName": "Denis Lai",' +
      '       "accountNumber": "3424909811",' +
      '       "productCode": "DDA",' +
      '       "accountBalance": "50.01",' +
      '       "status": "Active"' +
      '     }' +
      '   ]' +
      ' }';

    DemandAccountExternalQuery demandAcct = new DemandAccountExternalQuery();
    DataSource.QueryContext context = createDemandAccountQueryContext();
    demandAcct.prepareCallout(context, context.TableSelection);
    demandAcct.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(demandAcct.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    Test.startTest();
    DemandAccountExternalQuery demandAcct = new DemandAccountExternalQuery();
    demandAcct.parseResponse('');
    Test.stopTest();
    Assert.isTrue(demandAcct.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testPopulateStartDates() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.dates startDates = new DemandAccountModel.dates();
    model.startDates = startDates;
    startDates.data1 = Date.valueOf('2025-01-01');
    startDates.data2 = Date.valueOf('2025-01-02');
    startDates.data3 = Date.valueOf('2025-01-03');
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery()
      .populateDates(startDates, 'StartDate');
    Test.stopTest();
    Assert.areEqual(
      Date.newInstance(2025, 1, 1),
      row.get('StartDate1'),
      'start date should be populated correctly!'
    );
  }

  @isTest
  static void testPopulateExpiryDates() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.dates expiryDates = new DemandAccountModel.dates();
    model.expiryDates = expiryDates;
    expiryDates.data1 = Date.valueOf('2025-01-01');
    expiryDates.data2 = Date.valueOf('2025-01-02');
    expiryDates.data3 = Date.valueOf('2025-01-03');
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery()
      .populateDates(expiryDates, 'ExpiryDate');
    Test.stopTest();
    Assert.areEqual(
      Date.newInstance(2025, 1, 1),
      row.get('ExpiryDate1'),
      'expiry date should be populated correctly!'
    );
  }

  @isTest
  static void testPopulateCurrentGrossLimits() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.currentGrossLimits glimits = new DemandAccountModel.currentGrossLimits();
    model.currentGrossLimits = glimits;
    glimits.limit1 = 100.12;
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery().populateGrossLimits(glimits);
    Test.stopTest();
    Assert.areEqual(
      100.12,
      row.get('CurrentGrossLimit1'),
      'CurrentGrossLimit1 should be populated correctly!'
    );
  }

  @isTest
  static void testPopulatePercentageFactors() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.percentageFactors pfactors = new DemandAccountModel.percentageFactors();
    model.percentageFactors = pfactors;
    pfactors.percentageFactor1 = 2.12;
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery()
      .populatePercentageFactors(pfactors, 'PercentageFactor');
    Test.stopTest();
    Assert.areEqual(
      2.12,
      row.get('PercentageFactor1'),
      'PercentageFactor1 should be populated correctly!'
    );
  }

  @isTest
  static void testPopulateLimits() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.limits limits = new DemandAccountModel.limits();
    model.limits = limits;
    limits.limit1 = 2000.12;
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery().populateLimits(limits, 'Limit');
    Test.stopTest();
    Assert.areEqual(
      2000.12,
      row.get('Limit1'),
      'Limit1 should be populated correctly!'
    );
  }

  @isTest
  static void testPopulatePointsDifferences() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.pointsDifference pointsDifference = new DemandAccountModel.pointsDifference();
    model.pointsDifferences = pointsDifference;
    pointsDifference.pointsDifference1 = 2.5;
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery()
      .populatePointsDifferences(pointsDifference, 'PointsDifference');
    Test.stopTest();
    Assert.areEqual(
      2.5,
      row.get('PointsDifference1'),
      'PointsDifference1 should be populated correctly!'
    );
  }

  @isTest
  static void testPopulateFacilityTypes() {
    DemandAccountModel model = new DemandAccountModel();
    DemandAccountModel.facilityTypes facilityTypes = new DemandAccountModel.facilityTypes();
    model.facilityTypes = facilityTypes;
    facilityTypes.type1 = 'Test 1';
    Map<String, Object> row = new Map<String, Object>();
    Test.startTest();
    row = new DemandAccountExternalQuery().populateFacilityTypes(facilityTypes);
    Test.stopTest();
    Assert.areEqual(
      row.get('FacilityType1'),
      'Test 1',
      'FacilityType1 should be populated correctly!'
    );
  }
}
