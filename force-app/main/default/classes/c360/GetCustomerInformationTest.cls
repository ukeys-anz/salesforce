@IsTest
public class GetCustomerInformationTest {
  static Lib_MockProvider customerRepoMock;
  static void registerMocks() {
    customerRepoMock = Lib_MockProvider.forType(
      GetCustomerInformationRepo.class
    );
  }

  @isTest
  static void testgetFinancialAccounts() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    String customerOcv = '1234';
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.FinServ__PrimaryOwner__c = accId;
    financialAccount.Account_Key__c = 'AccountKey_20010101';
    financialAccount.FinServ__FinancialAccountType__c = 'CAP-CIS:DDA';
    financialAccount.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SObjectType
    );
    FinServ__FinancialAccountRole__c faObj = new FinServ__FinancialAccountRole__c();
    faObj.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.SObjectType
    );
    faObj.FinServ__FinancialAccount__r = new FinServ__FinancialAccount__c(
      Name = 'Test',
      FinServ__Status__c = 'Active',
      FinServ__PrimaryOwner__c = accId,
      Account_Key__c = 'AccountKey_20010101',
      FinServ__FinancialAccountType__c = 'CAP-CIS:DDA'
    );
    faObj.FinServ__RelatedAccount__r = new Account(Id = accId);
    faObj.Role_Type__c = 'SOL';

    customerRepoMock.mock(
      'getFinancialAccounts',
      new List<FinServ__FinancialAccountRole__c>{ faObj }
    );
    List<FinServ__FinancialAccountRole__c> faAccountList = GetCustomerInformation.fetchCustomerFinancialAccounts(
      accId,
      customerOcv
    );
    Test.startTest();
    Assert.isTrue(
      !faAccountList.isEmpty(),
      'Financial Accounts should not be empty'
    );
    Test.stopTest();
  }
}
