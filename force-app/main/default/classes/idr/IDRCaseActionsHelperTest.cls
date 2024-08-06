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
    registerMocks();
    Case testCase1 = caseRecord1;

    Task taskRecord = testCase1.Tasks[0];
    taskRecord.WhatId = testCase1.Id;

    caseRepoMock.mock('queryPendTasks', new List<Task>{ taskRecord });

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
}
