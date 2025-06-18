/**
 * @author Kopal Goswami
 * @since  10/2024
 * @description Test Class for CustomerNudgeTaskCloudEventModel
 */
@IsTest
public with sharing class CustomerNudgeTaskCloudEventModelTest {
  private static final Id FAKER_TASK_ID = Lib_FakeIdGenerator.getMockId(
    Task.getSObjectType()
  );

  @isTest
  static void testCustomerNudgeTaskCloudEventModelPositive() {
    Task taskRecord = mockTaskRecord();
    // Call the constructor for CustomerNudgeTaskCloudEventModel
    CustomerNudgeTaskCloudEventModel model = new CustomerNudgeTaskCloudEventModel(
      taskRecord,
      TestDataFactory.createAccount('account1', false),
      mockAemContentData(),
      new CloudEventModel.UserModel()
    );

    // Validate the ce_type
    String expectedCeType =
      System.Label.ANZX_Customer_Nudge_event_ce_type + 'created';
    Assert.areEqual(expectedCeType, model.ce_type, 'ce_type is set correctly.');

    // Validate the ce_subject
    Assert.areEqual(
      'Pub_Sub_Event_Id__c/' + taskRecord.Pub_Sub_Event_Id__c,
      model.ce_subject,
      'ce_subject is set correctly.'
    );

    // Validate the ce_dataschema
    Assert.areEqual(
      System.Label.ANZX_Customer_Nudge_Event_Proto_Data_Schema,
      model.ce_dataschema,
      'ce_dataschema is set correctly.'
    );

    // Validate the ce_partitionkey
    Assert.areEqual(
      'Pub_Sub_Event_Id__c/' + taskRecord.Pub_Sub_Event_Id__c,
      model.ce_partitionkey,
      'ce_partitionkey is set correctly.'
    );

    // Validate the data model (CustomerNudgeTaskCloudDataModel)
    CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel dataModel = (CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel) model.ce_data;
    Assert.isNotNull(
      dataModel.data.notification,
      'Notification node should not be null'
    );
    Assert.areEqual(
      taskRecord.Pub_Sub_Event_Id__c,
      dataModel.data.producerCommandKey,
      'producerCommandKey is set correctly.'
    );
  }

  @isTest
  static void testCustomerNudgeTaskCloudEventModelNegative() {
    Task taskRecord = mockTaskRecord();
    // Call the constructor for CustomerNudgeTaskCloudEventModel
    CustomerNudgeTaskCloudEventModel model = new CustomerNudgeTaskCloudEventModel(
      taskRecord,
      TestDataFactory.createAccount('account1', false),
      '',
      new CloudEventModel.UserModel()
    );

    CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel dataModel = (CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel) model.ce_data;
    Assert.isNull(dataModel.data.notification, 'Notification node be null');
  }

  /**
   * @description helper method to create a mock task
   * @return Mock Task
   */
  static Task mockTaskRecord() {
    Task mockPushToAppTask = TestDataFactory.createTaskRecord(
      RTTask.customerNudge,
      Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
      Lib_FakeIdGenerator.getMockId(Case.getSObjectType()),
      UserInfo.getUserId(),
      false
    );

    mockPushToAppTask.Id = FAKER_TASK_ID;
    mockPushToAppTask.Status = 'New';
    mockPushToAppTask.Pub_Sub_Event_Id__c = '12345_12';

    Task taskRecord = (Task) TestUtil.setFields(
      mockPushToAppTask,
      new Map<String, Object>{ 'TaskNumber__c' => 'TSK-00000001' }
    );
    return taskRecord;
  }

  static String mockAemContentData() {
    return '{\"bodyText\":\"Testing\",\"iconDarkURI\":\"path/to/dark/icon\",\"iconLightURI\":\"path/to/light/icon\",\"steps\":[{\"actions\":[{\"deepLink\":\"anz.com/.../transfer\",\"iconDarkURI\":\"path/to/dark/icon\",\"iconLightURI\":\"path/to/light/icon\"}]}],\"subtitle\":\"Hey Jane\",\"title\":\"Get in touch\"}';
  }
}
