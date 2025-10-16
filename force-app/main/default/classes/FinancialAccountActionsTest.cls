/**
 * @author Hrushikesh
 * @since 09/2025
 * @description Test class for FinancialAccountActions
 */
@isTest
public with sharing class FinancialAccountActionsTest {
  private static final Id FAKER_ACCOUNT_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  private static final Id FAKER_FIN_ACCOUNT_RECORD_ID = Lib_FakeIdGenerator.getMockId(
    FinServ__FinancialAccount__c.getSObjectType()
  );

  private static Lib_MockProvider dmlRepoMock;
  private static Lib_MockProvider finAccountRepo;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    finAccountRepo = Lib_MockProvider.forType(FinancialAccountRepository.class)
      .mock('getOpenSignAuthCasesByFinacialAccount', getOpenSignAuthCases());
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

  private static List<FinServ__FinancialAccount__c> getOldFinAccounts() {
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
    finAccount.Number_Of_Signatures__c = '2';
    finAccount.Id = FAKER_FIN_ACCOUNT_RECORD_ID;
    finAccounts.add(finAccount);
    return finAccounts;
  }

  private static List<Case> getOpenSignAuthCases() {
    List<Case> openCases = new List<Case>();
    Case record = new Case();
    record.RecordTypeId = RTCase.signAuth;
    record.AccountId = FAKER_ACCOUNT_RECORD_ID;
    record.Status = SigningAuthorityUpdateActions.CASE_STATUS_UNDER_INVESTIGATION;
    record.Sub_Status__c = SigningAuthorityUpdateActions.CASE_SUB_STATUS_PROCESSING;
    record.Type = 'Change to All to Sign';
    record.FinServ__FinancialAccount__c = FAKER_FIN_ACCOUNT_RECORD_ID;
    openCases.add(record);
    return openCases;
  }

  // method to test Case status update if related Case is Under Investigation
  @isTest
  private static void testPostitiveUpdateSigningAuthorityCases() {
    registerMocks();
    List<FinServ__FinancialAccount__c> records = getFinAccounts();
    List<FinServ__FinancialAccount__c> oldRecord = getOldFinAccounts();

    Test.startTest();
    FinancialAccountActions.updateSigningAuthorityCases(
      records,
      new Map<Id, FinServ__FinancialAccount__c>{ records[0].Id => oldRecord[0] }
    );
    Test.stopTest();
    List<Case> caseRecords = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(
      caseRecords[0].Status == SigningAuthorityUpdateActions.CASE_STATUS_CLOSED,
      'Case status should be Closed'
    );
    Assert.isTrue(
      caseRecords[0].Sub_Status__c ==
      SigningAuthorityUpdateActions.CASE_SUB_STATUS_SUCCESS,
      'Case status should be Closed'
    );
  }

  @isTest
  private static void testNegativeUpdateSigningAuthorityCases() {
    registerMocks();
    List<FinServ__FinancialAccount__c> records = getFinAccounts();
    List<FinServ__FinancialAccount__c> oldRecord = getFinAccounts();

    Test.startTest();
    FinancialAccountActions.updateSigningAuthorityCases(
      records,
      new Map<Id, FinServ__FinancialAccount__c>{ records[0].Id => records[0] }
    );
    Test.stopTest();
    List<Case> caseRecords = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(caseRecords.size() == 0, 'Case status should be Closed');
  }
}
