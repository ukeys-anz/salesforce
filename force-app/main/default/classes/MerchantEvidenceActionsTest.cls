/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class MerchantEvidenceActionsTest {
  static Faker faker = new Faker('AU');
  static List<Id> taskIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Task.SObjectType)
  };
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };
  static List<Id> extCaseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(External_Case_Status__c.SObjectType),
    Lib_FakeIdGenerator.getMockId(External_Case_Status__c.SObjectType)
  };
  static Lib_MockProvider queryMockCls;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    queryMockCls = Lib_MockProvider.forType(IDOpsQueryRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static List<Case> caseRecords {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          RecordTypeId = RTTask.merchantEvidentReceivedRT
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<External_Case_Status__c> externalCaseRecords {
    get {
      List<External_Case_Status__c> externalCases = new List<External_Case_Status__c>();
      for (Id extCaseId : extCaseIds) {
        External_Case_Status__c newCase = new External_Case_Status__c(
          Id = extCaseId,
          Case__c = caseRecords[0].Id,
          External_Status__c = 'Pending-PreArbInbound',
          Status_Event_ID__c = '1234567890'
        );
        externalCases.add(newCase);
      }
      return externalCases;
    }
  }

  static List<Task> taskRecords {
    get {
      List<Task> tasks = new List<Task>();
      for (Id taskId : taskIds) {
        Task taskRecord = new Task(
          Id = taskId,
          WhatId = caseRecords[0].Id,
          RecordTypeId = RTTask.merchantEvidentReceivedRT,
          Subject = 'Card - Merchant Evident Received',
          ActivityDate = System.today().addDays(10),
          Status = 'Not Started',
          Priority = 'Normal',
          Description = 'Please Review Merchant Evidence for Personal Information'
        );
        tasks.add(taskRecord);
      }
      return tasks;
    }
  }

  @IsTest
  static void testCreateTaskRecords() {
    registerMocks();
    queryMockCls.mock('getTaskAssociatedToCase', taskRecords);
    queryMockCls.mock('getCaseRecordUsingExternalCases', caseRecords);
    Test.startTest();
    MerchantEvidenceActions.createTaskRecords(externalCaseRecords);
    Test.stopTest();
    Assert.isFalse(
      queryMockCls.getHistories('getTaskAssociatedToCase').isEmpty(),
      'getTaskAssociatedToCase should have been called'
    );
  }

  @IsTest
  static void testCreateTaskRecordsMethod2() {
    registerMocks();
    List<Task> taskList = taskRecords;
    taskList[0].Subject = 'Test1';
    queryMockCls.mock('getTaskAssociatedToCase', taskList);
    queryMockCls.mock('getCaseRecordUsingExternalCases', caseRecords);
    Test.startTest();
    MerchantEvidenceActions.createTaskRecords(externalCaseRecords);
    Test.stopTest();
    Assert.isFalse(
      queryMockCls.getHistories('getTaskAssociatedToCase').isEmpty(),
      'getTaskAssociatedToCase should have been called'
    );
    Assert.isFalse(
      queryMockCls.getHistories('getCaseRecordUsingExternalCases').isEmpty(),
      'getCaseRecordUsingExternalCases should have been called'
    );
  }

  @IsTest
  static void testGetOpenTasks() {
    registerMocks();
    queryMockCls.mock('getTaskAssociatedToCase', taskRecords);

    Test.startTest();
    MerchantEvidenceActions.getOpenTasks(new Set<Id>{ caseRecords[0].Id });
    Test.stopTest();
    Assert.isFalse(
      queryMockCls.getHistories('getTaskAssociatedToCase').isEmpty(),
      'getTaskAssociatedToCase should have been called'
    );
  }

  @IsTest
  static void testGetFilteredCasesForTask() {
    registerMocks();
    queryMockCls.mock('getCaseRecordUsingExternalCases', caseRecords);

    Set<Id> caseIds = ListUtil.getIds(
      externalCaseRecords,
      External_Case_Status__c.Case__c
    );

    Test.startTest();
    MerchantEvidenceActions.getValidCardCases(caseIds);
    Test.stopTest();
    Assert.isFalse(
      queryMockCls.getHistories('getCaseRecordUsingExternalCases').isEmpty(),
      'getCaseRecordUsingExternalCases should have been called'
    );
  }

  @IsTest
  static void testPerformTaskCreation() {
    registerMocks();

    Test.startTest();
    MerchantEvidenceActions.performTaskCreation(caseRecords);
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );
  }
}
