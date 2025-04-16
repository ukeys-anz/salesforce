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

  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testCreateTaskCloudEventPositive() {
    registerMocks();
    pushToAppRepoMock.mock(
      'queryCustomerNudgeTaskDetails',
      new Customer_Task_Configuration__c()
    );
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      new Customer_Task_Data__c()
    );

    Test.startTest();
    PushToAppAction.createTaskCloudEvent(
      mockTaskRecordsList('Transfer Funds Out')
    );
    Test.stopTest();

    String payload = CloudEventController.cloudEvents[0].Data_1__c;

    CustomerNudgeTaskCloudEventModel customerNudgeTaskModel = (CustomerNudgeTaskCloudEventModel) JSON.deserialize(
      payload,
      CustomerNudgeTaskCloudEventModel.class
    );

    Assert.areEqual(
      System.Label.ANZX_Customer_Nudge_event_ce_type + 'status_sent',
      customerNudgeTaskModel.ce_type,
      'ce_type is set correctly.'
    );
    Assert.isTrue(
      payload.contains('actionTaken'),
      'Action Taken Node should be present in the payload'
    );
  }

  @isTest
  static void testCreateTaskCloudEventNegative() {
    registerMocks();
    pushToAppRepoMock.mock(
      'queryCustomerNudgeTaskDetails',
      new Customer_Task_Configuration__c()
    );
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      new Customer_Task_Data__c()
    );

    Test.startTest();
    PushToAppAction.createTaskCloudEvent(mockTaskRecordsList(null));
    Test.stopTest();

    String payload = CloudEventController.cloudEvents[0].Data_1__c;

    CustomerNudgeTaskCloudEventModel customerNudgeTaskModel = (CustomerNudgeTaskCloudEventModel) JSON.deserialize(
      payload,
      CustomerNudgeTaskCloudEventModel.class
    );
    Assert.isFalse(
      payload.contains('actionTaken'),
      'Action Taken Node should not be present in the payload'
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
    mockPushToAppTask.Action_Taken__c = actiontakenvalue;
    mockPushToAppTask.Status = 'STATUS_SENT';

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }
}
