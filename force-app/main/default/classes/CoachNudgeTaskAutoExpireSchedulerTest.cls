/**
 * @author Hrushikesh Pathak
 * @since 02/2024
 * @description  test class for CoachNudgeTaskAutoExpireScheduler
 */
@isTest
public with sharing class CoachNudgeTaskAutoExpireSchedulerTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider cdmRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    cdmRepoMock = Lib_MockProvider.forType(CoachNudgeRepository.class)
      .mock('queryTasksToExpire', createMockTaskRecord());
  }
  @isTest
  public static void testCheckAndUpdateTaskRecords() {
    registerMocks();
    Test.startTest();
    // Dummy call for test coverage
    CoachNudgeTaskAutoExpireScheduler coachNudgeSch = new CoachNudgeTaskAutoExpireScheduler();
    coachNudgeSch.execute(null);
    Test.stopTest();
    List<Task> expireTasks = (List<Task>) dmlRepoMock.getHistory(
        'updateRecords'
      )
      .getParam('records');
    Assert.isTrue(
      expireTasks[0].Status == GetHelpTaskActions.TASK_STATUS_EXPIRED,
      'Status should be expired'
    );
    Assert.isTrue(
      expireTasks[0].Sub_Status__c ==
      GetHelpTaskActions.TASK_SUB_STATUS_AUTO_CANCELLED,
      'Sub Status should be Auto Cancelled'
    );
    Assert.isTrue(
      expireTasks[1].Status == GetHelpTaskActions.TASK_STATUS_EXPIRED,
      'Status should be expired'
    );
    Assert.isTrue(
      expireTasks[1].Sub_Status__c ==
      GetHelpTaskActions.TASK_SUB_STATUS_AUTO_CANCELLED,
      'Sub Status should be Auto Cancelled'
    );
  }

  private static List<Task> createMockTaskRecord() {
    List<Task> mockTaskRecords = new List<Task>();
    Faker faker = new Faker('AU');
    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.COACH_NUDGE_RT_ID,
      null,
      Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType),
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    coachNudgeTask.Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType);
    mockTaskRecords.add(coachNudgeTask);
    Task callBackTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.CALLBACK_REQUEST_RT_ID,
      Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      null,
      Lib_FakeIdGenerator.getMockId(Group.SObjectType),
      false
    );
    callBackTask.Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType);
    callBackTask.Status = GetHelpTaskActions.TASK_STATUS_NEW;
    mockTaskRecords.add(callBackTask);
    return mockTaskRecords;
  }
}
