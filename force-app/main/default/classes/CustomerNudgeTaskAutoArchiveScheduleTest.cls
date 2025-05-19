/**
 * @author Shivam Swaraj
 * @since 10/2024
 * @description  test class for CustomerNudgeTaskAutoExpireScheduler
 */
@isTest
public with sharing class CustomerNudgeTaskAutoArchiveScheduleTest {
  private static final String TASK_AUTO_ARCHIVED = 'ACTIVITY_STATE_AUTO_ARCHIVED';
  private static final String FAKER_TASK_ID = (String) Lib_FakeIdGenerator.getMockId(
    Task.SObjectType
  );
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
    dmlRepoMock.mock(
      'doUpdate',
      getMockSaveResults(
        '[{"success":true,"id":"' + FAKER_TASK_ID + '"}]'
      )
    );
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
    cusNudgeTask.Id = FAKER_TASK_ID;
    mockTaskRecords.add(cusNudgeTask);
    return mockTaskRecords;
  }
    
     /**
   * @description This method is used to mock the behavior of a DML insert operation that returns multiple UpsertResult objects.
   * This is helpful for test cases where multiple records are inserted at once
   * @param mockUpsertResultString An array of JSON strings, where each string represents a mock UpsertResult for each record being inserted.
   * @return List<Database.UpsertResult> objects corresponding to the mock JSON strings.
   */
  private static List<Database.SaveResult> getMockSaveResults(
    String mockSaveResultString
  ) {
    return (List<Database.SaveResult>) JSON.deserialize(
      mockSaveResultString,
      List<Database.SaveResult>.class
    );
  }
}