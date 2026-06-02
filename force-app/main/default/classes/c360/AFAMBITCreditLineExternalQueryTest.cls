/**
 * @author Naman Garg
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AFAMBITCreditLineExternalQuery
 */
@isTest
private class AFAMBITCreditLineExternalQueryTest {
  static Lib_MockProvider faRepoMock;

  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }
  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "creditLines": [' +
      '     {' +
      '       "productName": "AMB050",' +
      '       "status": "Quote Expired",' +
      '       "accountName": "D E QUARRY SOLUTIONS",' +
      '       "compositeCreditLineId": "1011137670-146515-4092"' +
      '     }' +
      '   ]' +
      ' }';

    AFAMBITCreditLineExternalQuery assetFin = new AFAMBITCreditLineExternalQuery();
    Test.startTest();
    assetFin.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(assetFin.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AFAMBITCreditLineExternalQuery assetFin = new AFAMBITCreditLineExternalQuery();
    Test.startTest();
    assetFin.parseResponse('');
    Test.stopTest();
    Assert.isTrue(assetFin.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
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
    Account acc = new Account(
      External_Id__c = 'CACHE_1011137670',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    AFAMBITCreditLineExternalQuery assetFin = new AFAMBITCreditLineExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = assetFin.execute(
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
      'CACHE_1011137670-146515-4092',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '4092',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  @isTest
  static void testCreateExternalRecordsForDetail() {
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
    Account acc = new Account(
      External_Id__c = 'CACHE_1011137670',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    Test.startTest();
    DataSource.QueryContext context = createDetailQueryContext();
    AFAMBITCreditLineExternalQuery assetFin = new AFAMBITCreditLineExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = assetFin.execute(
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
      'CACHE_4011643101-391102388',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AFAMBITCreditLineQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AFAMBITCreditLine'
    );
    return context;
  }

  /**
   * @description create af ambit credit line detail Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createDetailQueryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new AFAMBITCreditLineQueryDetailTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'AFAMBITCreditLine',
      'CACHE'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITCreditLineQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetFinanceAMBIT');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITCreditLineQueryDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_AmbitCreditLineDetail');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
