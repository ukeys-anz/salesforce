/**
 * @author Ayushi Gupta
 * @since  Sept 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AFAMBITContractExternalQuery
 */
@isTest
private class AFAMBITContractExternalQueryTest {
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
      '   "contracts": [' +
      '     {' +
      '       "contractNumber": "190",' +
      '       "accountNumber": "24",' +
      '       "status": "End - Terminated",' +
      '       "dateOpened": "2014-10-22",' +
      '       "expiryDate": "2018-10-22",' +
      '       "termsInMonth": "4 Months",' +
      '       "termsInYear": "0 Years",' +
      '       "amountFinanced": 468012.18,' +
      '       "govtGuarantee": "YES",' +
      '       "productCode": "AMB050",' +
      '       "facilityDesc": "Chattel Mortgage Fixed Rate",' +
      '       "interestType": "Fixed",' +
      '       "interestRate": 6.53127482,' +
      '       "compositeContractNumber": "1011137670-24-190"' +
      '     }' +
      '   ]' +
      ' }';

    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    contract.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(contract.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    contract.parseResponse('');
    Test.stopTest();
    Assert.isTrue(contract.calloutResponse == null, 'Response is not null');
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
    DataSource.QueryContext context = createQueryContext();
    AFAMBITContractExternalQuery contract = new AFAMBITContractExternalQuery();
    Test.startTest();
    Account acc = new Account(
      External_Id__c = 'CACHE_4011643101',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    ExternalObjectQueryBase.ExternalQueryResult result = contract.execute(
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
      'CACHE_1011137670-24-190',
      firstRecord.get('ExternalId'),
      'External Id mismatch'
    );
    Assert.areEqual(
      '24',
      firstRecord.get('AccountNumber'),
      'Account Number mismatch'
    );
  }

  @isTest
  static void createAFAmbitAccountDetailTest() {
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
    DataSource.QueryContext context = createAFAmbitDetailContext();
    AFAMBITContractExternalQuery contractAcct = new AFAMBITContractExternalQuery();
    Account acc = new Account(
      External_Id__c = 'CACHE_4011643101',
      Source_System_Name__c = 'CACHE'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    ExternalObjectQueryBase.ExternalQueryResult result = contractAcct.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(1, result.externalRecords.size(), 'Size of accounts is 1');
    Map<String, Object> firstRecord = result.externalRecords[0];
    Assert.areEqual(
      'Complete Activated',
      firstRecord.get('Status'),
      'Status should match the account returned from external source'
    );
  }

  /**
   * @description create AF AMBIT summary Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AFAMBITContractQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AFAMBITContract'
    );
    return context;
  }

  /**
   * @description create AF AMBIT Detail Query Context and set mock response
   * @return DataSource.QueryContext
   */
  private static DataSource.QueryContext createAFAmbitDetailContext() {
    Test.setMock(HttpCalloutMock.class, new AFAMBITContractDetailTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextWithExternalId(
      'AFAMBITContract',
      'CACHE'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITContractQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_contract');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AFAMBITContractDetailTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_contractDetailResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setHeader('ms2-example', 'dda-success-with-single-account');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
