/**
 * @description Test class for CustomFieldHistoryAction
 * @author Arpit Pittie
 * @since Apr 22, 2024
 */
@isTest
public with sharing class CustomFieldHistoryActionTest {
  @isTest
  public static void testGetObjectHistoryMetadata() {
    Test.startTest();
    // Dummy Callouts for test coverage
    Custom_Dynamic_Object_History_Setting__mdt objectHisotry = CustomFieldHistoryActionHelper.getObjectHistoryMetadata(
      'Task'
    );
    List<Custom_Dynamic_Field_History_Setting__mdt> fieldHistoryList = CustomFieldHistoryActionHelper.getFieldHistoryMetadata(
      objectHisotry
    );
    Test.stopTest();
  }

  @isTest
  public static void testCreateFieldHistory() {
    Faker faker = new Faker('AU');
    Task callBackTask = TestDataFactory.createTaskRecord(
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
        .get('Callback_Request')
        .getRecordTypeId(),
      null,
      null,
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      false
    );

    Test.startTest();
    Task newCallBackTask = TestDataFactory.createTaskRecord(
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
        .get('Callback_Request')
        .getRecordTypeId(),
      null,
      null,
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      false
    );
    newCallBackTask.Status = 'Actioned';
    newCallBackTask.Id = callBackTask.Id;

    // Dummy callout for test coverage
    CustomFieldHistoryAction.createFieldHistory(
      new List<Task>{ newCallBackTask },
      new Map<Id, Task>{ callBackTask.Id => callBackTask }
    );
    Test.stopTest();
  }

  @isTest
  public static void testProcessCustomFieldHistoryForTask() {
    Faker faker = new Faker('AU');
    Task callBackTask = TestDataFactory.createTaskRecord(
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
        .get('Callback_Request')
        .getRecordTypeId(),
      null,
      null,
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      false
    );

    String customObjectHistoryMetadataJSON = '{"Table_Name__c":"ActivityFieldHistory__c","Label":"Task","MasterLabel":"Task","SystemModstamp":"2024-04-22T08:23:15.000+0000","SObject_Name__c":"Task","Language":"en_US","QualifiedApiName":"Task","DeveloperName":"Task"}';
    Custom_Dynamic_Object_History_Setting__mdt customObjectHistoryMetadata = (Custom_Dynamic_Object_History_Setting__mdt) JSON.deserialize(
      customObjectHistoryMetadataJSON,
      Custom_Dynamic_Object_History_Setting__mdt.class
    );

    String customFieldHistoryMetadataJSON = '[{"Field_Name__c":"Status"}, {"Field_Name__c":"OwnerId"}]';
    List<Custom_Dynamic_Field_History_Setting__mdt> customFieldHistoryMetadataList = (List<Custom_Dynamic_Field_History_Setting__mdt>) JSON.deserialize(
      customFieldHistoryMetadataJSON,
      List<Custom_Dynamic_Field_History_Setting__mdt>.class
    );
    Test.startTest();
    Task newCallBackTask = TestDataFactory.createTaskRecord(
      Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
        .get('Callback_Request')
        .getRecordTypeId(),
      null,
      null,
      Lib_FakeIdGenerator.getMockId(User.SObjectType),
      false
    );
    newCallBackTask.Status = 'Actioned';
    newCallBackTask.Id = callBackTask.Id;
    List<ActivityFieldHistory__c> activityHistoryList = (List<ActivityFieldHistory__c>) CustomFieldHistoryActionHelper.processCustomFieldHistory(
      new List<Task>{ newCallBackTask },
      new Map<Id, Task>{ callBackTask.Id => callBackTask },
      Task.SObjectType,
      customObjectHistoryMetadata,
      customFieldHistoryMetadataList
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      activityHistoryList.size(),
      'It should create 2 rows for history'
    );
    Assert.areEqual(
      'Actioned',
      activityHistoryList[0].New_Value__c,
      'It should store the new value properly'
    );
  }
}
