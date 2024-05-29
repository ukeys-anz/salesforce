/**
 * @author Hrushikesh Pathak
 * @since 02/2024
 * @description  test class for CoachNudgeTaskAutoExpireScheduler
 */
@isTest
public with sharing class CoachNudgeTaskAutoExpireSchedulerTest {
  @isTest
  public static void testCheckAndUpdateTaskRecords() {
    Faker faker = new Faker('AU');
    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.COACH_NUDGE_RT_ID,
      null,
      Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType),
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    Task callBackTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.CALLBACK_REQUEST_RT_ID,
      Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      null,
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    callBackTask.Status = GetHelpTaskActions.TASK_STATUS_NEW;
    Test.startTest();
    // Dummy call for test coverage
    CoachNudgeTaskAutoExpireScheduler coachNudgeSch = new CoachNudgeTaskAutoExpireScheduler();
    coachNudgeSch.execute(null);
    // Method to test updation of task to expired
    List<Task> updatedRecords = CoachNudgeTaskAutoExpireScheduler.checkAndUpdateTaskRecords(
      new List<Task>{ coachNudgeTask, callBackTask }
    );
    Test.stopTest();
    Assert.isTrue(
      updatedRecords[0].Status == GetHelpTaskActions.TASK_STATUS_EXPIRED,
      'Status should be expired'
    );
    Assert.isTrue(
      updatedRecords[1].Status == GetHelpTaskActions.TASK_STATUS_EXPIRED,
      'Status should be expired'
    );
  }
}
