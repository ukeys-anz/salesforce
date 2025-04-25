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

  static Lib_MockProvider pushToAppRepoMock;
  static void registerMocks() {
    pushToAppRepoMock = Lib_MockProvider.forType(PushToAppRepository.class);
  }

  @isTest
  static void testCustomerNudgeTaskCloudEventModel() {
    registerMocks();
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      new Customer_Task_Data__c()
    );
    Task taskRecord = mockTaskRecord();

    // Call the constructor for CustomerNudgeTaskCloudEventModel
    CustomerNudgeTaskCloudEventModel model = new CustomerNudgeTaskCloudEventModel(
      taskRecord,
      'created'
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

    // Validate the ce_xtargets
    Assert.areEqual(
      'Notification/' + taskRecord.Pub_Sub_Event_Id__c,
      model.ce_xtargets,
      'ce_xtargets is set correctly.'
    );

    // Validate systemData
    CloudEventModel.CloudEventSystemModel systemData = (CloudEventModel.CloudEventSystemModel) model.systemData;
    Assert.areEqual(
      taskRecord.LastModifiedDate,
      systemData.lastModifiedTime,
      'LastModifiedDate is correct in systemData.'
    );

    // Validate the data model (CustomerNudgeTaskCloudDataModel)
    CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel dataModel = (CustomerNudgeTaskCloudEventModel.CustomerNudgeTaskCloudDataModel) model.ce_data;
    Assert.isNull(dataModel.notification, 'Notification should be null');
    Assert.areEqual(
      taskRecord.Pub_Sub_Event_Id__c,
      dataModel.producer_command_key,
      'producer_command_key is set correctly.'
    );
  }

  private static Task mockTaskRecord() {
    // Create a Task record to use as test data
    Task testTask = new Task(
      Id = FAKER_TASK_ID,
      Status = 'ACTIVITY_STATE_SENT',
      Subject = 'Get In Touch',
      Pub_Sub_Event_Id__c = '12345',
      LastModifiedById = UserInfo.getUserId(),
      LastModifiedDate = System.now()
    );
    return testTask;
  }
}
