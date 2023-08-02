@IsTest
private with sharing class IDRTaskActionsTest {
  @TestSetup
  static void testSetup() {
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Normal',
          Subject = '1234-5678-9101-7632-3321',
          Description = 'Test description 1234-5678-9101-7632-3321 check mask'
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
        psaList.add(TestUtil.createPSAssignment(siUser.Id, ps.Id));
      }
      insert psaList;

      role = CommonUtil.getUserRoleByDevName('Customer_Resolution');
      User idrL1User = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'idrL1User',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert idrL1User;

      List<String> idrPsets = new List<String>{ 'IDR_Level_1' };
      psList = [
        SELECT Id, PermissionSetGroupId
        FROM PermissionSet
        WHERE Name IN :idrPsets AND Type = 'Group'
      ];
      List<String> lstPermissionSetGroupIds = new List<String>();
      for (PermissionSet oPermissionSet : psList) {
        lstPermissionSetGroupIds.add(oPermissionSet.PermissionSetGroupId);
      }
      // Need to force PermissionSetGroup calculation to finalise before adding a user to it.
      Test.calculatePermissionSetGroup(lstPermissionSetGroupIds);

      psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(idrL1User.Id, ps.Id));
      }
      insert psaList;
    }
  }

  @IsTest
  static void testTaskFieldMasking() {
    //GIVEN tasks
    //WHEN they're inserted
    //THEN long numbers in free text fields are masked, showing only the last four digits
    Task t = [SELECT Subject, Description FROM Task LIMIT 1];
    System.assertEquals(
      '****************3321',
      t.Subject,
      'Subject should not be masked.'
    );
    System.assertEquals(
      'Test description ****************3321 check mask',
      t.Description,
      'Description should be masked.'
    );
    //AND WHEN updated
    t.Subject = '1234-5678-9101-7632-3321';
    update t;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    t = [SELECT Subject FROM Task LIMIT 1];
    System.assertEquals(
      '****************3321',
      t.Subject,
      'Subject should be masked.'
    );
  }

  @IsTest
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
            Status = 'Closed',
            SI_Workflow_Step__c = 'Monitoring'
          )
        );
      }
      insert newSIs;

      // GIVEN a SI task created by Systemic Issue Team
      siTask = new Task(
        Subject = IDRTaskActions.IDR_TASK_SUBJECT,
        RecordTypeId = IDRConstants.SI_TASK_RT_ID,
        Priority = 'Normal',
        ActivityDate = System.today().addDays(10),
        WhatId = newSIs[0].Id
      );

      insert siTask;
    }

    //WHEN the task due date is updated by someone other than the case owner
    try {
      siTask.ActivityDate = System.today().addDays(15);
      update siTask;
    } catch (DmlException e) {
      //THEN restrict the user from updating task due date
      System.assertEquals(
        IDRTaskActions.SI_DUE_DATE_ERROR_MESSAGE,
        e.getDmlMessage(0),
        'Error message should be as expected.'
      );
    }
  }

  @IsTest
  static void testPendCaseTaskSubject() {
    Case customerCase = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
      IDR_Customer_Number__c = '1234567890',
      Priority = 'Standard',
      Type = '5',
      IDR_Subsequent_Issue__c = '38'
    );
    insert customerCase;

    Task pendTask = new Task(
      RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
      Type = IDRConstants.TASK_TYPE_PEND_CASE,
      Priority = 'Normal',
      ActivityDate = System.today().addDays(10),
      WhatId = customerCase.Id,
      Description = 'test Description',
      IDR_Key_Contact_Name__c = 'John Doe',
      IDR_Internal_or_External_Party__c = 'External',
      IDR_Pended_To__c = 'Other',
      IDR_Pend_Reason__c = 'Awaiting information to be provided'
      //IDR_Portfolio_or_Business_Unit__c = 'Wealth (AR&C)'
    );

    insert pendTask;

    Task pendCaseTask = [SELECT Subject FROM Task WHERE Id = :pendTask.Id];
    System.assertEquals(
      IDRConstants.SUBJECT_PEND_CASE_TASK,
      pendCaseTask.Subject,
      'Pend case task subject must default to a defined value'
    );
  }
  @IsTest
  static void testIDRTaskClosureOnCaseClose() {
    User l1User = TestUtil.getUserByFirstName('idrL1User');
    System.runAs(l1User) {
      Case[] newCases = new List<Case>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        newCases.add(
          new Case(
            RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
            IDR_Date_Received__c = System.now()
          )
        );
      }
      insert newCases;

      List<Task> taskToinsert = new List<Task>();
      for (Case c : newCases) {
        Task idrTask = new Task(
          WhatId = c.Id,
          Subject = IDRConstants.TASK_SUBJECT_DAY5,
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Standard',
          ActivityDate = System.today()
        );
        taskToinsert.add(idrTask);
      }

      insert taskToinsert;

      CheckRecursive.firstCall = false;

      Test.startTest();
      for (Case c : newCases) {
        c.Status = IDRConstants.CLOSED_STATUS;
        c.IDR_Complaint_Outcome__c = '1';
        c.IDR_Description_of_Outcome__c = 'test';
        c.IDR_Is_Common__c = 'No';
      }
      update newCases;

      Test.stopTest();

      for (Task task : [SELECT Status FROM Task WHERE Id = :taskToinsert]) {
        System.assertEquals(
          IDRConstants.TASK_STATUS_COMPLETED,
          task.Status,
          'Task Status should be as expected.'
        );
      }
    }
  }

  @IsTest
  static void testSystemTaskUpdate() {
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Normal',
          Subject = 'Test Subject',
          Description = 'Test description '
        )
      );
    }
    insert newTasks;
    Test.startTest();
    for (Task t : newTasks) {
      t.Subject = 'New Test Subject';
    }
    List<Database.SaveResult> results = Database.update(newTasks, false);
    Test.stopTest();

    for (Database.SaveResult result : results) {
      System.assertEquals(
        'You are not authorized to make updates to this record.',
        result.errors[0].getMessage(),
        'Error message should be as expected.'
      );
    }
  }

  @IsTest
  static void testQueueNameStamp() {
    //GIVEN new System Task
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Normal',
          Subject = 'Test Subject',
          Description = 'Test description '
        )
      );
    }
    insert newTasks;

    //WHEN they are updated with a Queue as Owner
    Set<Id> taskIds = (new Map<Id, Task>(newTasks)).keySet();
    newTasks = [SELECT OwnerId FROM Task WHERE Id IN :taskIds];
    for (Task c : newTasks) {
      c.OwnerId = IDRTaskActions.stopQueue.Id;
    }
    update newTasks;

    //THEN ensure the Queue name is updated
    Task c = [SELECT OwnerId, Queue__c FROM Task WHERE Id = :newTasks[0].Id];
    Group oQueue = [SELECT Id, Name FROM Group WHERE Id = :c.OwnerId];
    System.assertEquals(
      oQueue.Name,
      c.Queue__c,
      'Task Queue owner not updated'
    );
    // Change owner to test user
    for (Task oTask : newTasks) {
      oTask.OwnerId = UserInfo.getUserId();
    }
    update newTasks;

    //THEN ensure the Queue name is preserved
    c = [SELECT Queue__c FROM Task WHERE Id = :newTasks[0].Id];
    System.assertEquals(
      oQueue.Name,
      c.Queue__c,
      'Task Queue name not preserved'
    );
  }

  @IsTest
  static void testRestrictIDRSystemTaskDelete() {
    //GIVEN new IDR System Task
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Normal',
          Subject = 'Test Subject',
          Description = 'Test description '
        )
      );
    }
    Boolean errorThrown = false;
    User idrL1User = TestUtil.getUserByFirstName('idrL1User');
    System.runAs(idrL1User) {
      insert newTasks;

      //WHEN user attempts to delete the task
      try {
        delete newTasks;
      } catch (DmlException error) {
        System.debug(error);
        errorThrown = true;
      }
    }
    //THEN ensure the IDR System task doesn't get deleted
    System.assertEquals(
      true,
      errorThrown,
      'IDR System Task should not have been deleted'
    );
  }

  @IsTest
  static void testRestrictIDRTaskDelete() {
    //GIVEN new IDR Task
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Normal',
          Subject = 'Test Subject',
          Description = 'Test description '
        )
      );
    }
    Boolean errorThrown = false;
    User idrL1User = TestUtil.getUserByFirstName('idrL1User');
    System.runAs(idrL1User) {
      insert newTasks;

      //WHEN user attempts to delete the task
      try {
        delete newTasks;
      } catch (DmlException error) {
        errorThrown = true;
      }
    }
    //THEN the task should be able to be deleted
    System.assertEquals(
      false,
      errorThrown,
      'IDR Task should have been deleted'
    );
  }

  @IsTest
  static void testIDRCorrespondenceUpdate() {
    User l1User = TestUtil.getUserByFirstName('idrL1User');
    System.runAs(l1User) {
      Case[] newCases = new List<Case>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        newCases.add(
          new Case(
            RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
            Status = 'Withdrawn',
            IDR_Date_Received__c = System.now()
          )
        );
      }
      insert newCases;

      List<Task> taskToinsert = new List<Task>();
      for (Case c : newCases) {
        Task idrTask = new Task(
          WhatId = c.Id,
          Subject = IDRConstants.TASK_SUBJECT_DAY5,
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Standard',
          ActivityDate = System.today()
        );
        taskToinsert.add(idrTask);
      }

      insert taskToinsert;

      Test.startTest();
      for (Task t : tasktoInsert) {
        t.Status = IDRConstants.TASK_STATUS_COMPLETED;
      }
      update taskToInsert;

      Test.stopTest();

      for (Case c : [
        SELECT IDR_Additional_Correspondence_Reviewed__c
        FROM Case
        WHERE Id = :newCases
      ]) {
        System.assert(
          c.IDR_Additional_Correspondence_Reviewed__c,
          'Case Additional Correspondance Reviewed should be as expected.'
        );
      }
    }
  }

  @IsTest
  static void urgentCaseAllocationTask() {

    Group oGroup = [SELECT Id
                    FROM Group
                    WHERE DeveloperName = 'IDR_Everyday_Banking'
                    LIMIT 1];

    List<GroupMember> lstGroupMembers = new List<GroupMember>{
      new GroupMember(GroupId = oGroup.Id, UserOrGroupId = UserInfo.getUserId())
    };
    insert lstGroupMembers;

    Test.startTest();

    // Insert User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      Case[] newCases = new List<Case>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        newCases.add(
          new Case(
            RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
            IDR_Date_Received__c = System.now(),
            OwnerId = oGroup.Id
          )
        );
      }
      insert newCases;

      List<Task> lstTasks = new List<Task>();
      for (Case c : newCases) {
        Task idrTask = new Task(
          WhatId = c.Id,
          Subject = IDRTaskActions2.TASK_SUBJECT_URGENT,
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Standard',
          ActivityDate = System.today()
        );
        lstTasks.add(idrTask);
      }

      insert lstTasks;
    }
    Test.stopTest();
  }
}
