/**
 * @author Deepro De
 * @since August 2024
 * @description Test class for LoanApplicantActions
 */
@isTest
private class LoanApplicantActionsTest {
  private static final String PERSONACC_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();
  static Lib_MockProvider laRepoMock = Lib_MockProvider.forType(
    LoanApplicantRepository.class
  );
  static Lib_MockProvider dmlRepoMock;

  /*
   * @description method to test SynchronizeAndUpdateCustomerSyncStatus method
   */
  @isTest
  static void testSynchronizeAndUpdateCustomerSyncStatus() {
    Map<Id, Account> accMap = createCustomerAccount(3);
    List<ResidentialLoanApplication> rlaList = createResidentialLoanApplications(
      1
    );
    Map<Id, LoanApplicant> loanAppIdVsRecordMap = createLoanApplicants(
      accMap.keySet(),
      rlaList.get(0)
    );
    laRepoMock.mock('queryAccounts', accMap.values());
    laRepoMock.mock(
      'queryLoanApplicationOfApplicants',
      loanAppIdVsRecordMap.values()
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };
    dmlRepoMock.mock('updateRecords', saveResults);
    Test.startTest();
    LoanApplicantActions.synchronizeAndUpdateCustomerSyncStatus(
      loanAppIdVsRecordMap.keySet()
    );
    Test.stopTest();
    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords should have been called.'
    );
  }

  /*
   * @description method to test updateAccountSyncStatus method
   */
  @isTest
  static void updateAccountSyncStatusTest() {
    Map<Id, Account> accMap = createCustomerAccount(5);
    List<ResidentialLoanApplication> rlaList = createResidentialLoanApplications(
      1
    );
    Map<Id, LoanApplicant> loanAppIdVsRecordMap = createLoanApplicants(
      accMap.keySet(),
      rlaList.get(0)
    );
    Test.startTest();
    List<Account> accounts = LoanApplicantActions.updateAccountSyncStatus(
      loanAppIdVsRecordMap.values()
    );
    Test.stopTest();
    Assert.areEqual(
      accounts.size(),
      loanAppIdVsRecordMap.size(),
      'All 5 account record Sync Status should be mapped as Broker Org'
    );
  }

  /*
   * @description Test Method to create Customers
   */
  static Map<Id, Account> createCustomerAccount(Integer count) {
    Map<Id, Account> accountIdVsRecordMap = new Map<Id, Account>();
    for (Integer i = 0; i < count; i++) {
      Account acc = TestDataFactory.createAccount(false);
      acc.External_Id__c = 'Test0001' + i;
      acc.OCV_Event_Version__c = 1;
      acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      acc.RecordTypeId = PERSONACC_RECORDTYPEID;
      accountIdVsRecordMap.put(acc.Id, acc);
    }
    return accountIdVsRecordMap;
  }

  /*
   * @description Test Method to create ResidentialLoanApplication
   */
  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = new ResidentialLoanApplication(
        Name = 'TestLoanApplication',
        Status = 'STATE_CONFIRMED',
        InterestRate = 7.50,
        ApplicationExtIdentifier = '20000000',
        Last_Updated_Date__c = Date.today(),
        Expiry_Date__c = Date.today().addDays(30),
        Assisted_Broker_TPMI_SAO__c = '1232344' + i,
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        )
      );
      loanApps.add(loanApp);
    }
    return loanApps;
  }

  /*
   * @description Test Method to create LoanApplicants
   */
  static Map<Id, LoanApplicant> createLoanApplicants(
    Set<Id> accSet,
    ResidentialLoanApplication loanApp
  ) {
    Map<Id, LoanApplicant> loanAppIdVsRecordMap = new Map<Id, LoanApplicant>();
    for (Id eachAccId : accSet) {
      LoanApplicant loanApplicantObj = new LoanApplicant();
      loanApplicantObj.Name = 'Test Applicant';
      loanApplicantObj.LoanApplication = loanApp;
      loanApplicantObj.LoanApplication.Assisted_Broker_TPMI_SAO__c = '123345';
      loanApplicantObj.Account__c = eachAccId;
      loanApplicantObj.Id = Lib_FakeIdGenerator.getMockId(
        LoanApplicant.SObjectType
      );
      loanAppIdVsRecordMap.put(loanApplicantObj.Id, loanApplicantObj);
    }
    return loanAppIdVsRecordMap;
  }
}
