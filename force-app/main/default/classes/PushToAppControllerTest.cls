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

  private static final Id FAKER_NOTIFICATION_CONFIG_ID = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Configuration__c.getSObjectType()
  );

  private static final Id FAKER_NOTIFICATION_DATA = Lib_FakeIdGenerator.getMockId(
    Customer_Task_Data__c.getSObjectType()
  );

  private static final Id FAKER_TASK_DATA = Lib_FakeIdGenerator.getMockId(
    Task.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider pushToAppRepoMock;
  static Lib_MockProvider pushToAppUtilRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
    pushToAppUtilRepoMock = Lib_MockProvider.forType(PushToAppUtility.class);
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
    AemDataWrapper notificationDetails = PushToAppController.getAemContentData(
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
  static void testCreateTaskAndNotificationData() {
    registerMocks();
    pushToAppRepoMock.mock('queryTaskDetails', mockqueryTaskDetails());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockSelectedNotificationConfigDetail()
    );
    pushToAppUtilRepoMock.mock(
      'queryCustomerContactId',
      mockqueryCustomerContactId()
    );
    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + FAKER_NOTIFICATION_DATA + '"}'
      )
    );

    String taskResponseWrapperValue = mockTaskResponseWrapperValue();
    String notificationData = mockPushToAppNotifData();

    Test.startTest();
    Task taskRecord = PushToAppController.createTaskAndNotificationData(
      taskResponseWrapperValue,
      notificationData
    );
    Test.stopTest();

    Assert.isTrue(
      taskRecord.Id == FAKER_TASK_DATA,
      'task record should be created with Type as Push To App.'
    );
  }

  @isTest
  static void testCreateNotificationData() {
    registerMocks();
    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + FAKER_NOTIFICATION_DATA + '"}'
      )
    );

    String notificationData = mockPushToAppNotifData();

    Test.startTest();
    PushToAppController.createNotificationData(notificationData);
    Test.stopTest();

    Customer_Task_Data__c notifDataRecord = (Customer_Task_Data__c) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('record');

    Assert.isNotNull(
      notifDataRecord.AEM_Content_Data__c,
      'Notification Data Record should be inserted'
    );
  }

  @isTest
  static void testCreatePushToAppTask() {
    registerMocks();
    pushToAppRepoMock.mock('queryTaskDetails', mockqueryTaskDetails());
    pushToAppRepoMock.mock(
      'selectedNotificationConfigDetail',
      mockSelectedNotificationConfigDetail()
    );
    pushToAppUtilRepoMock.mock(
      'queryCustomerContactId',
      mockqueryCustomerContactId()
    );

    dmlRepoMock.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"' + FAKER_NOTIFICATION_DATA + '"}'
      )
    );

    String taskResponseWrapperValue = mockTaskResponseWrapperValue();

    Test.startTest();
    PushToAppController.createPushToAppTask(
      taskResponseWrapperValue,
      FAKER_NOTIFICATION_DATA
    );
    Test.stopTest();

    Task taskRecord = (Task) dmlRepoMock.getHistory('doInsert')
      .getParam('record');

    Assert.isTrue(
      taskRecord.Type == 'Push To App',
      'task record should be created with type Push To App.'
    );
  }

  private static String mockTaskResponseWrapperValue() {
    Map<String, String> taskResponse = new Map<String, String>{
      'subject' => 'Push To App - Get in touch',
      'description' => 'Message us',
      'notificationConfigId' => FAKER_NOTIFICATION_CONFIG_ID,
      'whatId' => FAKER_CASE_ID,
      'callToAction' => 'Call us',
      'activityDate' => '12/10/2024'
    };
    String taskResponseWrapperValue = JSON.serialize(taskResponse);
    return taskResponseWrapperValue;
  }

  private static String mockPushToAppNotifData() {
    Map<String, String> pushToAppNotifDataResponse = new Map<String, String>{
      'aemContentData' => mockAemData
    };
    String pushToAppNotifData = JSON.serialize(pushToAppNotifDataResponse);
    return pushToAppNotifData;
  }

  private static String mockqueryCustomerContactId() {
    return Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
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
