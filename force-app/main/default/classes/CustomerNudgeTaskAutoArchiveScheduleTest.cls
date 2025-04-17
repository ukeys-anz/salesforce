/**
 * @author Shivam Swaraj
 * @since 10/2024
 * @description  test class for CustomerNudgeTaskAutoExpireScheduler
 */
@isTest
public with sharing class CustomerNudgeTaskAutoArchiveScheduleTest {
  private static final String TASK_AUTO_ARCHIVED = 'STATUS_AUTO_ARCHIVED';

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider cdmRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    cdmRepoMock = Lib_MockProvider.forType(PushToAppRepository.class)
      .mock('queryCustomerNudgeTasksToArchive', createMockTaskRecord());
  }
  @isTest
  public static void testCustomerNudgeTaskAutoArchiveScheduler() {
    registerMocks();
    Test.startTest();
    // Dummy call for test coverage
    CustomerNudgeTaskAutoArchiveScheduler cusNudgeSch = new CustomerNudgeTaskAutoArchiveScheduler();
    cusNudgeSch.execute(null);
    Test.stopTest();
    List<Task> archiveTasks = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.isTrue(
      archiveTasks[0].Status == TASK_AUTO_ARCHIVED,
      'Status should be auto archived'
    );
  }

  private static List<Task> createMockTaskRecord() {
    List<Task> mockTaskRecords = new List<Task>();
    Task cusNudgeTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      false
    );
    cusNudgeTask.Id = Lib_FakeIdGenerator.getMockId(Task.SObjectType);
    mockTaskRecords.add(cusNudgeTask);
    return mockTaskRecords;
  }
}
