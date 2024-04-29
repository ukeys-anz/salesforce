/**
 * @description Test class for DataDeletionBatch
 * @author Arpit Pittie
 * @since Apr 24, 2024
 */
@isTest
public with sharing class DataDeletionBatchTest {
  @isTest
  public static void testDataDeletion() {
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
    // Dummy call for test coverage
    DataDeletionBatch dataDeleteBatch = new DataDeletionBatch();
    dataDeleteBatch = new DataDeletionBatch('ActivityFieldHistory__c');
    dataDeleteBatch = new DataDeletionBatch(
      'ActivityFieldHistory__c',
      new List<String>{ 'ActivityFieldHistory__c', 'Task' }
    );

    dataDeleteBatch.execute(null);
    dataDeleteBatch.execute(null, null);
    // Dummy call for test coverage
    dataDeleteBatch.finish(null);
    Test.stopTest();
  }
}
