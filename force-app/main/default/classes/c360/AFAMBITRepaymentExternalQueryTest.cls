/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description AF AMBIT Repayment external query test class
 */
@isTest
private class AFAMBITRepaymentExternalQueryTest {
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
      '   "repayments": [' +
      '     {' +
      '       "accountNumber": "NULL",' +
      '       "type": "15103",' +
      '       "frequency": 2601,' +
      '       "amount": "14513.0600",' +
      '       "startDate": "2017-03-27",' +
      '       "numberOfRepayments": 1,' +
      '       "compositeAssetRepaymentId": "4020632171-58887-127578-0"' +
      '     }' +
      '   ]' +
      ' }';

    AFAMBITRepaymentExternalQuery accountQuery = new AFAMBITRepaymentExternalQuery();
    Test.startTest();
    accountQuery.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(accountQuery.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AFAMBITRepaymentExternalQuery accountQuery = new AFAMBITRepaymentExternalQuery();
    Test.startTest();
    accountQuery.parseResponse('');
    Test.stopTest();
    Assert.isNull(accountQuery.calloutResponse, 'Response is not null');
  }

  @isTest
  static void createAssetRepaymentDetailTest() {
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
    DataSource.QueryContext context = createQueryContext();
    AFAMBITRepaymentExternalQuery accountQuery = new AFAMBITRepaymentExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
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
      1,
      firstRecord.get('TotalNumberOfRepayments'),
      'TotalNumberOfRepayments mismatch'
    );
  }

  /**
   * @description create Deposit Account Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AFAMBITRepaymentTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AFAMBITRepayment'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITRepaymentTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_assetRepaymentDetail');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
