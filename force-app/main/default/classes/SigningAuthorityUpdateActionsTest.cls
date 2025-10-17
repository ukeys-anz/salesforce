/**
 * @description       : Test class for SigningAuthUpdateActions class
 * @author            : Sanskriti Routray
 * @group             :
 * @last modified on  : 19-09-2025
 **/
@isTest
public with sharing class SigningAuthorityUpdateActionsTest {
  private static final Id FAKER_ACCOUNT_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_FIN_ACCOUNT_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  private static final Id FAKER_USER_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    User.getSObjectType()
  );
  private static final Id FAKER_MANAGER_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    User.getSObjectType()
  );

  private static Lib_MockProvider dmlRepoMock;
  private static Id anzxProfile = CommonUtil.getProfileByName(
      'ANZx Standard User'
    )
    .Id;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    Lib_MockProvider.forType(SigningAuthorityUpdateRepository.class)
      .mock('getFinancialAccountsWithCaseId', getFinAccounts());
    Lib_MockProvider.forType(SigningAuthorityUpdateRepository.class)
      .mock('getManagerInfo', getUser());
  }

  private static List<FinServ__FinancialAccount__c> getFinAccounts() {
    List<FinServ__FinancialAccount__c> finAccounts = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c();
    finAccount.Name = 'Everyday Account';
    finAccount.FinServ__Balance__c = 400;
    finAccount.FinServ__CurrentPostedBalance__c = 400;
    finAccount.FinServ__Status__c = 'Active';
    finAccount.RecordTypeId = RTFinancialAccount.checkingAccount;
    finAccount.FinServ__PrimaryOwner__c = FAKER_ACCOUNT_RECORD_ID;
    finAccount.Account_Key__c = '123456789';
    finAccount.FinServ__FinancialAccountNumber__c = '123';
    finAccount.Number_Of_Signatures__c = '1';
    finAccount.Id = FAKER_FIN_ACCOUNT_RECORD_ID;
    finAccounts.add(finAccount);
    return finAccounts;
  }

  private static List<Case> getOpenSignAuthCases() {
    List<Case> openCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.signAuth;
    record.Status = 'Open';
    record.Type = 'Change to All to Sign';
    openCases.add(record);
    return openCases;
  }

  private static List<Case> getOldSignAuthCases() {
    List<Case> openCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.signAuth;
    record.AccountId = FAKER_ACCOUNT_RECORD_ID;
    record.Status = 'Open';
    record.Type = 'Change to Any to Sign';
    record.FinServ__FinancialAccount__c = FAKER_FIN_ACCOUNT_RECORD_ID;
    openCases.add(record);
    return openCases;
  }

  private static List<User> getManagerUser() {
    List<User> managerUsers = new List<User>();
    User managerUser = new User();
    managerUser.Id = FAKER_MANAGER_RECORD_ID;
    managerUser.FirstName = 'Test';
    managerUser.LastName = 'Manager User';
    managerUser.isActive = true;
    managerUser.ProfileId = anzxProfile;
    managerUsers.add(managerUser);
    return managerUsers;
  }

  private static List<User> getUser() {
    List<User> oldUsers = new List<User>();
    User oldUser = new User();
    oldUser.Id = FAKER_USER_RECORD_ID;
    oldUser.FirstName = 'Test';
    oldUser.LastName = 'User';
    oldUser.isActive = true;
    oldUser.ProfileId = anzxProfile;
    oldUser.ManagerId = getManagerUser()[0].Id;
    oldUsers.add(oldUser);
    return oldUsers;
  }

  @isTest
  private static void testSetSubject() {
    registerMocks();
    List<Case> records = getOpenSignAuthCases();
    Test.startTest();
    SigningAuthorityUpdateActions.setSubject(records);
    Test.stopTest();
    Assert.isTrue(
      records[0].Subject == 'Signing Authority Update ',
      'Case subject should be default value - Signing Authority Update '
    );
  }

  @isTest
  private static void testSetSubjectForUpdate() {
    registerMocks();
    List<Case> records = getOpenSignAuthCases();
    records[0].FinServ__FinancialAccount__c = FAKER_FIN_ACCOUNT_RECORD_ID;

    Test.startTest();
    SigningAuthorityUpdateActions.setSubject(records);
    Test.stopTest();
    Assert.isTrue(
      records[0].Subject == 'Signing Authority Update - 123',
      'Case subject should be default value - Signing Authority Update + account number'
    );
  }

  @isTest
  private static void testDereferenceFA() {
    List<Case> records = getOpenSignAuthCases();
    records[0].FinServ__FinancialAccount__c = FAKER_FIN_ACCOUNT_RECORD_ID;
    List<Case> oldRecords = getOldSignAuthCases();
    Test.startTest();
    SigningAuthorityUpdateActions.dereferenceFA(
      records,
      new Map<Id, Case>{ records[0].Id => oldRecords[0] }
    );
    Test.stopTest();
    Assert.isTrue(
      records[0].FinServ__FinancialAccount__c == null,
      'Financial Account on Case should be removed when there is a change in Type'
    );
  }

  @isTest
  private static void testCaseEscalationUpdate() {
    registerMocks();
    List<Case> records = getOpenSignAuthCases();
    records[0].SLA_Status__c = 'Breached';
    records[0].OwnerId = getUser()[0].Id;
    String managerId = getManagerUser()[0].Id;
    List<Case> oldRecords = getOldSignAuthCases();
    Test.startTest();
    SigningAuthorityUpdateActions.caseEscalationUpdate(
      records,
      new Map<Id, Case>{ records[0].Id => oldRecords[0] }
    );
    Test.stopTest();
    Assert.isTrue(
      records[0].OwnerId == managerId,
      'Case Owner should be updated to Case Owner Manager when SLA Status is Breached'
    );
  }
}
