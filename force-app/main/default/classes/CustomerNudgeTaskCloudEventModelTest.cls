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
      'queryCustomerNudgeTaskDetails',
      mockQueryCustomerNudgeTaskDetails()
    );
    pushToAppRepoMock.mock(
      'queryCustomerTaskDataDetails',
      new Customer_Task_Data__c()
    );
    Task taskRecord = mockTaskRecord();

    // Call the constructor for CustomerNudgeTaskCloudEventModel
    CustomerNudgeTaskCloudEventModel model = new CustomerNudgeTaskCloudEventModel(
      taskRecord
    );

    // Validate the ce_type
    String expectedCeType =
      System.Label.ANZX_Customer_Nudge_event_ce_type +
      taskRecord.Status.toLowerCase();
    Assert.areEqual(expectedCeType, model.ce_type, 'ce_type is set correctly.');

    // Validate the ce_subject
    String expectedCeSubject =
      'TaskExternalId/' + taskRecord.Pub_Sub_Event_Id__c;
    Assert.areEqual(
      expectedCeSubject,
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
    String expectedPartitionKey =
      'TaskExternalId/' + taskRecord.Pub_Sub_Event_Id__c;
    Assert.areEqual(
      expectedPartitionKey,
      model.ce_partitionkey,
      'ce_partitionkey is set correctly.'
    );

    // Validate the ce_xtargets
    String expectedXtargets = 'Notification/' + taskRecord.Pub_Sub_Event_Id__c;
    Assert.areEqual(
      expectedXtargets,
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
    Assert.areEqual(
      taskRecord.Pub_Sub_Event_Id__c,
      dataModel.taskExternalId,
      'TaskExternalId is set correctly in ce_data.'
    );
    Assert.areEqual(
      taskRecord.Status,
      dataModel.status,
      'Status is set correctly in ce_data.'
    );
    Assert.areEqual(
      taskRecord.Subject,
      dataModel.subject,
      'Subject is set correctly in ce_data'
    );
  }

  private static Task mockTaskRecord() {
    // Create a Task record to use as test data
    Task testTask = new Task(
      Id = FAKER_TASK_ID,
      Status = 'STATUS_SENT',
      Subject = 'Get In Touch',
      Pub_Sub_Event_Id__c = '12345',
      LastModifiedById = UserInfo.getUserId(),
      LastModifiedDate = System.now()
    );
    return testTask;
  }

  private static Customer_Task_Configuration__c mockQueryCustomerNudgeTaskDetails() {
    Customer_Task_Configuration__c testCustomerTaskConfig = new Customer_Task_Configuration__c(
      AEM_Content_Id__c = 'get_in_touch_complaint',
      Applicable_Record_Types__c = 'Account Closure',
      Applicable_User_Role__c = 'Coach',
      SObject_Type__c = 'Case',
      Name = 'Get In Touch',
      Expire_After_Days__c = 12,
      Id = Lib_FakeIdGenerator.getMockId(
        Customer_Task_Configuration__c.getSObjectType()
      )
    );
    return testCustomerTaskConfig;
  }
}
