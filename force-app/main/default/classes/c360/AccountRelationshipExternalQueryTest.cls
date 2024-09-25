/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for AccountRelationshipExternalQuery
 */
@isTest
private class AccountRelationshipExternalQueryTest {
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
  static void testGetSequence() {
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    Test.startTest();
    String result = accRelQry.getSequence(1);
    Test.stopTest();
    Assert.areEqual('0001', result, 'result is not 0001');
  }

  @isTest
  static void testParseResponse() {
    String responseBody =
      '{' +
      '    "accountRelationships": [' +
      '      {' +
      '        "compositeAccountRelationshipId": "DDA-901221265-0",' +
      '        "relatedPartyCustomerId": "4017120146",' +
      '        "relationshipType": "PRI"' +
      '      },' +
      '      {' +
      '        "compositeAccountRelationshipId": "DDA-901221265-1",' +
      '        "relatedPartyCustomerId": "902168950",' +
      '        "relationshipType": "CLG"' +
      '      },' +
      '      {' +
      '        "compositeAccountRelationshipId": "DDA-901221265-2",' +
      '        "relatedPartyCustomerId": "1009086103",' +
      '        "relationshipType": "TPS"' +
      '      },' +
      '      {' +
      '        "compositeAccountRelationshipId": "DDA-901221265-3",' +
      '        "relatedPartyCustomerId": "1009086140",' +
      '        "relationshipType": "TPS"' +
      '      },' +
      '      {' +
      '        "compositeAccountRelationshipId": "DDA-901221265-4",' +
      '        "relatedPartyCustomerId": "4017120167",' +
      '        "relationshipType": "SOL"' +
      '      }' +
      '    ]' +
      '  }';

    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    Test.startTest();
    accRelQry.parseResponse(responseBody);
    Test.stopTest();
    Assert.isFalse(accRelQry.calloutResponse == null, 'Response is null');
  }

  @isTest
  static void testParseResponseEmptyResponse() {
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    Test.startTest();
    accRelQry.parseResponse('');
    Test.stopTest();
    Assert.isTrue(accRelQry.calloutResponse == null, 'Response is not null');
  }

  //Integration Test
  @isTest
  static void testAccountRelationshipQuery() {
    DataSource.QueryContext context = createAccountRelationshipContextForAPI();
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accRelQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      5,
      result.externalRecords.size(),
      'Size of accounts is not 5'
    );
  }

  @isTest
  static void testCreateExternalRecords() {
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createAccountRelationshipContextForAPI();
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    accRelQry.populateData(
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    accRelQry.execute(context);
    accRelQry.calloutResponse = new AccountRelationshipExternalQuery.AccountRelationshipCalloutResponse();
    ((AccountRelationshipExternalQuery.AccountRelationshipCalloutResponse) accRelQry.calloutResponse)
      .accountRelationships = new List<AccountRelationshipExternalQuery.AccountRelationshipModel>();
    AccountRelationshipExternalQuery.AccountRelationshipModel accountRelationshipModel = new AccountRelationshipExternalQuery.AccountRelationshipModel();
    accountRelationshipModel.relatedPartyCustomerId = '4017120146';
    accountRelationshipModel.relationshipType = 'PRI';
    ((AccountRelationshipExternalQuery.AccountRelationshipCalloutResponse) accRelQry.calloutResponse)
      .accountRelationships.add(accountRelationshipModel);
    ExternalObjectQueryBase.ExternalQueryResult result = accRelQry.createExternalRecords(
      accRelQry.calloutResponse
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of accounts is not 1'
    );
  }

  @isTest
  static void createExternalRecordsBySOQLQueryTest() {
    registerMocks();
    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();
    DataSource.QueryContext context = createAccountRelationshipContextForSOQL();
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    faRepoMock.mock(
      'getRelatedCustomers',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    ExternalObjectQueryBase.ExternalQueryResult result = accRelQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.externalRecords.size(),
      'Size of related customer is not 1'
    );
  }

  @isTest
  static void getRelatedCustomersOfAccountTest() {
    registerMocks();

    //setting up mocked data
    FinServ__FinancialAccountRole__c mockFar = getMockedData();

    createAccountRelationshipContextForSOQL();
    AccountRelationshipExternalQuery accRelQry = new AccountRelationshipExternalQuery();
    faRepoMock.mock(
      'getRelatedCustomers',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    List<FinServ__FinancialAccountRole__c> roles = accRelQry.getRelatedCustomersOfAccount(
      'CAP-CIS_4011643101-234500817',
      new Set<String>{ 'UNO' }
    );
    Test.stopTest();
    Assert.areEqual(1, roles.size(), 'No related customers found');
  }
  /**
   * @description create account relationship Query Context and set mock response
   * @return queryContext
   */
  public static DataSource.QueryContext createAccountRelationshipContextForAPI() {
    Test.setMock(HttpCalloutMock.class, new AccountRelationshipQueryTestMock());
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContext(
      'AccountRelationship'
    );
    return context;
  }

  /**
   * @description Create Account Relationship test context for SOQL
   * @name createAccountRelationshipContextForSOQL
   * @return Returns DataSource.QueryContext context
   */
  public static DataSource.QueryContext createAccountRelationshipContextForSOQL() {
    //query
    DataSource.QueryContext context = ExternalQueryContextMock.createQueryContextForSOQL(
      'AccountRelationship'
    );
    return context;
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AccountRelationshipQueryTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_accountRelationship');
      HTTPResponse res = new HTTPResponse();
      res.setHeader('example', 'account-relationship-query');
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}