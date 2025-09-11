@IsTest
private with sharing class UpdateCustomerInformationTest {
  static Lib_MockProvider customerRepoMock;
  static Lib_MockProvider userInfoRepoMock;
  static void registerMocks() {
    customerRepoMock = Lib_MockProvider.forType(ComplaintsRepository.class);
    userInfoRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  @isTest
  static void testgetFinancialAccounts() {
    registerMocks();
    userInfoRepoMock.mock('checkProfile', false);
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
    userInfoRepoMock.mock('checkProfile', false);
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
    userInfoRepoMock.mock('checkProfile', false);
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
  @isTest
  static void testupdateCustomerInfoToNoAccess() {
    registerMocks();
    userInfoRepoMock.mock('checkProfile', true);
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      BillingPostalCode = '234567'
    );
    Case caseObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      AccountId = accObj.id,
      recordtypeId = RTCase.generalInquiryCmos
    );
    Test.startTest();
    UpdateCustomerInformation.updateCustomer(new List<Case>{ caseObj });
    Assert.isTrue(
      String.isBlank(caseObj.IDR_CC_Postcode__c),
      'No Updates for no Access User'
    );
    Test.stopTest();
  }

  @isTest
  static void testupdateCustomerInfoShippingAddress() {
    registerMocks();
    userInfoRepoMock.mock('checkProfile', false);
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      ShippingPostalCode = '234567',
      ShippingCountry = 'AUS'
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
    Test.stopTest();
    Assert.isTrue(
      caseObj.IDR_CC_Country__c == 'AUS',
      'Shipping country should be retrieved'
    );
    Assert.isTrue(
      caseObj.IDR_CC_Postcode__c == '234567',
      'Shipping Postal Code should be retrieved'
    );
  }
  @isTest
  static void testupdateCustomerInfoNoRelatedAccount() {
    registerMocks();
    userInfoRepoMock.mock('checkProfile', false);
    Account accObj = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      RecordTypeId = RTAccount.businessAccount,
      ShippingPostalCode = '234567'
    );
    Case caseObj = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      recordtypeId = RTCase.generalInquiryCmos
    );
    customerRepoMock.mock(
      'findAccountsByAccountIds',
      (new List<Account>{ accObj })
    );
    Test.startTest();
    UpdateCustomerInformation.updateCustomer(new List<Case>{ caseObj });
    Test.stopTest();
    Assert.isTrue(
      String.isBlank(caseObj.IDR_CC_Postcode__c),
      'No Updates as Account and Case are not releated'
    );
  }
}
