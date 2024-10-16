/**
 * @author Ayushi Gupta
 * @since  09/2023
 * @group CCRM (Commercial CRM)
 * @description Test class of CCRMInactiveIndemnityGuaranteeQuery
 */
@isTest
private class CCRMInactiveIndemnityGuaranteeQueryTest {
  static Lib_MockProvider faRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    faRepoMock = Lib_MockProvider.forType(
      CCRMFinancialAccountQueryBaseRepository.class
    );
  }

  @isTest
  static void createInactiveIndemnityAccountsTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SobjectType);
    FinServ__FinancialAccountRole__c mockFar = createMockData();
    DataSource.QueryContext context = CCRMTestDataFactory.createInactiveIndemnityGuaranteeContext();
    CCRMInactiveIndemnityGuaranteeQuery accountQuery = new CCRMInactiveIndemnityGuaranteeQuery();
    faRepoMock.mock(
      'getFinancialAccountsWithCustomerId',
      new List<FinServ__FinancialAccountRole__c>{ mockFar }
    );
    Test.startTest();
    CCRMExternalObjectQueryBase.ExternalQueryResult result = accountQuery.execute(
      context
    );
    Test.stopTest();
    assert.areEqual(1, result.queryResult.size(), 'Size of accounts is 1');
    assert.areEqual(
      'FIN',
      result.queryResult[0].get('PurposeCode'),
      'PurposeCode matched'
    );
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
}
