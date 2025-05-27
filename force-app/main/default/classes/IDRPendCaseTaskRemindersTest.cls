/**
 * @author Adnan, Anuja Vats
 * @since  09/2021
 * @description Test class for Pend Case Task Reminders.
 */
@IsTest
public with sharing class IDRPendCaseTaskRemindersTest {
  static Lib_MockProvider taskRepoMock;
  static void registerMocks() {
    taskRepoMock = Lib_MockProvider.forType(IDRTaskActionsRepository.class);
  }
  static final Faker FAKER = new Faker('0-9');
  static Case caseRecord = (Case) TestUtil.setFields(
    new Case(Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType)),
    new Map<String, Object>{ 'CaseNumber' => FAKER.randomInteger(6) }
  );
  static Task pendTask1 = (Task) TestUtil.setFields(
    new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Date_Case_on_Hold_From__c = Date.TODAY(),
      Status = IDRConstants.OPEN_STATUS,
      RecordTypeId = RTTask.idrTask,
      Type = IDRConstants.TASK_TYPE_PEND_CASE
    ),
    new Map<String, Object>{ 'Due_in_Days__c' => '1' }
  );
  static Task pendTask2 = (Task) TestUtil.setFields(
    new Task(
      Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType),
      Date_Case_on_Hold_From__c = Date.TODAY(),
      Status = IDRConstants.OPEN_STATUS,
      RecordTypeId = RTTask.idrTask,
      Type = IDRConstants.TASK_TYPE_PEND_CASE
    ),
    new Map<String, Object>{ 'Due_in_Days__c' => '2' }
  );

  @IsTest
  static void testTaskRemindersNotificationSent() {
    registerMocks();
    Case testCase = caseRecord;
    Task taskRecord = pendTask1;
    taskRecord.WhatId = testCase.Id;
    taskRepoMock.mock('queryCases', new List<Case>{ testCase });
    Test.startTest();
    SchedulableContext sc = null;
    IDRPendCaseTaskRemindersScheduler schedule = new IDRPendCaseTaskRemindersScheduler();
    schedule.execute(sc);
    List<IDRBankerNotificationWrapper> pendCaseTaskWrapper = IDRPendCaseTaskRemindersHandler.createWrapper(
      new List<Task>{ taskRecord }
    );
    Test.stopTest();

    //Asserts
    //We cannot check if the notification is sent or not, hence verifying the wrapper if its properly built

    Assert.isTrue(
      pendCaseTaskWrapper.size() == 1,
      'Pend Task notification Wrapper created successfully'
    );
    Assert.isTrue(
      pendCaseTaskWrapper[0].msgTitle ==
      IDRPendCaseTaskRemindersHandler.PEND_TASK_REMINDER,
      'Message title is as expected'
    );
    Assert.isTrue(
      pendCaseTaskWrapper[0].relatedCaseRecord.Id == caseRecord.Id,
      'Case Record in wrapper is as expected'
    );
    Assert.isTrue(
      pendCaseTaskWrapper[0].msgBody ==
      'Pend Task for Case : ' + caseRecord.CaseNumber + ' is due in 1 Days.',
      'Message Body is as expected'
    );
  }

  @IsTest
  static void testTaskRemindersNotificationNotSent() {
    registerMocks();
    Case testCase = caseRecord;
    Task taskRecord = pendTask2;
    taskRecord.WhatId = testCase.Id;
    taskRepoMock.mock('queryCases', new List<Case>{ testCase });
    Test.startTest();
    List<IDRBankerNotificationWrapper> pendCaseTaskWrapper = IDRPendCaseTaskRemindersHandler.createWrapper(
      new List<Task>{ taskRecord }
    );
    Test.stopTest();

    Assert.isFalse(
      pendCaseTaskWrapper.size() > 0,
      'Pend Task notification Wrapper was not created as notification is only sent when Due_in_Days__c is in {1,3,5,7} or is overdue'
    );
  }
}
