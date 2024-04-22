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
}
