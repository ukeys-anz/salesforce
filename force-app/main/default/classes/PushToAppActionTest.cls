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

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testUpdateCustomerNudgeTask() {
    registerMocks();
    List<Task> taskRecords = mockTaskRecordsList('Transfer Funds Out');

    Test.startTest();
    PushToAppAction.updateCustomerNudgeTask(taskRecords);
    Test.stopTest();

    List<Task> taskRecordsUpdated = (List<Task>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );
    Assert.isTrue(
      taskRecordsUpdated[0].Subject.contains('TSK-00000001'),
      'Task Subject should show TaskNumber generated'
    );
    Assert.isTrue(
      taskRecordsUpdated[0].Pub_Sub_Event_Id__c.contains(FAKER_TASK_ID),
      'Task Subject should show TaskNumber generated'
    );
  }

  private static List<Task> mockTaskRecordsList(String actiontakenvalue) {
    List<Task> tasklist = new List<Task>();
    tasklist.add(mockTaskRecord(actiontakenvalue));
    return tasklist;
  }

  /**
   * @description helper method to create a mock task
   * @param actiontakenvalue actionTakenValue
   * @return Mock Task
   */
  static Task mockTaskRecord(String actiontakenvalue) {
    Id ownerId = UserInfo.getUserId();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.getSObjectType());

    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      accountId,
      caseId,
      ownerId,
      false
    );

    mockPushToAppTask.Id = FAKER_TASK_ID;
    mockPushToAppTask.Status = 'STATUS_SENT';
    mockPushToAppTask.Customer_Task_Data__c = FAKER_CUSTOMER_TASK_DATA_ID;
    mockPushToAppTask.Pub_Sub_Event_Id__c = '12345_12345';

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }
}
