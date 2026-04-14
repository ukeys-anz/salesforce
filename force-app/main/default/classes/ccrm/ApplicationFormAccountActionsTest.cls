/**
 * @author  Akanksha Kulkarni
 * @description Test class for ApplicationFormAccountActions
 */
@IsTest
private class ApplicationFormAccountActionsTest {
  static Lib_MockProvider appFormRepoMock = Lib_MockProvider.forType(
    ApplicationFormEventRepository.class
  );
  static Lib_MockProvider dmlRepoMock;

  private static final String PERSONACC_RECORDTYPEID = Schema.SObjectType.Account
    .getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  /*
   * @description Test method for accountSyncStatusUpdate
   */
  @IsTest
  static void testAccountSyncStatusUpdate() {
    // Create accounts
    Map<Id, Account> accMap = createCustomerAccount(2);

    // Create ApplicationForm records
    Map<Id, ApplicationForm> appFormMap = createApplicationForms(
      accMap.keySet()
    );

    // Mock repository method
    appFormRepoMock.mock('queryApplicationFormCustomer', appFormMap.values());

    // Mock DML Repository
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);

    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"500xx00000TESTAAA","success":true,"errors":[]}'
      )
    };

    dmlRepoMock.mock('doUpdate', saveResults);

    Test.startTest();
    ApplicationFormAccountActions.accountSyncStatusUpdate(appFormMap.keySet());
    Test.stopTest();

    // Verify update call
    List<Account> updatedAccounts = (List<Account>) dmlRepoMock
      .getHistory('doUpdate')
      .getParam('records');

    System.assertEquals(
      2,
      updatedAccounts.size(),
      'Should update two account records'
    );

    System.assertEquals(
      ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG,
      updatedAccounts[0].Sync_Status__c,
      'Sync status should be set to Broker Org'
    );
  }

  /*
   * @description Test method for updateAccountSyncStatus
   */
  @IsTest
  static void testUpdateAccountSyncStatus() {
    Map<Id, Account> accMap = createCustomerAccount(3);

    Map<Id, ApplicationForm> appForms = createApplicationForms(accMap.keySet());

    Test.startTest();
    List<Account> updatedAccounts = ApplicationFormAccountActions.updateAccountSyncStatus(
      appForms.values()
    );
    Test.stopTest();

    System.assertEquals(
      3,
      updatedAccounts.size(),
      'All application forms should map to account updates'
    );

    System.assertEquals(
      ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG,
      updatedAccounts[0].Sync_Status__c,
      'Account sync status must be Broker Org'
    );
  }

  /*
   * @description Test Method to create Customer Accounts
   */
  static Map<Id, Account> createCustomerAccount(Integer count) {
    Map<Id, Account> accountMap = new Map<Id, Account>();

    for (Integer i = 0; i < count; i++) {
      Account acc = TestDataFactory.createAccount(false);
      acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      acc.RecordTypeId = PERSONACC_RECORDTYPEID;
      acc.External_Id__c = 'EXT' + i;
      accountMap.put(acc.Id, acc);
    }
    return accountMap;
  }

  /*
   * @description Test Method to create ApplicationForm records
   */
  static Map<Id, ApplicationForm> createApplicationForms(Set<Id> accountIds) {
    Map<Id, ApplicationForm> appFormMap = new Map<Id, ApplicationForm>();

    for (Id accId : accountIds) {
      ApplicationForm appForm = new ApplicationForm();
      appForm.Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
      appForm.AccountId = accId;

      appFormMap.put(appForm.Id, appForm);
    }
    return appFormMap;
  }
}
