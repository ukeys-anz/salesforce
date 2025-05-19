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
    List<Task> taskRecords = mockTaskRecordsList('New');

    Test.startTest();
    PushToAppAction.updateCustomerNudgeTask(taskRecords);
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
      'getRelatedCustomerNudgeTasks',
      mockTaskRecordsList('New')
    );

    List<Case> caseList = mockComplaintCaseRecords();
    Test.startTest();
    PushToAppAction.autoExpireCustomerNudgeTask(caseList);
    Test.stopTest();

    List<Task> taskUpdated = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      taskUpdated[0].Status == 'ACTIVITY_STATE_AUTO_ARCHIVED',
      'Task status should be updated to Auto Archived'
    );
  }

  @isTest
  static void testAutoExpireCustomerNudgeTaskNegative() {
    registerMocks();
    pushToAppRepoMock.mock('getRelatedCustomerNudgeTasks', new List<Task>());

    List<Case> caseList = mockComplaintCaseRecords();
    Test.startTest();
    PushToAppAction.autoExpireCustomerNudgeTask(caseList);
    Test.stopTest();

    List<Task> taskUpdated = (List<Task>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.isTrue(
      taskUpdated.size() == 0,
      'No Task is eligible for the update'
    );
  }

  private static List<Task> mockTaskRecordsList(String statusValue) {
    List<Task> tasklist = new List<Task>();
    tasklist.add(mockTaskRecord(statusValue));
    return tasklist;
  }

  /**
   * @description helper method to create a mock task
   * @param statusValue statusValue
   * @return Mock Task
   */
  static Task mockTaskRecord(String statusValue) {
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

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }

  private static List<Case> mockComplaintCaseRecords() {
    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = FAKER_CASE_ID,
        AccountId = FAKER_ACCOUNT_ID,
        RecordTypeId = RTCase.customerComplaint,
        Status = 'Escalated'
      ),
      new Map<String, Object>{ 'CaseNumber' => '1234567' }
    );
    return new List<Case>{ caseRecord };
  }
}
