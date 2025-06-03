@IsTest
private with sharing class UpdateCustomerInformationTest {
  static Lib_MockProvider customerRepoMock;
  static void registerMocks() {
    customerRepoMock = Lib_MockProvider.forType(ComplaintsRepository.class);
  }

  @isTest
  static void testgetFinancialAccounts() {
    registerMocks();
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      PersonOtherPostalCode = '234567',
      PersonOtherCountry = 'AUS'
    );
    Case caseObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = accObj.id,
      recordtypeId = RTCase.generalInquiryCmos
    );
    customerRepoMock.mock(
      'findAccountsByAccountIds',
      (new List<Account>{ accObj })
    );

    Test.startTest();
    UpdateCustomerInformation.updateCustomer(new List<Case>{ caseObj });
    Assert.isTrue(
      caseObj.IDR_CC_Postcode__c == '234567',
      'Customer Information should be updated'
    );
    Test.stopTest();
  }

  @isTest
  static void testgetFinancialBusinessAccounts() {
    registerMocks();
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      BillingPostalCode = '234567',
      BillingCountry = 'AUS'
    );
    Case caseObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = accObj.id,
      recordtypeId = RTCase.generalInquiryCmos
    );
    customerRepoMock.mock(
      'findAccountsByAccountIds',
      (new List<Account>{ accObj })
    );

    Test.startTest();
    UpdateCustomerInformation.updateCustomer(new List<Case>{ caseObj });
    Assert.isTrue(
      caseObj.IDR_CC_Postcode__c == '234567',
      'Customer Information should be updated'
    );
    Test.stopTest();
  }

  @isTest
  static void testupdateCustomerInfoToNull() {
    registerMocks();
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount
    );
    Case caseObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = accObj.id,
      recordtypeId = RTCase.generalInquiryCmos
    );
    customerRepoMock.mock(
      'findAccountsByAccountIds',
      (new List<Account>{ accObj })
    );

    Test.startTest();
    UpdateCustomerInformation.updateCustomer(new List<Case>{ caseObj });
    Assert.isTrue(
      String.isBlank(caseObj.IDR_CC_Postcode__c),
      'Customer Information should be blank'
    );
    Test.stopTest();
  }
}
