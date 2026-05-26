/**
 * @author Kopal Goswami
 * @since April 2025
 * @description This class is for testing the functionality of PushToAppAction
 */
@isTest
public with sharing class PushToAppActionTest {
  private static final Id FAKER_TASK_ID = Lib_FakeIdGenerator.getMockId(
    Task.getSObjectType()
  );

  private static final Id FAKER_CUSTOMER_TASK_DATA_ID = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testUpdateCustomerNudgeTask() {
    registerMocks();

    Test.startTest();
    PushToAppAction.updateCustomerNudgeTask(
      mockTaskRecordsList('New', PushToAppConstant.PUSH_TO_APP_TASK_TYPE)
    );
    Test.stopTest();

    List<Task> taskRecordsUpdated = (List<Task>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isTrue(
      taskRecordsUpdated[0].Subject.contains('TSK-00000001'),
      'Task Subject should show TaskNumber generated'
    );
    Assert.isTrue(
      taskRecordsUpdated[0].Pub_Sub_Event_Id__c.contains(FAKER_TASK_ID),
      'Task Subject should show TaskNumber generated'
    );
  }

  @isTest
  static void testAutoExpireCustomerNudgeTaskPositive() {
    registerMocks();
    pushToAppRepoMock.mock(
      'getRelatedCustomerNudgeTasksByType',
      mockTaskRecordsList('New', PushToAppConstant.PUSH_TO_APP_TASK_TYPE)
    );

    Test.startTest();
    PushToAppAction.autoExpireCustomerNudgeTask(
      mockCaseRecords('Escalated', RTCase.customerComplaint)
    );
    Test.stopTest();

    List<Task> taskUpdated = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      taskUpdated[0].Status == 'TASK_STATE_AUTO_ARCHIVED',
      'Task status should be updated to Auto Archived'
    );
  }

  @isTest
  static void testAutoExpireCustomerNudgeTaskNegative() {
    registerMocks();
    pushToAppRepoMock.mock(
      'getRelatedCustomerNudgeTasksByType',
      new List<Task>()
    );

    Test.startTest();
    PushToAppAction.autoExpireCustomerNudgeTask(
      mockCaseRecords('Escalated', RTCase.customerComplaint)
    );
    Test.stopTest();

    List<Task> taskUpdated = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      taskUpdated.size() == 0,
      'No Task is eligible for the update'
    );
  }

  @isTest
  static void testArchiveCustomerNudgeUploadTasksPositive() {
    registerMocks();
    pushToAppRepoMock.mock(
      'getRelatedCustomerNudgeTasksByType',
      mockTaskRecordsList('New', PushToAppConstant.ID_UPLOAD_TASK_TYPE)
    );

    Test.startTest();
    PushToAppAction.archiveCustomerNudgeUploadTasks(
      mockCaseRecords('Documents Uploaded', RTCase.kycQa)
    );
    Test.stopTest();

    List<Task> tasksToUpdate = (List<Task>) dmlRepoMock
      .getHistory('doUpdate')
      .getParam('records');

    Assert.isNotNull(tasksToUpdate, 'doUpdate should have been invoked');
    Assert.areEqual(
      'TASK_STATE_CUSTOMER_ARCHIVED',
      tasksToUpdate[0].Status,
      'Customer nudge task of type ID Upload should be customer archived'
    );
  }

  @isTest
  static void testArchiveCustomerNudgeUploadTasksNegative() {
    registerMocks();
    pushToAppRepoMock.mock(
      'getRelatedCustomerNudgeTasksByType',
      new List<Task>()
    );

    Test.startTest();
    PushToAppAction.archiveCustomerNudgeUploadTasks(
      mockCaseRecords('Documents Uploaded', RTCase.kycQa)
    );
    Test.stopTest();

    List<Task> tasksToUpdate = (List<Task>) dmlRepoMock
      .getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      tasksToUpdate.size() == 0,
      'No Task is eligible for the archive update'
    );
  }

  private static List<Task> mockTaskRecordsList(
    String statusValue,
    String tasktype
  ) {
    List<Task> tasklist = new List<Task>();
    tasklist.add(mockTaskRecord(statusValue, tasktype));
    return tasklist;
  }

  /**
   * @description helper method to create a mock task
   * @param statusValue statusValue
   * @param taskType task type to set in the mock task record
   * @return Mock Task
   */
  static Task mockTaskRecord(String statusValue, String taskType) {
    Id ownerId = UserInfo.getUserId();
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      FAKER_ACCOUNT_ID,
      FAKER_CASE_ID,
      ownerId,
      false
    );

    mockPushToAppTask.Id = FAKER_TASK_ID;
    mockPushToAppTask.Status = statusValue;
    mockPushToAppTask.Customer_Task_Data__c = FAKER_CUSTOMER_TASK_DATA_ID;
    mockPushToAppTask.Pub_Sub_Event_Id__c = '12345_12345';
    mockPushToAppTask.Type = taskType;

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }

  private static List<Case> mockCaseRecords(
    String statusValue,
    String recordTypeId
  ) {
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = FAKER_CASE_ID,
        AccountId = FAKER_ACCOUNT_ID,
        RecordTypeId = recordTypeId,
        Status = statusValue
      ),
      new Map<String, Object>{ 'CaseNumber' => '1234567' }
    );
    return new List<Case>{ caseRecord };
  }
}
