/**
 * @author @ramvilas
 * @since April 2025
 * @description Test class for RLA Loan Application actions
 */
@isTest
private class ResidentialLoanApplicationActionsTest {
  private static final String BROKER_CODE = 'TPMI123456789';
  private static final String SUNSET_STATUS = 'STATE_UNSPECIFIED';
  private static final String NON_SUNSET_STATUS = 'STATE_CAPTURE';
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider coachNudgeRepoMock;
  static Lib_MockProvider rlaRepoMock;
  static Lib_MockProvider caseRepoMock;
  static Lib_MockProvider brokerSettingsMock;
  private static final Id FAKER_CONTACT_ID = Lib_FakeIdGenerator.getMockId(
    Contact.getSObjectType()
  );
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );
  private static final Id COACH_NUDGE_RT_ID = RTTask.coachNudge;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    rlaRepoMock = Lib_MockProvider.forType(
      ResidentialLoanApplicationRepository.class
    );
    caseRepoMock = Lib_MockProvider.forType(LendingCaseRepository.class);
    brokerSettingsMock = Lib_MockProvider.forType(
      BrokerSettingsRepository.class
    );
    coachNudgeRepoMock = Lib_MockProvider.forType(LendingTaskRepository.class)
      .mock('queryActiveTaskWithRLA', createMockTaskRelatedToRla());
  }

  @isTest
  static void testLoanAppOwnerAssignment() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToInsert = createResidentialLoanApplications(
      1
    );
    // Test insert scenarios
    Test.startTest();
    ResidentialLoanApplicationActions.assignHomeLoanAppQueue(
      testLoanAppsToInsert
    );
    Test.stopTest();

    Assert.areEqual(
      testLoanAppsToInsert[0].OwnerId,
      QueryQueue.get('Home_Loan_Applications_Queue').Id,
      'Owner should be Home Loan Applications Queue'
    );
  }

  /**
   * @description
   * Scenarios:
   * 1. insert status = sunset: set timestamp
   * 2. insert status = non sunset: do not set timestamp
   */
  @IsTest
  static void testSetSunsetTimestamp() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToInsert = createResidentialLoanApplications(
      2
    );
    // Set new apps attributes
    testLoanAppsToInsert[0].Status = SUNSET_STATUS;
    testLoanAppsToInsert[1].Status = NON_SUNSET_STATUS;

    // Test insert scenarios
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.setSunsetTimestamp(
      testLoanAppsToInsert
    );
    Test.stopTest();

    // Assert
    Assert.isTrue(
      results[0].SunsetTimestamp__c.isSameDay(Date.today()),
      'Application Sunset Timestamp should be set as current date time'
    );
    Assert.isNull(
      testLoanAppsToInsert[1].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
  }

  /**
   * @description
   * Scenario:
   * 1. update from non sunset to sunset: set timestamp
   */
  @IsTest
  static void testSetEnteredSunsetTimestampPositive() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    Datetime now = System.now();
    // Set old apps attributes
    oldLoanApps[0].Status = NON_SUNSET_STATUS;

    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = SUNSET_STATUS;

    Test.startTest();
    // Test update scenarios
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.setEnteredSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();

    // Assert
    Assert.isTrue(
      results[0].SunsetTimestamp__c.isSameDay(now),
      'Application Sunset Timestamp should be set as current date time'
    );
  }

  /**
   * @description
   * Scenario:
   * 1. update from sunset to sunset: keep the timestamp no change
   */
  @IsTest
  static void testSetEnteredSunsetTimestampNegative() {
    Boolean isAvailable = false;
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    Datetime now = System.now();
    // Set old apps attributes
    oldLoanApps[0].Status = 'STATE_CANCELLED';

    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = SUNSET_STATUS;
    testLoanAppsToUpdate[0].SunsetTimestamp__c = now - 1;

    Test.startTest();
    // Test update scenarios
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.setEnteredSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();
    for (ResidentialLoanApplication res : results) {
      if (res.Id == testLoanAppsToUpdate[0].Id) {
        isAvailable = true;
        break;
      }
    }

    // Assert
    Assert.areEqual(
      now - 1,
      testLoanAppsToUpdate[0].SunsetTimestamp__c,
      'Application Sunset Timestamp should remain the same'
    );

    Assert.isFalse(
      isAvailable,
      'Sunset to Sunset status change should be filtered out'
    );
  }

  /**
   * @description
   * Scenario:
   * 1. update from sunset to non sunset: clear timestamp
   */
  @IsTest
  static void testSetExitedSunsetTimestampPositive() {
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    Datetime now = System.now();
    // Set old apps attributes
    oldLoanApps[0].Status = SUNSET_STATUS;

    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = NON_SUNSET_STATUS;
    testLoanAppsToUpdate[0].SunsetTimestamp__c = now;

    Test.startTest();
    // Test update scenarios
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.setExitedSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();

    Assert.isNull(
      results[0].SunsetTimestamp__c,
      'Application Sunset Timestamp should be cleared'
    );
  }

  /**
   * @description
   * Scenarios:
   * 1. update from non sunset to non sunset: do not set timestamp
   */
  @IsTest
  static void testSetExitedSunsetTimestampNegative() {
    Boolean isAvailable = false;
    // Test Data Prep
    List<ResidentialLoanApplication> testLoanAppsToUpdate = createResidentialLoanApplications(
      4
    );
    List<ResidentialLoanApplication> oldLoanApps = testLoanAppsToUpdate.deepClone(
      true
    );
    Map<Id, ResidentialLoanApplication> oldLoanAppMap = new Map<Id, ResidentialLoanApplication>(
      oldLoanApps
    );

    Datetime now = System.now();
    // Set old apps attributes
    oldLoanApps[0].Status = NON_SUNSET_STATUS;

    // Set new apps attributes
    testLoanAppsToUpdate[0].Status = 'STATE_CANCELLED';
    testLoanAppsToUpdate[0].SunsetTimestamp__c = now - 1;

    Test.startTest();
    // Test update scenarios
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.setExitedSunsetTimestamp(
      testLoanAppsToUpdate,
      oldLoanAppMap
    );
    Test.stopTest();
    for (ResidentialLoanApplication res : results) {
      if (res.Id == testLoanAppsToUpdate[0].Id) {
        isAvailable = true;
        break;
      }
    }

    Assert.areEqual(
      now - 1,
      testLoanAppsToUpdate[0].SunsetTimestamp__c,
      'Application Sunset Timestamp should not be set'
    );
    Assert.isFalse(
      isAvailable,
      'Non-Sunset to Non-Sunset status change should be filtered out'
    );
  }

  @isTest
  static void testCancelRelatedCreditReferralCases() {
    registerMocks();
    caseRepoMock.mock(
      'queryRelatedCreditReferralCases',
      createMockCaseRelatedToRla()
    );

    List<ResidentialLoanApplication> newRlaRecordsList = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Map<Id, ResidentialLoanApplication> newRlaRecords = new Map<Id, ResidentialLoanApplication>{
      newRlaRecordsList.get(0).Id => newRlaRecordsList.get(0)
    };

    Test.startTest();
    ResidentialLoanApplicationActions.cancelRelatedCreditReferralCases(
      newRlaRecords,
      oldRlaRecords
    );
    Test.stopTest();

    List<Case> caseRecordAfterUpdate = (List<Case>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.areEqual(
      'Closed - Cancelled',
      caseRecordAfterUpdate[0].Status,
      'The Case record status should update to Closed Cancelled'
    );
  }

  /**
   * @description Method for testing publishSyncEvents
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testPublishSyncEvents() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      10
    );
    for (ResidentialLoanApplication eachLoanApp : loanApps) {
      eachLoanApp.Sync_Status__c = 'Broker Org';
    }
    registerMocks();
    rlaRepoMock.mock('queryLoanApplications', loanApps);
    Test.startTest();
    BrokerSettings__c mockSettings = new BrokerSettings__c();
    mockSettings.BypassApplicationEvent__c = false;
    brokerSettingsMock.mock('getBrokerSettings', mockSettings);
    List<SObject> cloudEvents = ResidentialLoanApplicationActions.publishSyncEvents(
      loanApps,
      ApplicationEventActions.APPLICATION_EVENT_ADD
    );
    Test.stopTest();
    Assert.areEqual(
      10,
      cloudEvents.size(),
      '10 Cloud Events should be published'
    );
    Assert.isFalse(
      rlaRepoMock.getHistories('queryLoanApplications').isEmpty(),
      'queryLoanApplications should have been called at least once'
    );
    List<String> loanApplicationParam = (List<String>) rlaRepoMock.getHistories(
        'queryLoanApplications'
      )[0]
      .listOfParamNames;
    Assert.isFalse(
      loanApplicationParam.isEmpty(),
      'loanApplicationIds should have been passed on to the queryLoanApplications method'
    );
  }

  @IsTest
  static void testPopulateAssistedBroker() {
    Test.startTest();
    List<ResidentialLoanApplication> results = ResidentialLoanApplicationActions.populateRetailLoanAssistedBroker(
      new List<ResidentialLoanApplication>(),
      new Map<Id, ResidentialLoanApplication>()
    );
    Test.stopTest();
    Assert.isTrue(results.isEmpty(), 'Results should be empty without input');
  }

  /**
   * @description Method for testing updateApplicationSyncStatus
   * @author Deepro De | 06-03-2024
   **/
  @isTest
  static void testUpdateApplicationSyncStatus() {
    List<ResidentialLoanApplication> loanApps = createResidentialLoanApplications(
      2
    );
    loanApps[1].Sync_Status__c = 'Blocked';
    Test.startTest();
    ResidentialLoanApplicationActions.updateApplicationSyncStatus(loanApps);
    Test.stopTest();
    Assert.areEqual(
      'Blocked',
      loanApps[1].Sync_Status__c,
      'Expected Residential Loan Application Sync Status to be Blocked'
    );

    Assert.areEqual(
      'Broker Org',
      loanApps[0].Sync_Status__c,
      'Expected Residential Loan Application Sync Status to be Broker Org'
    );
  }

  @isTest
  static void testProcessCancelledRLARecords() {
    registerMocks();
    rlaRepoMock.mock(
      'queryRelatedCreditReferralCases',
      createMockCaseRelatedToRla()
    );

    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecord(
      'STATE_CANCELLED'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecord(
      'STATE_CAPTURE'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };
    List<Task> taskRecordBeforeUpdate = createMockTaskRelatedToRla();

    Test.startTest();
    ResidentialLoanApplicationActions.processCancelledRLARecords(
      newRlaRecords,
      oldRlaRecords
    );
    Test.stopTest();

    List<Task> taskRecordAfterUpdate = (List<Task>) dmlRepoMock.getHistory(
        'updateRecords'
      )
      .getParam('records');

    Assert.areEqual(
      'Not Started',
      taskRecordBeforeUpdate[0].Status,
      'The task record status should be created with "Not Started" status'
    );

    Assert.areEqual(
      'Expired',
      taskRecordAfterUpdate[0].Status,
      'The task record status should update to Expired'
    );
  }

  @isTest
  private static void testUpdateAppProgressToBlankSuccess() {
    List<ResidentialLoanApplication> rlaRecord = new List<ResidentialLoanApplication>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecordWithSubStatus(
      'STATE_CANCELLED',
      'With Coach'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecordWithSubStatus(
      'STATE_REFERRED',
      'With Coach'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecord = ResidentialLoanApplicationActions.updateApplicationProgressToBlank(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    Assert.isFalse(
      rlaRecord.isEmpty(),
      'Residential Loan Application should return to update substatus'
    );
    Assert.isNull(
      rlaRecord[0].Application_Progress__c,
      'Residential Loan Application Progress should be blank'
    );
  }

  @isTest
  private static void testUpdateAppProgressToBlankFailure() {
    List<ResidentialLoanApplication> rlaRecord = new List<ResidentialLoanApplication>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecordWithSubStatus(
      'STATE_REFERRED',
      'With Coach'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecordWithSubStatus(
      'STATE_EXPIRED',
      'With Coach'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecord = ResidentialLoanApplicationActions.updateApplicationProgressToBlank(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();
    Assert.isTrue(
      rlaRecord.isEmpty(),
      'Residential Loan Application Progress should not changed so return should be null'
    );
    Assert.areEqual(
      'With Coach',
      newRlaRecords[0].Application_Progress__c,
      'RLA Application Progress should remains same'
    );
  }

  static List<Task> createMockTaskRelatedToRla() {
    List<Task> strTasklist = new List<Task>();

    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      COACH_NUDGE_RT_ID,
      null,
      FAKER_RLA_ID,
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    strTasklist.add(coachNudgeTask);
    return strTasklist;
  }

  static List<ResidentialLoanApplication> createMockRlaRecord(String status) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
    rlaRecord.Id = FAKER_RLA_ID;
    rlaRecord.Status = status;

    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }

  static List<Case> createMockCaseRelatedToRla() {
    List<Case> strCaselist = new List<Case>();

    Case creditRefCase = TestDataFactory.createCase('Credit_Referral');
    creditRefCase.Loan_Application__c = FAKER_RLA_ID;
    strCaselist.add(creditRefCase);
    return strCaselist;
  }

  static List<ResidentialLoanApplication> createResidentialLoanApplications(
    Integer count
  ) {
    List<ResidentialLoanApplication> loanApps = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < count; i++) {
      ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication(
        String.valueOf(i + 1)
      );
      loanApp.Id = Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      );
      loanApp.Assisted_Broker_TPMI_SAO__c = BROKER_CODE;
      loanApp.Sync_Status__c = 'Broker Org';
      loanApps.add(loanApp);
    }
    return loanApps;
  }

  private static List<ResidentialLoanApplication> createMockRlaRecordWithSubStatus(
    String status,
    String appProgress
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
    rlaRecord.Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.getSObjectType()
    );
    rlaRecord.Status = status;
    rlaRecord.Application_Progress__c = appProgress;

    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }

  @IsTest
  static void testSetResidentialLoanApplicationValidityRLS() {
    registerMocks();
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.RecordTypeId = RTResidentialLoanApplication.rlsResidentialLoanApplication;
    rla.Status = 'STATE_SUBMITTED';
    Test.startTest();
    List<ResidentialLoanApplication> rlas = ResidentialLoanApplicationActions.setResidentialLoanApplicationValidity(
      new List<ResidentialLoanApplication>{ rla }
    );
    Test.stopTest();
    Date expectedDate = Date.today().addDays(60);
    Assert.areEqual(
      expectedDate,
      rlas[0].SunsetTimestamp__c,
      'Sunset Timestamp should be populated correctly.'
    );
  }

  @IsTest
  static void testSetResidentialLoanApplicationValidityNotRLS() {
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.RecordTypeId = RTResidentialLoanApplication.anzxHomeLoan;
    Test.startTest();
    List<ResidentialLoanApplication> rlas = ResidentialLoanApplicationActions.setResidentialLoanApplicationValidity(
      new List<ResidentialLoanApplication>{ rla }
    );
    Test.stopTest();
    Assert.isTrue(
      rlas[0].SunsetTimestamp__c == null,
      'Sunset Timestamp should not be populated as the record type is not RLS'
    );
  }

  @IsTest
  static void testSetResidentialLoanApplicationValidityInelgibleStatus() {
    registerMocks();
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.RecordTypeId = RTResidentialLoanApplication.rlsResidentialLoanApplication;
    rla.Status = 'STATE_NOTVALID_FOR_SUNSET_TIMESTAMP';
    Test.startTest();
    List<ResidentialLoanApplication> rlas = ResidentialLoanApplicationActions.setResidentialLoanApplicationValidity(
      new List<ResidentialLoanApplication>{ rla }
    );
    Test.stopTest();
    Assert.isTrue(
      rlas[0].SunsetTimestamp__c == null,
      'Sunset Timestamp should not be populated as no CMDT present for the status'
    );
  }
}
