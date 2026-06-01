/**
 * @author Naman Garg
 * @since  Oct 2024
 * @group CCRM (Commercial CRM)
 * @description Test class of AssetDetailELSExternalQuery
 */
@isTest
private class AssetDetailELSExternalQueryTest {
  static Lib_MockProvider faRepoMock;

  static void registerMocks() {
    faRepoMock = Lib_MockProvider.forType(
      FinancialAccountQueryBaseRepository.class
    );
  }

  private static FinServ__FinancialAccountRole__c getMockedData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);

    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = 'CAP-CIS_4011643101-234500817',
        FinServ__FinancialAccountNumber__c = '234500817',
        Product_Type__c = 'CAP-CIS:DDA'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }

  @isTest
  static void testParseResponse() {
    String responseBody =
      ' {' +
      '   "assets": [' +
      '     {' +
      '       "manufacturedYear": "8",' +
      '       "make": "TOYOTA",' +
      '       "model": "HILUX SR 4x",' +
      '       "serialNumber": "2TR6507723",' +
      '       "purchasePrice": "13990",' +
      '       "compositePhysicalAssetId": "4011643101-431214465-0"' +
      '     }' +
      '   ]' +
      ' }';

    AssetDetailELSExternalQuery assetDetELS = new AssetDetailELSExternalQuery();
    Test.startTest();
    assetDetELS.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(assetDetELS.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AssetDetailELSExternalQuery assetDetELS = new AssetDetailELSExternalQuery();
    Test.startTest();
    assetDetELS.parseResponse('');
    Test.stopTest();
    Assert.isTrue(assetDetELS.calloutResponse == null, 'Response is not null');
  }

  @isTest
  static void testCreateExternalRecords() {
    registerMocks();
    Account acc = new Account(
      External_Id__c = 'CAP-CIS_4011643101',
      Source_System_Name__c = 'CAP-CIS'
    );
    faRepoMock.mock('getCustomerUsingExternalId', new List<Account>{ acc });
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createQueryContext();
    AssetDetailELSExternalQuery assetDetELS = new AssetDetailELSExternalQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    faRepoMock.mock('getCustomerUsingExternalIdAndRtName', new List<Account>());
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = assetDetELS.execute(
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
      13990,
      firstRecord.get('PurchasePrice'),
      'PurchasePrice mismatch'
    );
  }

  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createQueryContext() {
    Test.setMock(HttpCalloutMock.class, new AssetDetailELSQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AssetDetailELS'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AssetDetailELSQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_assetDetailELSResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
