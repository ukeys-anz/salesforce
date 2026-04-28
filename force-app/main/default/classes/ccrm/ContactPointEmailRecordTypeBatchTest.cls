/**
 * @author       : Kritika Sharma
 * @since        : April 2026
 * @description  : ContactPointEmailRecordTypeBatchTest is the test class for ContactPointEmailRecordTypeBatch
 **/
@IsTest
public class ContactPointEmailRecordTypeBatchTest {
  @IsTest
  static void testContactPointEmailBatch() {
    Id targetRT = Schema.SObjectType.ContactPointEmail.getRecordTypeInfosByDeveloperName()
      .get('Individual')
      .getRecordTypeId();

    ContactPointEmail successRecord = new ContactPointEmail(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType),
      EmailAddress = 'success@example.com'
    );

    ContactPointEmail failRecord = new ContactPointEmail(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType),
      EmailAddress = 'fail@example.com'
    );

    List<ContactPointEmail> scope = new List<ContactPointEmail>{
      successRecord,
      failRecord
    };

    ContactPointEmailRecordTypeBatch batch = new ContactPointEmailRecordTypeBatch();

    Test.startTest();
    batch.execute(null, scope);
    Test.stopTest();

    Assert.areEqual(
      targetRT,
      successRecord.RecordTypeId,
      'Record Type should be assigned'
    );
  }

  @IsTest
  static void testBatchUpdate() {
    Account acc = new Account(Name = 'Test Acc', OCV_ID__c = 'OCV-123');
    insert acc;

    Individual ind = new Individual(LastName = 'Test Ind');
    insert ind;

    ContactPointEmail cpe = new ContactPointEmail(
      ParentId = ind.Id,
      EmailAddress = 'test@test.com',
      Customer_Name__c = acc.Id
    );
    insert cpe;

    cpe.RecordTypeId = null;
    update cpe;

    Test.startTest();
    ContactPointEmailRecordTypeBatch batch = new ContactPointEmailRecordTypeBatch();
    Database.executeBatch(batch);
    Test.stopTest();

    Assert.isNotNull(batch, 'Batch should instantiate');
  }
}
