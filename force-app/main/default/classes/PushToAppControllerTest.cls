/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Model Test class PushToAppController
 */
@IsTest
public with sharing class PushToAppControllerTest {
  /**
   * @description This method helps in providing the mock response from AEM
   * @return AEM content Data
   */
  private static String mockAemData {
    get {
      String mockAemContentDataResponse = [
          SELECT body
          FROM StaticResource
          WHERE Name = 'mock_aemContentData'
        ]
        .body.toString();
      return mockAemContentDataResponse;
    }
  }
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );

  private static final String FAKER_CONTACT_ID = (String) Lib_FakeIdGenerator.getMockId(
    Contact.SObjectType
  );

  private static final Id FAKER_NOTIFICATION_CONFIG_ID = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Configuration__c.getSObjectType()
  );

  private static final Id FAKER_NOTIFICATION_DATA = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );

  private static final Id CUSTOMER_ACTION_MOCK_ID1 = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );

  private static final Id CUSTOMER_ACTION_MOCK_ID2 = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );

  private static final Id FAKER_TASK_DATA = Lib_FakeIdGenerator.getMockId(
    Task.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider pushToAppRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testGetTemplateDetails() {
    registerMocks();
    pushToAppRepoMock.mock(
      'queryNotificationConfigrecords',
      mockNotificationConfigurationList()
    );

    Test.startTest();
    List<Customer_Task_Configuration__c> pushToAppTemplates = PushToAppController.getTemplateDetails(
      FAKER_CASE_ID
    );
    Test.stopTest();

    Assert.isTrue(
      pushToAppTemplates[0].AEM_Content_Id__c == 'get_in_touch_complaint',
      'AEM content id should be get_in_touch_complaint'
    );
  }

  @isTest
  static void testGetAemContentData() {
    registerMocks();
    pushToAppRepoMock.mock('queryMergeFieldsData', mockQueryMergeFieldsData());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockSelectedNotificationConfigDetail()
    );
    Test.startTest();
    AemDataModel notificationDetails = PushToAppController.getAemContentData(
      'get_in_touch_complaint',
      FAKER_CASE_ID
    );
    Test.stopTest();

    Assert.isTrue(
      notificationDetails.data.pushToAppList.items[0].id ==
      'get_in_touch_complaint',
      'Id should be get_in_touch_complaint'
    );

    Assert.isTrue(
      notificationDetails.data.pushToAppList.items[0].title == 'Get in touch',
      'Title should be Get in touch'
    );

    Assert.isTrue(
      notificationDetails.data.pushToAppList.items[0].reference ==
      'Complaint Ref 1234567',
      'Case Number should be 1234567'
    );
  }

  @isTest
  static void testCreateTaskAndRelatedRecords() {
    registerMocks();
    pushToAppRepoMock.mock('queryTaskDetails', mockqueryTaskDetails());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockSelectedNotificationConfigDetail()
    );
    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + FAKER_NOTIFICATION_DATA + '"}'
      )
    );
    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResults(
        new List<String>{
          '{"success":true,"id":"' +
          CUSTOMER_ACTION_MOCK_ID1 +
          '"}',
          '{"success":true,"id":"' +
          CUSTOMER_ACTION_MOCK_ID2 +
          '"}'
        }
      )
    );
    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + FAKER_TASK_DATA + '"}'
      )
    );

    PushToAppTaskWrapper taskResponseWrapperValue = mockTaskResponseWrapperValue();
    CustomerTaskDataWrapper notificationData = mockPushToAppNotifData();

    Test.startTest();
    Task taskRecord = PushToAppController.createTaskAndRelatedRecords(
      taskResponseWrapperValue,
      notificationData
    );
    Test.stopTest();

    Assert.isTrue(
      taskRecord.Id == FAKER_TASK_DATA,
      'task record should be created with Type as Push To App.'
    );
  }

  private static PushToAppTaskWrapper mockTaskResponseWrapperValue() {
    PushToAppTaskWrapper taskResponseWrapper = new PushToAppTaskWrapper();
    taskResponseWrapper.subject = 'Push To App - Get in touch';
    taskResponseWrapper.description = 'Message us';
    taskResponseWrapper.notificationConfigId = FAKER_NOTIFICATION_CONFIG_ID;
    taskResponseWrapper.whatId = FAKER_CASE_ID;
    taskResponseWrapper.callToAction = 'Call us';
    taskResponseWrapper.activityDate = '12/10/2024';
    return taskResponseWrapper;
  }

  private static CustomerTaskDataWrapper mockPushToAppNotifData() {
    CustomerTaskDataWrapper pushToAppNotifData = new CustomerTaskDataWrapper();
    pushToAppNotifData.aemContentData = mockAemData;
    pushToAppNotifData.aemContentObject = aemContentDataAsObject();
    return pushToAppNotifData;
  }

  private static CustomerActionWrapper aemContentDataAsObject() {
    CustomerActionWrapper.Action action = new CustomerActionWrapper.Action();
    action.deepLink = 'anz.com/.../transfer';
    action.description = 'Transfer Funds Out';
    action.icon = 'path/to/dark/icon';
    action.type = 'singleAction';
    CustomerActionWrapper.Step step = new CustomerActionWrapper.Step();
    step.title = 'Step1';
    step.actions = new List<CustomerActionWrapper.Action>{ action };
    CustomerActionWrapper customerAction = new CustomerActionWrapper();
    customerAction.bodyText = 'We called about your Case Reference 03772625 and couldn\'t reach you. Please call us back or send us a message';
    customerAction.expiryDate = '25/05/2025';
    customerAction.id = 'get_in_touch_complaint';
    customerAction.notificationConfigId = 'a36AD000000QbC1YAK';
    customerAction.reference = 'Complaint Ref 03772625';
    customerAction.subtitle = 'Hey Jane';
    customerAction.title = 'Get in touch';
    customerAction.steps = new List<CustomerActionWrapper.Step>{ step };

    return customerAction;
  }

  /**
   * @description helper method to create a mock task
   * @return Mock Task
   */
  private static Task mockQueryTaskDetails() {
    Id ownerId = UserInfo.getUserId();
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.getSObjectType());
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      accountId,
      FAKER_CASE_ID,
      ownerId,
      false
    );

    mockPushToAppTask.Id = FAKER_TASK_DATA;
    mockPushToAppTask.Status = 'New';
    return mockPushToAppTask;
  }

  private static List<Customer_Task_Configuration__c> mockNotificationConfigurationList() {
    List<Customer_Task_Configuration__c> listofNotificConfig = new List<Customer_Task_Configuration__c>();
    Customer_Task_Configuration__c testNotificConfig = mockSelectedNotificationConfigDetail();
    listofNotificConfig.add(testNotificConfig);
    return listofNotificConfig;
  }

  private static List<sObject> mockQueryMergeFieldsData() {
    List<SObject> listofSObject = new List<SObject>();

    Case caseRecord = (Case) TestUtil.setFields(
      new Case(
        Id = FAKER_CASE_ID,
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
      ),
      new Map<String, Object>{ 'CaseNumber' => '1234567' }
    );

    listofSObject.add(caseRecord);
    return listofSObject;
  }

  private static Customer_Task_Configuration__c mockSelectedNotificationConfigDetail() {
    Customer_Task_Configuration__c testNotificConfig = new Customer_Task_Configuration__c(
      AEM_Content_Id__c = 'get_in_touch_complaint',
      Applicable_Record_Types__c = 'Account Closure',
      Applicable_User_Role__c = 'Coach',
      SObject_Type__c = 'Case',
      Name = 'Get In Touch',
      Expire_After_Days__c = 12,
      Id = FAKER_NOTIFICATION_CONFIG_ID
    );
    return testNotificConfig;
  }
}
