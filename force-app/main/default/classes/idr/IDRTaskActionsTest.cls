@IsTest
private with sharing class IDRTaskActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider taskRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    taskRepoMock = Lib_MockProvider.forType(IDRTaskActionsRepository.class);
  }
  static final Faker FAKER = new Faker('0-9');
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)),
    new Map<String, List<SObject>>{
      'Tasks' => new List<Task>{
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Date_Case_on_Hold_From__c = Date.TODAY(),
          Status = IDRConstants.OPEN_STATUS,
          RecordTypeId = RTTask.idrTask,
          Type = IDRConstants.TASK_TYPE_PEND_CASE
        ),
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Date_Case_on_Hold_From__c = Date.TODAY(),
          Status = IDRConstants.TASK_STATUS_COMPLETED,
          RecordTypeId = RTTask.idrTask,
          Type = IDRConstants.TASK_TYPE_PEND_CASE
        )
      }
    }
  );
  static Quality_Assessment__c qaRecord = (Quality_Assessment__c) TestUtil.setFields(
    new Quality_Assessment__c(
      Id = Lib_FakeIdGenerator.getMockId(Quality_Assessment__c.SObjectType),
      Status__c = QualityAssessmentActions.STATUS_PENDING,
      RecordTypeId = IDRConstants.idrtCQQualityAssessment,
      Corrective_actions_for_TM_CM__c = 'Update internal records'
    ),
    new Map<String, List<SObject>>{
      'Tasks' => new List<Task>{
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Status = IDRConstants.OPEN_STATUS,
          RecordTypeId = RTTask.complianceTask,
          Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
        )
      }
    }
  );
  static Case urgentCaseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.nonCustomerComplaint
    ),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );

  @TestSetup
  static void testSetup() {
    Task[] newTasks = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newTasks.add(
        new Task(
          RecordTypeId = IDRConstants.IDR_TASK_RT_ID,
          Priority = 'Normal',
          Subject = '1234-5678-9101-3321',
          Description = 'Test description 1234-5678-9101-3321 check mask'
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

      Profile stdUserProfile = CommonUtil.getProfileByName('ANZ Standard User');
      UserRole cqRole = CommonUtil.getUserRoleByDevName(
        'Capability_Quality_C_Q_Team'
      );
      UserRole crplRole = CommonUtil.getUserRoleByDevName(
        'Customer_Resolution_Leadership'
      );

      User oQAUser;
      User oIDRUser;
      List<User> lstUsers = new List<User>{
        // Create QA user
        oQAUser = TestUtil.createTestUser(
          new Map<String, Object>{
            'FirstName' => 'QA_User',
            'ProfileId' => stdUserProfile.Id,
            'UserRoleId' => cqRole.Id
          }
        ),
        // Create IDR user
        oIDRUser = TestUtil.createTestUser(
          new Map<String, Object>{
            'FirstName' => 'IDR_User',
            'ProfileId' => stdUserProfile.Id,
            'UserRoleId' => crplRole.Id
          }
        )
      };
      insert lstUsers;

      // Add IDR User permissions on test users
      PermissionSet ps = CommonUtil.getPermissionSetByName('IDR_User');
      List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>{
        TestUtil.createPSAssignment(oQAUser.Id, ps.Id)
      };

      List<PermissionSetGroup> lstPSG = [
        SELECT Id, DeveloperName
        FROM PermissionSetGroup
        WHERE DeveloperName IN ('CMOS_Quality_Assessor', 'IDR_Level_1')
      ];
      List<Id> lstPSGIds = new List<Id>();
      for (PermissionSetGroup psg : lstPSG) {
        lstPSGIds.add(psg.Id);
        lstPSA.add(
          new PermissionSetAssignment(
            AssigneeId = oQAUser.Id,
            PermissionSetGroupId = psg.Id
          )
        );
      }

      Test.calculatePermissionSetGroup(lstPSGIds);

      insert lstPSA;
    }
  }

  @IsTest
  static void testTaskFieldMasking() {
    //GIVEN tasks
    //WHEN they're inserted
    //THEN long numbers in free text fields are masked, showing only the last four digits
    Task t = [SELECT Subject, Description FROM Task LIMIT 1];
    System.assertEquals(
      '************3321',
      t.Subject,
      'Subject should not be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      t.Description,
      'Description should be masked.'
    );
    //AND WHEN updated
    t.Subject = '1234-5678-9101-3321';
    update t;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    t = [SELECT Subject FROM Task LIMIT 1];
    System.assertEquals(
      '************3321',
      t.Subject,
      'Subject should be masked.'
    );
  }
  @IsTest
  static void testSITaskDueDateUpdate() {
    registerMocks();
    Id currentUserId = UserInfo.getUserId();
    Case caseRecord = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)
    );
    Case caseRecord1 = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      OwnerId = currentUserId
    );

    Task taskRecord1 = generateSITask(
      Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      caseRecord
    );
    Task taskRecord2 = generateSITask(taskRecord1.Id, caseRecord);
    taskRecord2.ActivityDate = System.today().addDays(15);
    Task taskRecord3 = generateSITask(
      Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      caseRecord1
    );
    Task taskRecord4 = generateSITask(taskRecord3.Id, caseRecord1);
    taskRecord4.ActivityDate = System.today().addDays(15);

    taskRepoMock.mock('queryCases', new List<Case>{ caseRecord });
    Test.startTest();
    IDRTaskActions.validateSIDueDate(
      new List<Task>{ taskRecord2 },
      new Map<Id, Task>{ taskRecord1.Id => taskRecord1 }
    );
    IDRTaskActions.validateSIDueDate(
      new List<Task>{ taskRecord4 },
      new Map<Id, Task>{ taskRecord3.Id => taskRecord3 }
    );
    Test.stopTest();
    System.assertEquals(
      IDRTaskActions.SI_DUE_DATE_ERROR_MESSAGE,
      taskRecord2.getErrors()[0].getMessage(),
      'Error message should be as expected.'
    );
    System.assertEquals(0, taskRecord4.getErrors().size(), 'No error message');
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

      List<Task> taskToInsert = new List<Task>();
      for (Case c : newCases) {
        Task idrTask = new Task(
          WhatId = c.Id,
          Subject = IDRConstants.TASK_SUBJECT_DAY1,
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Standard',
          ActivityDate = System.today()
        );
        taskToInsert.add(idrTask);
      }

      insert taskToInsert;

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

      for (Task task : [SELECT Status FROM Task WHERE Id = :taskToInsert]) {
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
    Group stopQueue = [
      SELECT Id
      FROM Group
      WHERE
        DeveloperName = 'IDR_Stop_Collections'
        AND Type = :IDRCaseActions.QUEUE_TYPE
    ];
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
      c.OwnerId = stopQueue.Id;
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

      List<Task> taskToInsert = new List<Task>();
      for (Case c : newCases) {
        Task idrTask = new Task(
          WhatId = c.Id,
          Subject = IDRConstants.TASK_CORRESPONDENCE_SUBJECT,
          RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
          Priority = 'Standard',
          ActivityDate = System.today()
        );
        taskToInsert.add(idrTask);
      }

      insert taskToInsert;

      Test.startTest();
      for (Task t : taskToInsert) {
        t.Status = IDRConstants.TASK_STATUS_COMPLETED;
      }
      update taskToInsert;

      Test.stopTest();

      for (Case c : [
        SELECT IDR_Additional_Correspondence_reviewed__c
        FROM Case
        WHERE Id = :newCases
      ]) {
        System.assert(
          c.IDR_Additional_Correspondence_reviewed__c,
          'Case Additional Correspondence Reviewed should be as expected.'
        );
      }
    }
  }

  @IsTest
  static void urgentCaseAllocationTask() {
    registerMocks();
    User thisUser = new User(Id = UserInfo.getUserId());
    GroupMember gmember = new GroupMember(
      GroupId = QueryQueue.get('IDR_Everyday_Banking').Id,
      UserOrGroupId = UserInfo.getUserId()
    );
    Task urgentTask = new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Type = 'General Task/ Reminder',
      Subject = IDRTaskActions2.TASK_SUBJECT_URGENT,
      RecordTypeId = RTTask.idrTask,
      Priority = 'Standard',
      ActivityDate = System.today(),
      OwnerId = QueryQueue.get('IDR_Everyday_Banking').Id,
      WhatId = urgentCaseRecord.Id
    );
    taskRepoMock.mock('queryInactiveUsers', new List<User>{ thisUser });
    taskRepoMock.mock('queryGroupMember', new List<GroupMember>{ gmember });
    taskRepoMock.mock(
      'queryCasesForUrgentTasks',
      new List<Case>{ urgentCaseRecord }
    );
    Test.startTest();
    IDRTaskActions2.checkForUrgentCaseAllocationTask(
      new List<Task>{ urgentTask }
    );
    Test.stopTest();
    Assert.isTrue(
      dmlRepoMock.getHistories('insertRecords').isEmpty(),
      'Nothing to Update, as only notification is getting sent'
    );
  }
  @IsTest
  static void validateQAComplianceTask() {
    registerMocks();
    Quality_Assessment__c qaRecord = qaRecord;
    List<Task> qaTasks = qaRecord.Tasks;
    Task oldTask = qaTasks[0];
    oldTask.WhatId = qaRecord.Id;
    Task newTask = new Task(
      Id = oldTask.Id,
      WhatId = qaRecord.Id,
      Status = IDRConstants.TASK_STATUS_COMPLETED,
      RecordTypeId = RTTask.complianceTask,
      Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
    );
    taskRepoMock.mock(
      'queryQualityAssessments',
      new List<Quality_Assessment__c>{ qaRecord }
    );
    Test.startTest();
    IDRTaskActions2.validateQAComplianceTask(
      new List<Task>{ newTask },
      new Map<Id, Task>{ oldTask.Id => oldTask }
    );
    Test.stopTest();
    System.AssertEquals(
      IDRConstants.TASK_QA_CLOSE_ERROR,
      newTask.getErrors()[0].getMessage(),
      'Error thrown while updating task'
    );
  }

  @IsTest
  static void validateQAComplianceTaskNoError() {
    registerMocks();
    Quality_Assessment__c qaRecord = qaRecord;
    qaRecord.Team_Manager_Response__c = 'Accepted by TM';
    qaRecord.Team_Manager_Comments__c = 'Test';
    List<Task> qaTasks = qaRecord.Tasks;
    Task oldTask = qaTasks[0];
    oldTask.WhatId = qaRecord.Id;
    Task newTask = new Task(
      Id = oldTask.Id,
      WhatId = qaRecord.Id,
      Status = IDRConstants.TASK_STATUS_COMPLETED,
      RecordTypeId = RTTask.complianceTask,
      Subject = IDRConstants.TASK_QA_COMPLIANCE_SUBJECT
    );
    taskRepoMock.mock(
      'queryQualityAssessments',
      new List<Quality_Assessment__c>{ qaRecord }
    );
    Test.startTest();
    IDRTaskActions2.validateQAComplianceTask(
      new List<Task>{ newTask },
      new Map<Id, Task>{ oldTask.Id => oldTask }
    );
    Test.stopTest();
    System.AssertEquals(0, newTask.getErrors().size(), 'No Error');
  }

  @IsTest
  static void testgetOnHoldDateFromOpenTask() {
    Case testCase = caseRecord;

    Task taskRecord = testCase.Tasks[0];
    taskRecord.WhatId = testCase.Id;
    Test.startTest();
    Map<Id, Date> caseMap = IDRTaskActions2.getOnHoldDateFromTask(
      new List<Task>{ taskRecord }
    );
    Test.stopTest();

    System.assertEquals(
      caseMap.get(taskRecord.WhatId),
      taskRecord.Date_Case_on_Hold_From__c,
      'Both dates should be equal'
    );
  }
  @IsTest
  static void testgetOnHoldDateFromCompletedTask() {
    Case testCase = caseRecord;

    Task taskRecord = testCase.Tasks[1];
    taskRecord.WhatId = testCase.Id;
    Test.startTest();
    Map<Id, Date> caseMap = IDRTaskActions2.getOnHoldDateFromTask(
      new List<Task>{ taskRecord }
    );
    Test.stopTest();

    Assert.isNull(caseMap.get(taskRecord.WhatId), 'Expected null date');
  }
  @IsTest
  static void testsetCaseFieldsWithOpenPendTask() {
    Case testCase = caseRecord;

    Task taskRecord = testCase.Tasks[0];
    taskRecord.WhatId = testCase.Id;

    Map<Id, Date> caseIdtoDateValue = new Map<Id, Date>();
    caseIdtoDateValue.put(
      taskRecord.WhatId,
      taskRecord.Date_Case_on_Hold_From__c
    );

    Test.startTest();
    List<Case> cases = IDRTaskActions2.setCaseFields(caseIdtoDateValue, true);
    Test.stopTest();

    System.assertEquals(
      cases[0].IDR_Date_Case_on_Hold_From__c,
      taskRecord.Date_Case_on_Hold_From__c,
      'Case field IDR_Date_Case_on_Hold_From__c should be equal to Task On Hold Date'
    );
  }
  @IsTest
  static void testsetCaseFieldsWithCompletedTask() {
    Case testCase = caseRecord;

    Task taskRecord = testCase.Tasks[1];
    taskRecord.WhatId = testCase.Id;

    Map<Id, Date> caseIdtoDateValue = new Map<Id, Date>();
    caseIdtoDateValue.put(
      taskRecord.WhatId,
      taskRecord.Date_Case_on_Hold_From__c
    );

    Test.startTest();
    List<Case> cases = IDRTaskActions2.setCaseFields(caseIdtoDateValue, false);
    Test.stopTest();

    Assert.isNull(
      cases[0].IDR_Date_Case_on_Hold_From__c,
      'Date should be updated to null'
    );
  }
  @IsTest
  static void testUpdateOnHoldDateonCase() {
    registerMocks();
    Case testCase = caseRecord;
    Task taskRecord = testCase.Tasks[0];
    taskRecord.WhatId = testCase.Id;

    Test.startTest();
    IDRTaskActions2.updateOnHoldDateonCase(new List<Task>{ taskRecord }, true);
    Test.stopTest();

    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');

    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords should have been invoked at least once'
    );

    System.assertEquals(
      IDRConstants.ON_HOLD_STATUS,
      cases[0].Status,
      'Status should be updated to On Hold'
    );
    System.assertEquals(
      taskRecord.Date_Case_on_Hold_From__c,
      cases[0].IDR_Date_Case_on_Hold_From__c,
      'On Hold Date on Case should be updated from Task'
    );
  }
  @IsTest
  static void testUpdateOnHoldDateonCasetoNull() {
    registerMocks();
    Case testCase = caseRecord;
    Task taskRecord = testCase.Tasks[1];
    taskRecord.WhatId = testCase.Id;
    dmlRepoMock.mock(
      'updateRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
    Test.startTest();
    IDRTaskActions2.updateOnHoldDateonCase(new List<Task>{ taskRecord }, false);
    Test.stopTest();
    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');
    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords should have been invoked at least once'
    );

    Assert.isNull(
      cases[0].IDR_Date_Case_on_Hold_From__c,
      'Date should be updated to null'
    );
  }
  @IsTest
  static void testassignPendTasktoCaseOwner() {
    registerMocks();
    Case testCase = caseRecord;
    Task taskRecord = testCase.Tasks[0];
    taskRecord.WhatId = testCase.Id;
    taskRepoMock.mock('queryCases', new List<Case>{ testCase });
    Test.startTest();
    IDRTaskActions2.assignPendTasktoCaseOwner(
      new List<Task>{ testCase.Tasks[0] }
    );
    Test.stopTest();

    System.assertEquals(
      taskRecord.OwnerId,
      testCase.OwnerId,
      'Both Owners should be Equal'
    );
  }
  @isTest
  static void testIsValidPendTask() {
    Case testCase = caseRecord;

    Task taskRecord = testCase.Tasks[0];
    taskRecord.WhatId = testCase.Id;
    Test.startTest();
    Boolean isValidTask = IDRTaskActions2.isValidPendTask(taskRecord);
    Test.stopTest();

    System.assertEquals(true, isValidTask, 'Boolean should be true');
  }
  /**
   * @description Create test SI Task records
   * @param  recordId Id Task record Id
   * @param  caseRecord Case record
   * @return Task
   */
  private static Task generateSITask(Id recordId, Case caseRecord) {
    return new Task(
      Id = recordId,
      RecordTypeId = RTTask.systemicIssueTask,
      WhatId = caseRecord.Id,
      ActivityDate = System.today().addDays(10)
    );
  }
}