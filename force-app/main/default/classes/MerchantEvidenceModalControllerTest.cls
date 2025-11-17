/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 11-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class MerchantEvidenceModalControllerTest {
  static Faker faker = new Faker('AU');
  static List<Id> taskIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Task.SObjectType),
    Lib_FakeIdGenerator.getMockId(Task.SObjectType)
  };
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
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

  static List<Task> taskRecords {
    get {
      List<Task> tasks = new List<Task>();
      for (Id taskId : taskIds) {
        Task taskRecord = new Task(
          Id = taskId,
          WhatId = caseRecords[0].Id,
          RecordTypeId = RTTask.idrTask,
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
  static void testGetTaskRecord() {
    registerMocks();
    queryMockCls.mock('getTaskAssociatedToCase', taskRecords);
    Test.startTest();
    MerchantEvidenceModalController.getTaskRecord(caseRecords[0].Id);
    Test.stopTest();

    Assert.isFalse(
      queryMockCls.getHistories('getTaskAssociatedToCase').isEmpty(),
      'getTaskAssociatedToCase should have been called'
    );
  }

  @IsTest
  static void testGetTaskRecordException() {
    List<Task> newTaskList = new List<Task>();
    registerMocks();
    queryMockCls.mock('getTaskAssociatedToCase', newTaskList);
    Test.startTest();
    try {
      MerchantEvidenceModalController.getTaskRecord('caseId');
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();

    Assert.isTrue(
      queryMockCls.getHistories('getTaskAssociatedToCase').isEmpty(),
      'getTaskAssociatedToCase should return records'
    );
  }

  @IsTest
  static void testUpdateTaskStatus() {
    registerMocks();
    Test.startTest();
    MerchantEvidenceModalController.updateTaskStatus(taskRecords[0]);
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );
  }
}
