/**
 * @author Ayushi Gupta
 * @since  07/2023
 * @group CCRM (Commercial CRM)
 * @description Test class for Active Indemnity Guarantee external query class
 */
@isTest
private class CCRMActiveIndemnityGuaranteeQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void createActiveIndemnityAccountsTest() {
    registerMocks();
    Test.startTest();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    FinServ__FinancialAccountRole__c mockFar = createMockData();
    DataSource.QueryContext context = CCRMTestDataFactory.createActiveIndemnityGuaranteeContext();
    CCRMActiveIndemnityGuaranteeQuery accountQuery = new CCRMActiveIndemnityGuaranteeQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    assert.areEqual(1, result.queryResult.size(), 'Size of accounts is 1');
  }

  private static FinServ__FinancialAccountRole__c createMockData() {
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    FinServ__FinancialAccountRole__c mockFar = new FinServ__FinancialAccountRole__c(
      FinServ__Active__c = true,
      Role_Type__c = 'UNO',
      FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
        Name = 'Test',
        FinServ__Status__c = 'Active',
        FinServ__FinancialAccountType__c = 'Savings',
        FinServ__PrimaryOwner__c = accId,
        Account_Key__c = '4011643101-391102388',
        FinServ__FinancialAccountNumber__c = '391102388',
        Product_Type__c = 'CAP-CIS:ILS'
      ),
      FinServ__RelatedAccount__r = new Account(
        External_Id__c = 'CAP-CIS_4011643101'
      )
    );
    return mockFar;
  }
  @isTest
  static void getPayloadForEBDChildAccountsTest() {
    String result;
    CCRMActiveIndemnityGuaranteeQuery accountQuery = new CCRMActiveIndemnityGuaranteeQuery();
    accountQuery.parentId = '4022196691-72344723601';
    accountQuery.parent = 'GuaranteeId';
    Test.startTest();
    result = accountQuery.getPayloadForEBDChildAccounts('');
    Test.stopTest();
    Assert.areEqual(
      '{"compositeAccountNumber": "4022196691-72344723601","fieldSet": "ACTIVE_GUARANTEES"}',
      result,
      'Payload is empty'
    );
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CCRMActiveIndemnityGuaranteeTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_activeIGResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
