@isTest
private with sharing class SICaseActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider sicaseRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    sicaseRepoMock = Lib_MockProvider.forType(SICaseActionsRepository.class);
  }
  static final Faker FAKER = new Faker('0-9');

  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.systemicIssue,
      SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_INVESTIGATING
    ),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );

  static Case caseRecord1 = (Case) TestUtil.setFields(
    new Case(
      Id = caseRecord.Id,
      RecordTypeId = RTCase.systemicIssue,
      SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_MONITORING
    ),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );

  static Case caseRecord2 = (Case) TestUtil.setFields(
    new Case(
      Id = caseRecord1.Id,
      RecordTypeId = RTCase.systemicIssue,
      SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_MONITORING
    ),
    new Map<String, List<SObject>>{
      'Tasks' => new List<Task>{
        new Task(
          Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
          Type = IDRConstants.SI_WF_STEP_MONITORING
        )
      }
    }
  );

  static Case caseRecord3 = new Case(
    Id = caseRecord2.Id,
    RecordTypeId = RTCase.systemicIssue,
    SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_ASSESSING
  );

  @isTest
  static void testTasksonCaseAfterInsert() {
    registermocks();
    Case testCase = caseRecord;
    testCase.SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_MONITORING;

    Test.startTest();
    SICaseActions.processMonitoringTasks(
      new List<Case>{ testCase },
      new Map<Id, Case>()
    );
    Test.stopTest();
    List<Task> taskslist = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');

    System.assertEquals(2, taskslist.size(), '2 Tasks should be inserted');

    Assert.isFalse(
      dmlRepoMock.getHistories('doInsert').isEmpty(),
      'insertRecords should have been invoked at least once'
    );
  }

  @isTest
  static void testRemovePendingMonitoringTasks() {
    registerMocks();

    Case testCase2 = caseRecord2;

    Case testCase3 = caseRecord3;

    Task taskRecord = testCase2.Tasks[0];
    taskRecord.WhatId = testCase2.Id;
    sicaseRepoMock.mock(
      'queryMonitoringTasksToDelete',
      new List<Task>{ taskRecord }
    );

    Test.startTest();
    SICaseActions.removePendingMonitoringTasks(
      new List<Case>{ testCase3 },
      new Map<Id, Case>{ testCase2.Id => testCase2 }
    );
    Test.stopTest();

    Assert.isFalse(
      dmlRepoMock.getHistories('doDelete').isEmpty(),
      'deleteRecords should have been invoked at least once'
    );
  }
  @isTest
  static void testTasksOnCaseAfterUpdate() {
    registerMocks();
    Case testCase = caseRecord;
    testCase.RecordTypeId = RTCase.systemicIssue;
    testCase.SI_Workflow_step__c = IDRConstants.SI_WF_STEP_INVESTIGATING;
    Case testCase2 = caseRecord1;

    Test.startTest();
    SICaseActions.processMonitoringTasks(
      new List<Case>{ testCase2 },
      new Map<Id, Case>{ testCase.Id => testCase }
    );
    Test.stopTest();

    List<Task> taskslist = (List<Task>) dmlRepoMock.getHistory('doInsert')
      .getParam('records');
    System.assertEquals(
      2,
      taskslist.size(),
      '2 monitoring tasks should be created per case'
    );
  }
  @isTest
  static void testNoMonitotingTaskstriggered() {
    registerMocks();
    Case testCase = caseRecord;
    Case testCase3 = caseRecord3;

    Test.startTest();
    SICaseActions.processMonitoringTasks(
      new List<Case>{ testCase3 },
      new Map<Id, Case>{ testCase.Id => testCase }
    );
    Test.stopTest();
    Assert.isTrue(
      ((List<Task>) dmlRepoMock.getHistory('doInsert').getParam('records'))
        .isEmpty(),
      'No Monitoring Task should be created'
    );
  }

  @isTest
  static void testRollupToParentSI() {
    //Assert that testsetup complaint count has rollup to the parent SI records
    registerMocks();

    Case testSICase = caseRecord;

    Case testCase1 = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.customerComplaint,
      IDR_Parent_Systemic_Issue__c = testSICase.Id
    );

    sicaseRepoMock.mock('queryComplaintsOnCases', new List<Case>{ testSICase });

    Test.startTest();
    SICaseActions.rollupToParentSI(new List<case>{ testCase1 });
    Test.stopTest();

    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isFalse(
      dmlRepoMock.getHistories('doUpdate').isEmpty(),
      'doUpdate should have been invoked at least once'
    );
    System.assertEquals(
      testCase1.IDR_Parent_Systemic_Issue__c,
      testSICase.Id,
      'Parent SI Id same'
    );

    System.assertEquals(1, cases.size(), '1 Case should be updated');
  }

  @isTest
  static void testSystemicIssueFieldMasking() {
    //GIVEN SIs
    //WHEN they're inserted
    // THEN long numbers in free text fields are masked, showing only the last four digits
    List<Case> caseList = new List<Case>();
    Map<Id, Case> oldMap = new Map<Id, Case>();

    Case testCase = caseRecord;
    testCase.Status = IDRConstants.OPEN_STATUS;
    testCase.Subject = '1234-5678-9101-3321';
    testCase.SI_Workflow_Step__c = IDRConstants.SI_WF_STEP_ASSESSING;
    testCase.Description = 'Test description 1234-5678-9101-3321 check mask';
    testCase.IDR_Description_of_Outcome__c = 'Test description 1234-5678-9101-3321 check mask';
    testCase.RAG_Comments__c = 'Test description 1234-5678-9101-3321 check mask';
    testCase.SI_Definite_Action_Completed__c = 'Test description 1234-5678-9101-3321 check mask';
    testCase.SI_Rec_Rem_Actions__c = 'Test description 1234-5678-9101-3321 check mask';
    testCase.SI_Subject_of_Breach_Report_Comments__c = 'Test description 1234-5678-9101-3321 check mask';

    Test.startTest();
    SICaseActions.applyDefaults(new List<Case>{ testCase });

    System.assertEquals(
      '************3321',
      testCase.Subject,
      'Subject should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.Description,
      'Description should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.IDR_Description_of_Outcome__c,
      'IDR_Description_of_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.RAG_Comments__c,
      'RAG_Comments__c should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.SI_Definite_Action_Completed__c,
      'SI_Definite_Action_Completed__c should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.SI_Rec_Rem_Actions__c,
      'SI_Rec_Rem_Actions__c should be masked.'
    );
    System.assertEquals(
      'Test description ************3321 check mask',
      testCase.SI_Subject_of_Breach_Report_Comments__c,
      'SI_Subject_of_Breach_Report_Comments__c should be masked.'
    );

    Case oldCaseRecord = testCase;
    oldMap.put(oldCaseRecord.id, oldCaseRecord);

    //AND WHEN updated
    testCase.Description = '1234-5678-9101-3321';
    caseList.add(testCase);

    SICaseActions.beforeUpdate(caseList, oldMap);
    Test.stopTest();

    System.assertEquals(
      '************3321',
      testCase.Subject,
      'Subject should be masked.'
    );
  }
}