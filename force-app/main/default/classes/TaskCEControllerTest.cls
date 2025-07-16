/**
 * @author Kopal Goswami
 * @since  May/2025
 * @description Test Class for TaskCEController
 */
@isTest
public with sharing class TaskCEControllerTest {
  private static final Id FAKER_TASK_ID = Lib_FakeIdGenerator.getMockId(
    Task.getSObjectType()
  );

  private static final Id FAKER_CUSTOMER_TASK_DATA_ID = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );

  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testGenerateCloudEventModelPositive() {
    registerMocks();

    pushToAppRepoMock.mock('queryAccountDetails', new List<Account>());
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      mockQueryCustomerTaskDataDetails()
    );
    pushToAppRepoMock.mock('getUsers', new List<User>());
    pushToAppRepoMock.mock('queryTaskRecords', mockTaskRecordsList('New'));

    Test.startTest();
    TaskCEController.TaskCloudEventContexT taskCEContext = TaskCEController.buildContext(
      mockTaskRecordsList('New')
    );
    List<CloudEventModel> taskCloudEvent = TaskCEController.buildCloudEvent(
      mockTaskRecordsList('New'),
      taskCEContext
    );
    Test.stopTest();

    CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel dataModel = (CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel) taskCloudEvent[0]
      .ce_data;
    Assert.isNotNull(
      dataModel.data.notification,
      'Notification node should not be null'
    );
    Assert.areEqual(
      System.Label.ANZX_Customer_Nudge_event_ce_type + 'created',
      taskCloudEvent[0].ce_type,
      'ce_type is set correctly.'
    );
  }

  @isTest
  static void testGenerateCloudEventModelNegative() {
    registerMocks();

    pushToAppRepoMock.mock('queryAccountDetails', new List<Account>());
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      mockQueryCustomerTaskDataDetails()
    );
    pushToAppRepoMock.mock('getUsers', new List<User>());
    pushToAppRepoMock.mock(
      'queryTaskRecords',
      mockTaskRecordsList('TASK_STATE_SENT')
    );

    Test.startTest();
    TaskCEController.TaskCloudEventContexT taskCEContext = TaskCEController.buildContext(
      mockTaskRecordsList('TASK_STATE_SENT')
    );
    List<CloudEventModel> taskCloudEvent = TaskCEController.buildCloudEvent(
      mockTaskRecordsList('TASK_STATE_SENT'),
      taskCEContext
    );
    Test.stopTest();

    CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel dataModel = (CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel) taskCloudEvent[0]
      .ce_data;
    Assert.isNull(dataModel.data.notification, 'Notification node is null');
    Assert.areEqual(
      System.Label.ANZX_Customer_Nudge_event_ce_type + 'updated',
      taskCloudEvent[0].ce_type,
      'ce_type is set correctly.'
    );
  }

  @isTest
  static void testPublishCloudEventsPositive() {
    registerMocks();

    pushToAppRepoMock.mock('queryAccountDetails', new List<Account>());
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      mockQueryCustomerTaskDataDetails()
    );
    pushToAppRepoMock.mock('getUsers', new List<User>());
    pushToAppRepoMock.mock('queryTaskRecords', mockTaskRecordsList('New'));

    Test.startTest();
    TaskCEController.publishCloudEvents(mockTaskRecordsList('New'));
    Test.stopTest();

    String payload = CloudEventController.cloudEvents[0].Data_1__c;

    Assert.isTrue(
      payload.contains('title'),
      'Title Node should not be present in the payload'
    );
  }

  @isTest
  static void testPublishCloudEventsNegative() {
    registerMocks();

    pushToAppRepoMock.mock('queryAccountDetails', new List<Account>());
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      mockQueryCustomerTaskDataDetails()
    );
    pushToAppRepoMock.mock('getUsers', new List<User>());
    pushToAppRepoMock.mock(
      'queryTaskRecords',
      mockTaskRecordsList('TASK_STATE_SENT')
    );

    Test.startTest();
    TaskCEController.publishCloudEvents(mockTaskRecordsList('TASK_STATE_SENT'));
    Test.stopTest();

    String payload = CloudEventController.cloudEvents[0].Data_1__c;

    Assert.isFalse(
      payload.contains('title'),
      'Title Node should not be present in the payload'
    );
  }

  private static List<Task> mockTaskRecordsList(String statusValue) {
    List<Task> tasklist = new List<Task>();
    tasklist.add(mockTaskRecord(statusValue));
    return tasklist;
  }

  /**
   * @description helper method to create a mock task
   * @param statusValue task record's status
   * @return Mock Task
   */
  static Task mockTaskRecord(String statusValue) {
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      UserInfo.getUserId(),
      false
    );

    mockPushToAppTask.Id = FAKER_TASK_ID;
    mockPushToAppTask.Status = statusValue;
    mockPushToAppTask.Customer_Task_Data__c = FAKER_CUSTOMER_TASK_DATA_ID;
    mockPushToAppTask.Pub_Sub_Event_Id__c = '12345_12';
    mockPushToAppTask.Type = 'Push To App';
    mockPushToAppTask.ActivityDate = Date.today();

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }

  private static List<Customer_Task_Data__c> mockQueryCustomerTaskDataDetails() {
    List<Customer_Task_Data__c> customerTaskDataList = new List<Customer_Task_Data__c>();
    Customer_Task_Data__c testCustomerTaskData = new Customer_Task_Data__c(
      Id = FAKER_CUSTOMER_TASK_DATA_ID,
      AEM_Content_Data__c = '{\"bodyText\":\"Testing\",\"iconDarkURI\":\"path/to/dark/icon\",\"iconLightURI\":\"path/to/light/icon\",\"steps\":[{\"actions\":[{\"deepLink\":\"anz.com/.../transfer\",\"iconDarkURI\":\"path/to/dark/icon\",\"iconLightURI\":\"path/to/light/icon\"}]}],\"subtitle\":\"Hey Jane\",\"title\":\"Get in touch\"}'
    );
    customerTaskDataList.add(testCustomerTaskData);
    return customerTaskDataList;
  }
}
