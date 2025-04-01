@IsTest
public class GetCustomerInformationTest {
     
    static Lib_MockProvider customerRepoMock;
    static void registerMocks() {
    customerRepoMock = Lib_MockProvider.forType(GetCustomerInformationRepo.class);
  }
    
   @isTest
  static void testgetFinancialAccounts() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.FinServ__PrimaryOwner__c = accId;
    financialAccount.Account_Key__c = 'AccountKey_20010101';
    financialAccount.FinServ__FinancialAccountType__c ='CAP-CIS:DDA';
    financialAccount.Id = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.SObjectType
    );
    customerRepoMock.mock('getFinancialAccounts', new List<FinServ__FinancialAccount__c>{ financialAccount });
    List<FinServ__FinancialAccount__c> faAccountList=GetCustomerInformation.fetchCustomerFinancialAccounts(accId);
    Test.startTest();
     Assert.isTrue(
      !faAccountList.isEmpty(),
          'Financial Accounts should not be empty'
      );
     Test.stopTest();
  }

}