/**
 * @author Hitesh W
 * @since  08/2023
 * @group CCRM (Commercial CRM)
 * @description Test Class for CCRMAccountRelationshipQuery
 */
@isTest
private class CCRMAccountRelationshipQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void testGetSequence() {
    Test.startTest();
    CCRMAccountRelationshipQuery accRelQry = new CCRMAccountRelationshipQuery();
    String result = accRelQry.getSequence(1);
    Test.stopTest();
    Assert.areEqual('0001', result, 'result is not 0001');
  }

  @isTest
  static void testAccountRelationshipQuery() {
    Test.startTest();
    DataSource.QueryContext context = CCRMTestDataFactory.createAccountRelationshipContextForAPI();
    CCRMAccountRelationshipQuery accRelQry = new CCRMAccountRelationshipQuery();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accRelQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(5, result.queryResult.size(), 'Size of accounts is not 5');
  }

  @isTest
  static void testAccountRelationshipQueryWithSOQL() {
    registerMocks();
    Test.startTest();
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
    DataSource.QueryContext context = CCRMTestDataFactory.createAccountRelationshipContextForSOQL();
    CCRMAccountRelationshipQuery accRelQry = new CCRMAccountRelationshipQuery();
    faRepoMock.mock(
      'getRelatedCustomers',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accRelQry.execute(
      context
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      result.queryResult.size(),
      'Size of related customer is not 1'
    );
  }

  @isTest
  static void getRelatedCustomersOfAccountTest() {
    registerMocks();
    Test.startTest();
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

    CCRMAccountRelationshipQuery accRelQry = new CCRMAccountRelationshipQuery();
    faRepoMock.mock(
      'getRelatedCustomers',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );

    List<FinServ__FinancialAccountRole__c> roles = accRelQry.getRelatedCustomersOfAccount(
      'CAP-CIS_4011643101-234500817',
      new Set<String>{ 'UNO' }
    );
    Test.stopTest();
    Assert.areEqual(1, roles.size(), 'No related customers found');
  }
}
