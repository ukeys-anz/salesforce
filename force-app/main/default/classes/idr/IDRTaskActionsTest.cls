@isTest
private with sharing class IDRTaskActionsTest {
  @TestSetup
  static void testSetup() {
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Normal',
          Subject = '000001234',
          Description = 'Test description 1234-5678-9101 check mask'
        )
      );
    }
    insert newTasks;
    // Insert User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a Systemic Issue User with Systemic Issue Team role
      Profile profile = CommonUtil.getProfileByName('ANZ Standard User');
      UserRole role = CommonUtil.getUserRoleByDevName('Systemic_Issue_Team');
      User siUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'siUser',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert siUser;

      // Assign related PSs
      List<String> siPsets = new List<String>{ 'Systemic_Issue_User_Base' };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :siPsets
      ];

      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(siUser.id, ps.Id));
      }
      insert psaList;
    }
  }

  @isTest
  static void testTaskFieldMasking() {
    //GIVEN tasks
    //WHEN they're inserted
    //THEN long numbers in free text fields are masked, showing only the last four digits
    Task t = [SELECT Subject, Description FROM Task LIMIT 1];
    System.assertEquals('*****1234', t.Subject, 'Subject should be masked.');
    System.assertEquals(
      'Test description ********9101 check mask',
      t.Description,
      'Description should be masked.'
    );
    //AND WHEN updated
    t.Subject = '987654321';
    update t;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    t = [SELECT Subject FROM Task LIMIT 1];
    System.assertEquals('*****4321', t.Subject, 'Subject should be masked.');
  }

  @isTest
  static void testSITaskDueDateUpdate() {
    User siUser = TestUtil.getUserByFirstName('siUser');
    List<Case> newSIs = new List<Case>();
    Task siTask = new Task();

    System.runAs(siUser) {
      // SI records
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        newSIs.add(
          new Case(
            RecordTypeId = IDRConstants.SI_RT_ID,
            Status = 'Open',
            SI_Workflow_step__c = 'Assessing'
          )
        );
      }
      insert newSIs;

      // GIVEN a SI task created by Systemic Issue Team
      siTask = new Task(
        Subject = IDRTaskActions.IDR_TASK_SUBJECT,
        RecordTypeId = IDRConstants.SI_TASK_RT_ID,
        Priority = 'Normal',
        ActivityDate = system.today().addDays(10),
        WhatId = newSIs[0].Id
      );

      insert siTask;
    }

    //WHEN the task due date is updated by someone other than the case owner
    try {
      siTask.ActivityDate = system.today().adddays(15);
      update siTask;
    } catch (DMLexception e) {
      //THEN restrict the user from updating task due date
      system.assertEquals(
        IDRTaskActions.SI_DUE_DATE_ERROR_MESSAGE,
        e.getDmlMessage(0)
      );
    }
  }

  @isTest
  static void testIDRTaskClosureOnCaseClose() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Date_Received__c = system.now()
        )
      );
    }
    insert newCases;

    List<Task> taskToinsert = new List<Task>();
    for (Case c : newCases) {
      task idrTask = new task(
        whatId = c.Id,
        Subject = IDRConstants.TASK_SUBJECT_DAY5,
        RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
        Priority = 'Standard',
        ActivityDate = system.today()
      );
      taskToinsert.add(idrTask);
    }

    insert taskToinsert;

    checkRecursive.firstCall = false;

    Test.startTest();
    for (Case c : newCases) {
      c.Status = IDRConstants.CLOSED_STATUS;
      c.IDR_Complaint_Outcome__c = '1';
      c.IDR_Description_of_Outcome__c = 'test';
    }
    update newCases;

    Test.stopTest();

    for (Task task : [SELECT Status FROM Task WHERE id = :taskToinsert]) {
      system.assertEquals(IDRConstants.TASK_STATUS_COMPLETED, task.Status);
    }
  }
}
