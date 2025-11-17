/**
 * @author CMOS
 * @date 03/2024
 * @description Test class for {@link IDRCaseActionsHelper}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class IDRCaseActionsHelperTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider caseRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    caseRepoMock = Lib_MockProvider.forType(IDRCaseActionsRepository.class);
  }
  static Case caseRecord1 = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ON_HOLD_STATUS
    ),
    new Map<String, List<SObject>>{
      'Tasks' => new List<Task>{
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Date_Case_on_Hold_From__c = Date.TODAY(),
          Status = IDRConstants.OPEN_STATUS,
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Type = IDRConstants.TASK_TYPE_PEND_CASE
        )
      }
    }
  );

  static Case caseRecord2 = new Case(
    Id = caseRecord1.Id,
    Status = IDRConstants.ESCALATED_STATUS
  );

  static Case caseRecord3 = new Case(
    Id = caseRecord1.Id,
    Status = IDRConstants.REOPENED_STATUS
  );

  static Case caseRecord4 = new Case(
    Id = caseRecord1.Id,
    Status = IDRConstants.UNDER_INVESTIGATION_STATUS
  );

  static Case shellCaseRecord = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.generalInquiryCmos,
    Priority = IDRConstants.CASE_PRIORITY_STANDARD
  );

  static Account accountRecord = (Account) TestUtil.setFields(
    new Account(Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
    new Map<String, Object>{
      'Cases' => new List<Case>{
        new Case(
          Id = shellCaseRecord.Id,
          RecordTypeId = RTCase.customerComplaint,
          Priority = IDRConstants.CASE_PRIORITY_STANDARD
        )
      }
    }
  );

  /**
   * @description Generating PendTask for testing
   * @return Task
   */
  public static Task generatePendTask() {
    Task taskRecord = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Status = IDRConstants.OPEN_STATUS,
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      Type = IDRConstants.TASK_TYPE_PEND_CASE
    );
    return taskRecord;
  }

  @isTest
  static void testHardshipUpdateDateTimeFlagUpdated() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Id = caseRecordId;

    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.IDR_Is_Hardship_Resolution_Letter_Sent__c = 'Test1';
    newCase.IDR_Final_Letter_Outcome__c = 'Test2';
    newCase.Id = caseRecordId;

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      newCase,
      oldCase
    );

    System.assertNotEquals(null, dt, 'Date/time flag should be updated');
  }

  @isTest
  static void testHardshipUpdateDateTimeFlagNotUpdated() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Id = caseRecordId;

    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.Id = caseRecordId;

    Datetime dt = IDRCaseActionsHelper.populateHardshipUpdateDate(
      newCase,
      oldCase
    );

    System.assertEquals(null, dt, 'Date/time flag should be null');
  }

  @isTest
  static void testPopulateDateCaseAllocatedToCM() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ID userRecordID = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID userRecordID2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID groupRecordID = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Case caseRecord = IDRTestDataFactory.createComplaint();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = IDRTestDataFactory.createComplaint();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = IDRTestDataFactory.createComplaint();
    caseRecord2.Id = caseRecordId;
    caseRecord2.OwnerId = groupRecordID;
    DateTime dt1 = IDRCaseActionsHelper.populateDateCaseAllocatedToCM(
      caseRecord1,
      caseRecord
    );
    DateTime dt2 = IDRCaseActionsHelper.populateDateCaseAllocatedToCM(
      caseRecord2,
      caseRecord
    );

    System.assertNotEquals(null, dt1, 'Date/time flag should be updated');
    System.assertEquals(
      null,
      dt2,
      'DateTime must be blank if user is updated to a group'
    );
  }
  @isTest
  static void testPopulateOldOwnerID() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ID userRecordID = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID userRecordID2 = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    ID groupRecordID = Lib_FakeIdGenerator.getMockId(Group.SObjectType);
    Case caseRecord = IDRTestDataFactory.createComplaint();
    caseRecord.Id = caseRecordId;
    caseRecord.OwnerId = userRecordID;
    Case caseRecord1 = IDRTestDataFactory.createComplaint();
    caseRecord1.Id = caseRecordId;
    caseRecord1.OwnerId = userRecordID2;
    Case caseRecord2 = IDRTestDataFactory.createComplaint();
    caseRecord2.Id = caseRecordId;
    caseRecord2.OwnerId = groupRecordID;
    ID pco = IDRCaseActionsHelper.populateOldOwnerID(caseRecord1, caseRecord);
    System.assertEquals(
      userRecordID,
      pco,
      'Previous Case Owner must be User Record 1'
    );
  }

  @isTest
  static void testpopulateAfcaRegistrationResponseDate() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Id = caseRecordId;
    oldCase.IDR_AFCA_Registration_Response_Provided__c = false;
    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.Id = caseRecordId;
    newCase.IDR_AFCA_Registration_Response_Provided__c = true;
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      oldCase,
      newCase
    );
    System.assertNotEquals(
      null,
      responseProvided,
      'Date/time flag should be updated'
    );
  }

  @isTest
  static void testAfcaDueDateNotPopulate() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Id = caseRecordId;
    oldCase.IDR_AFCA_Registration_Response_Provided__c = false;
    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.Id = caseRecordId;
    newCase.IDR_AFCA_Registration_Response_Provided__c = false;
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      oldCase,
      newCase
    );
    System.assertEquals(
      null,
      responseProvided,
      'Date/time flag should be null'
    );
  }
  @isTest
  static void testAfcaDueDatewithResponseUncheckedPopulate() {
    Id caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Id = caseRecordId;
    oldCase.IDR_AFCA_Registration_Response_Provided__c = true;
    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.Id = caseRecordId;
    newCase.IDR_AFCA_Registration_Response_Provided__c = false;
    DateTime responseProvided = IDRCaseActionsHelper.populateAfcaRegistrationResponseDate(
      oldCase,
      newCase
    );
    System.assertEquals(
      null,
      responseProvided,
      'Date/time flag should be null'
    );
  }

  @isTest
  static void testIdentifyCaseStatusChange() {
    Case testCase1 = caseRecord1;
    Case testCase2 = caseRecord2;
    Case testCase3 = caseRecord3;
    Case testCase4 = caseRecord4;

    Test.startTest();
    Map<Id, Case> caseMap = IDRCaseActionsHelper.identifyCaseStatusChange(
      new List<Case>{ testCase2, testCase3 },
      new Map<Id, Case>{ testCase1.Id => testCase1 }
    );
    Map<Id, Case> caseMap1 = IDRCaseActionsHelper.identifyCaseStatusChange(
      new List<Case>{ testCase4 },
      new Map<Id, Case>{ testCase1.Id => testCase1 }
    );
    Test.stopTest();

    System.assertEquals(1, caseMap.size(), 'Map should return 1 case');
    System.assertEquals(
      IDRConstants.ESCALATED_STATUS,
      testCase2.Status,
      'Status should be updated to Escalated'
    );
    System.assertnotEquals(
      1,
      caseMap1.size(),
      'Map should not return any case'
    );
    System.assertnotEquals(
      IDRConstants.ESCALATED_STATUS,
      testCase4.Status,
      'Status should not be updated to Escalated'
    );
  }

  @isTest
  static void testSetTaskStatustoCompleted() {
    Task taskRecord = generatePendTask();
    taskRecord.Status = IDRConstants.TASK_STATUS_COMPLETED;

    Test.startTest();
    List<Task> tasks = IDRCaseActionsHelper.setTaskstatustoCompleted(
      new List<Task>{ taskRecord }
    );
    Test.stopTest();

    System.assertEquals(
      IDRConstants.TASK_STATUS_COMPLETED,
      tasks[0].Status,
      'Task Status should be set to Completed'
    );
  }

  @isTest
  static void testUpdateTaskStatustoCompleted() {
    registerMocks();
    Case testCase1 = caseRecord1;
    Case testCase2 = caseRecord2;
    Case testCase3 = caseRecord3;

    Task taskRecord = testCase1.Tasks[0];
    taskRecord.WhatId = testCase1.Id;

    caseRepoMock.mock('queryPendTasks', new List<task>{ taskRecord });

    Test.startTest();
    IDRCaseActionsHelper.updateTaskStatustoCompleted(
      new List<Case>{ testCase2, testCase3 },
      new Map<Id, Case>{ testCase1.Id => testCase1 }
    );

    Test.stopTest();

    List<Task> tasks = (List<Task>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');

    System.assertEquals(1, tasks.size(), '1 Task should be updated');

    System.assertEquals(
      IDRConstants.TASK_STATUS_COMPLETED,
      tasks[0].Status,
      'Task Status should be updated to Completed'
    );
  }
  /**
   * @description Test logging when case is created.
   */
  @isTest
  static void testLogCaseCreation() {
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      IDRCaseActionsHelper.logCaseCreation(
        Lib_FakeIdGenerator.getMockId(Case.getSObjectType())
      );
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
    }

    Assert.isfalse(exceptionThrown, 'No Exceptions thrown while logging info');
  }
  /**
   * @description Test logging error when  case creation failed.
   */
  @isTest
  static void testLogCaseError() {
    try {
      Test.startTest();
      IDRCaseActionsHelper.logCaseError('Status');
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual(
        'Required field is missing or invalid:' + ' ' + 'Status',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }
  /**
   * @description Test logging error when ocv failed.
   */
  @isTest
  static void testLogOCVError() {
    try {
      Test.startTest();
      IDRCaseActionsHelper.logOCVError('OCV Down', '4349876584');
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual(
        'Unable to retrieve Account Policy Numbers for ' +
          ' ' +
          '4349876584' +
          ' ' +
          'OCV Down',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }
  /**
   * @description Test to Update Priority to Customer Experiencing Vulnerability on Case if Account ECF is true.
   */
  @isTest
  static void testUpdatePriorityforECF() {
    registerMocks();

    Case shellCase = shellCaseRecord;

    Account testAccount = accountRecord;
    testAccount.ExtraCareTimePeriod__c = IDRConstants.TIME_PERIOD_ONGOING;
    Case testCase = testAccount.Cases[0];
    testCase.AccountId = testAccount.Id;

    caseRepoMock.mock(
      'getAccountsWithExtraCareFlag',
      new List<Account>{ testAccount }
    );
    Test.startTest();
    IDRCaseActionsHelper.updateCasePriorityforECFAccount(
      new List<Case>{ testCase },
      new Map<Id, Case>{ shellCase.Id => shellCase }
    );
    Test.stopTest();

    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      testCase.Priority,
      'Priority should be updated'
    );
  }
  /**
   * @description Test to not Update Priority to Customer Experiencing Vulnerability on Case if Account ECF is false.
   */
  @isTest
  static void testUpdatePriorityforECFNegative() {
    registerMocks();

    Case shellCase = shellCaseRecord;

    Account testAccount = accountRecord;
    testAccount.ExtraCareTimePeriod__c = IDRConstants.TIME_PERIOD_NOT_REQUIRED;
    Case testCase = testAccount.Cases[0];
    testCase.AccountId = testAccount.Id;

    caseRepoMock.mock(
      'getAccountsWithExtraCareFlag',
      new List<Account>{ testAccount }
    );
    Test.startTest();
    IDRCaseActionsHelper.updateCasePriorityforECFAccount(
      new List<Case>{ testCase },
      new Map<Id, Case>{ shellCase.Id => shellCase }
    );
    Test.stopTest();

    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_STANDARD,
      testCase.Priority,
      'Priority should not be updated to Vulnerable Customer and remain standard'
    );
  }
  /**
   * @description Test to set Priority to Customer Experiencing Vulnerability on Case if Account has ExtraCare flag as true.
   */
  @isTest
  static void testCaseInsertPriorityforECF() {
    registerMocks();

    Case cs = IDRTestDataFactory.getCase();
    cs.Priority = IDRConstants.CASE_PRIORITY_STANDARD;
    Account testAccount = IDRTestDataFactory.getAccountWithCase(cs);
    testAccount.ExtraCareTimePeriod__c = IDRConstants.TIME_PERIOD_ONGOING;
    cs.AccountId = testAccount.Id;
    caseRepoMock.mock(
      'getAccountsWithExtraCareFlag',
      new List<Account>{ testAccount }
    );
    Test.startTest();
    IDRCaseActionsHelper.updateCasePriorityforECFAccount(
      new List<Case>{ cs },
      null
    );
    Test.stopTest();

    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_VULNERABLE,
      cs.Priority,
      'Priority should be updated to ' + IDRConstants.CASE_PRIORITY_VULNERABLE
    );
  }
  /**
   * @description Test negative scenario to check Case priority is unchanged if Account has ExtraCare flag as false.
   */
  @isTest
  static void testCaseInsertPriorityforECFNegative() {
    registerMocks();
    Case cs = IDRTestDataFactory.getCase();
    cs.Priority = IDRConstants.CASE_PRIORITY_STANDARD;
    cs.RecordTypeId = RTCase.nonCustomerComplaint;
    Account testAccount = IDRTestDataFactory.getAccountWithCase(cs);
    testAccount.ExtraCareTimePeriod__c = IDRConstants.TIME_PERIOD_NOT_REQUIRED;
    cs.AccountId = testAccount.Id;
    caseRepoMock.mock(
      'getAccountsWithExtraCareFlag',
      new List<Account>{ testAccount }
    );
    Test.startTest();
    IDRCaseActionsHelper.updateCasePriorityforECFAccount(
      new List<Case>{ cs },
      null
    );
    Test.stopTest();

    Assert.areEqual(
      IDRConstants.CASE_PRIORITY_STANDARD,
      cs.Priority,
      'Priority should not be updated to ' +
      IDRConstants.CASE_PRIORITY_VULNERABLE
    );
  }
}
