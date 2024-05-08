/**
 * @author Peter Charalambous
 * @since Mon Apr 15 2024
 * @description test class for SettlementTaskActions
 */
@IsTest
public with sharing class SettlementTaskActionsTest {
  public static final Id SETTLEMENT_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Settlement_Task')
    .getRecordTypeId();

  @IsTest
  static void testSettlementTaskRecordTypeAssignment() {
    Faker faker = new Faker('AU');
    List<Task> settlementTaskList = new List<Task>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      settlementTaskList.add(
        new Task(
          WhatId = Lib_FakeIdGenerator.getMockId(Settlement__c.getSObjectType())
        )
      );
    }

    Test.startTest();
    SettlementTaskActions.handleSettlementTasks(settlementTaskList);
    Test.stopTest();

    Assert.areEqual(
      SETTLEMENT_TASK_RT_ID,
      settlementTaskList[0].RecordTypeId,
      'Record Type IDs should be the same'
    );
  }

  @IsTest
  static void testCommentCardNumberMasking() {
    Faker faker = new Faker('AU');
    Map<Id, Task> settlementTaskOldMap = new Map<Id, Task>();
    List<Task> settlementTaskList = new List<Task>();
    //Create sample of card numbers to mock
    List<String> cardNumbers = new List<String>{
      '36521485964125',
      '365214859644125',
      '3652-148596-4125',
      '3652 1485 4596 4125',
      '3652148545964125',
      '3652-1485-4596-4125'
    };
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Id taskMockId = Lib_FakeIdGenerator.getMockId(Task.getSObjectType());
      Id settlementMockId = Lib_FakeIdGenerator.getMockId(
        Settlement__c.getSObjectType()
      );
      Task oldTask = new Task(
        Id = taskMockId,
        WhatId = settlementMockId,
        RecordTypeId = SETTLEMENT_TASK_RT_ID,
        Description = ''
      );
      settlementTaskOldMap.put(taskMockId, oldTask);
      //Need to create new task as updating the description after assigning to map still updates the task in the map
      Task newTask = new Task(
        Id = taskMockId,
        WhatId = settlementMockId,
        RecordTypeId = SETTLEMENT_TASK_RT_ID,
        Description = Faker.randomElement(cardNumbers)
      );
      settlementTaskList.add(newTask);
    }
    Test.startTest();
    SettlementTaskActions.applyRedaction(
      settlementTaskList,
      settlementTaskOldMap
    );
    Test.stopTest();
    for (Task settlementTask : settlementTaskList) {
      Assert.isFalse(
        cardNumbers.contains(settlementTask.Description),
        'Card number (' + settlementTask.Description + ') should be redacted'
      );
    }
  }

  @IsTest
  static void testCommentPrefixMasking() {
    Faker faker = new Faker('AU');
    Map<Id, Task> settlementTaskOldMap = new Map<Id, Task>();
    List<Task> settlementTaskList = new List<Task>();
    //Create sample of prefixes to mock - cant use faker for digits as
    //faker.randomInteger returns a int with a random length, not always the digits set
    List<String> prefixes = new List<String>{
      'TAX 123456789',
      'TIN 123456789',
      'TFN 123456789',
      'FILE 123456789',
      'ATO 123456789',
      'SUPER 123456789',
      'SUPERANNUATION 123456789',
      'EMPLOYMENT 123456789',
      'PASSPORT 123456789',
      'PP 123456789',
      'DL 123456789',
      'DRIVER\'S LICENCE 123456789',
      'LICENCE 123456789',
      'DRIVER\'S LICENSE 123456789',
      'LICENSE 123456789',
      'MEDICARE 123456789',
      'CENTRELINK CRN 123456789',
      'DVA NUMBER 123456789',
      'AUS 123456789'
    };
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Id taskMockId = Lib_FakeIdGenerator.getMockId(Task.getSObjectType());
      Id settlementMockId = Lib_FakeIdGenerator.getMockId(
        Settlement__c.getSObjectType()
      );
      Task oldTask = new Task(
        Id = taskMockId,
        WhatId = settlementMockId,
        RecordTypeId = SETTLEMENT_TASK_RT_ID,
        Description = ''
      );
      settlementTaskOldMap.put(taskMockId, oldTask);
      //Need to create new task as updating the description after assigning to map still updates the task in the map
      Task newTask = new Task(
        Id = taskMockId,
        WhatId = settlementMockId,
        RecordTypeId = SETTLEMENT_TASK_RT_ID,
        Description = Faker.randomElement(prefixes)
      );
      settlementTaskList.add(newTask);
    }
    Test.startTest();
    SettlementTaskActions.applyRedaction(
      settlementTaskList,
      settlementTaskOldMap
    );
    Test.stopTest();
    for (Task settlementTask : settlementTaskList) {
      Assert.isFalse(
        prefixes.contains(settlementTask.Description),
        'Prefix number (' + settlementTask.Description + ') should be redacted'
      );
    }
  }
}
