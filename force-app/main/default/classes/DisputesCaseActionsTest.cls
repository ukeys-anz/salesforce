/**
 * @author Hrushikesh
 * @since 10/2024
 * @description DisputesCaseActionsTest class for DisputesCaseActions
 */
@isTest
public with sharing class DisputesCaseActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider queryMockCls;
  static Faker faker = new Faker('AU');

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    queryMockCls = Lib_MockProvider.forType(IDOpsQueryRepository.class);
  }

  static List<Id> taskIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Task.SObjectType),
    Lib_FakeIdGenerator.getMockId(Task.SObjectType)
  };

  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Case> cardCaseRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Priority = 'Medium',
          Description = faker.randomString(10),
          Subject = 'Card Dispute',
          Origin = 'Origination',
          Status = 'Open',
          RecordTypeId = RTCase.cardDispute
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static Task merchantEvidenceTask = new Task(
    Id = taskIds[0],
    WhatId = cardCaseRecord[0].Id,
    Subject = 'Card - Merchant Evident Received',
    Status = 'Not Started',
    RecordTypeId = RTTask.merchantEvidentReceivedRT
  );

  // To test creation of External Case Status for NPP Non Fruad dispute
  @isTest
  private static void testNewExternalStatusCreationForNppNonFraud() {
    registerMocks();

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );

    Case theCase = TestDataFactory.createCase('NPP_Dispute');

    Test.startTest();
    DisputesCaseActions.createExternalCaseStatuses(
      new List<Case>{ theCase },
      'NPP_New'
    );
    Test.stopTest();
    List<External_Case_Status__c> extCaseStatuses = (List<External_Case_Status__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    Assert.isTrue(
      extCaseStatuses.size() == 1,
      'Only one external case record should be created'
    );

    Assert.areEqual(
      extCaseStatuses[0].External_Status__c,
      'New',
      'External Case Status with External Status as New should be created'
    );
  }

  @isTest
  private static void testCheckForOpenTask() {
    registerMocks();

    queryMockCls.mock(
      'getTaskAssociatedToCase',
      new List<Task>{ merchantEvidenceTask }
    );

    Test.startTest();
    DisputesCaseActions.checkForOpenTask(cardCaseRecord);
    Test.stopTest();

    Assert.areEqual(
      0,
      cardCaseRecord[0].getErrors().size(),
      'There is error during lead updation'
    );
  }

  @isTest
  private static void testCheckForOpenTaskToClose() {
    registerMocks();
    List<Case> records = new List<Case>{
      new Case(Id = cardCaseRecord[0].Id, Status = 'Closed')
    };
    cardCaseRecord[0].Status = 'Closed';
    queryMockCls.mock(
      'getTaskAssociatedToCase',
      new List<Task>{ merchantEvidenceTask }
    );

    Test.startTest();
    DisputesCaseActions.checkForOpenTask(records);
    Test.stopTest();

    List<Database.Error> errors = records[0].getErrors();
    Database.Error error = errors.get(0);

    Assert.areEqual(1, errors.size(), 'There is no error during case updation');
    Assert.areEqual(
      DisputesCaseActions.CASE_CLOSURE_ERR_MSG,
      error.getMessage(),
      'Case updated successfully'
    );
  }
}
