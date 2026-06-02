/**
 * @author Naman Garg
 * @since  Oct 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AssetFinanceAssetDetailExternalQuery
 */
@isTest
private class AssetFinanceAssetDetailExternalQueryTest {
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
      '   "assetDetails": [' +
      '     {' +
      '       "assetNumber": "364931",' +
      '       "year": "2018",' +
      '       "make": "NULL",' +
      '       "model": "972M Wheel",' +
      '       "serialNumber": "M8W10249",' +
      '       "purchasePrice": "366400.0000",' +
      '       "ecvValuer": "P.McLoughlin",' +
      '       "compositePhysicalAssetId": "4020632171-162381-364930-364931"' +
      '     }' +
      '   ]' +
      ' }';

    AssetFinanceAssetDetailExternalQuery assetDet = new AssetFinanceAssetDetailExternalQuery();
    Test.startTest();
    assetDet.parseResponse(responseBody);
    Test.stopTest();
    Assert.isNotNull(assetDet.calloutResponse, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AssetFinanceAssetDetailExternalQuery assetDet = new AssetFinanceAssetDetailExternalQuery();
    Test.startTest();
    assetDet.parseResponse('');
    Test.stopTest();
    Assert.isNull(assetDet.calloutResponse, 'Response is not null');
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
      External_Id__c = 'CACHE_4011643101',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    Test.startTest();
    DataSource.QueryContext context = createQueryContext();
    AssetFinanceAssetDetailExternalQuery assetDet = new AssetFinanceAssetDetailExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = assetDet.execute(
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
      'M8W10249',
      firstRecord.get('SerialNo'),
      'SerialNo mismatch'
    );
  }

  @isTest
  static void testCreateExternalRecordsForDetailView() {
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
      External_Id__c = 'CACHE_4011643101',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    Test.startTest();
    DataSource.QueryContext context = createQueryContextForDetail();
    AssetFinanceAssetDetailExternalQuery assetDet = new AssetFinanceAssetDetailExternalQuery();
    ExternalObjectQueryBase.ExternalQueryResult result = assetDet.execute(
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
      'M8W10249',
      firstRecord.get('SerialNo'),
      'SerialNo mismatch'
    );
  }

  /**
   * @description create summary Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(
      HttpCalloutMock.class,
      new AssetFinanceAssetDetailQueryTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AssetFinanceAssetDetail'
    );
    return context;
  }

  /**
   * @description create asset detail Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContextForDetail() {
    Test.setMock(
      HttpCalloutMock.class,
      new AssetFinanceAssetDetailForDetailQueryTestMock()
    );
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'AssetFinanceAssetDetail',
      'CACHE'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AssetFinanceAssetDetailQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetDetail');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AssetFinanceAssetDetailForDetailQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_assetDetalForDetailView'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
