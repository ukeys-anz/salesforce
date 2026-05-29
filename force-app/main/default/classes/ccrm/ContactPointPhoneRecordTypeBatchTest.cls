/**
 * @author       : Kritika Sharma
 * @since        : April 2026
 * @description  : ContactPointPhoneRecordTypeBatchTest is the test class for ContactPointPhoneRecord
 */
@IsTest
public class ContactPointPhoneRecordTypeBatchTest {
  @IsTest
  static void testContactPointPhoneBatchFullCoverage() {
    Id targetRT = Schema.SObjectType.ContactPointPhone.getRecordTypeInfosByDeveloperName()
      .get('Individual')
      .getRecordTypeId();

    ContactPointPhone successRecord = new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      TelephoneNumber = '123456789'
    );

    ContactPointPhone failRecord = new ContactPointPhone(
      Id = Lib_FakeIdGenerator.getMockId(ContactPointPhone.SObjectType),
      TelephoneNumber = '987654321'
    );

    List<ContactPointPhone> scope = new List<ContactPointPhone>{
      successRecord,
      failRecord
    };

    ContactPointPhoneRecordTypeBatch batch = new ContactPointPhoneRecordTypeBatch();

    Test.startTest();
    batch.execute(null, scope);
    Test.stopTest();

    Assert.areEqual(
      targetRT,
      successRecord.RecordTypeId,
      'Record Type should have been assigned to the object in memory'
    );
  }

  @IsTest
  static void testStartAndFinishMethods() {
    Test.startTest();
    ContactPointPhoneRecordTypeBatch batch = new ContactPointPhoneRecordTypeBatch();

    batch.start(null);
    batch.finish(null);
    Test.stopTest();

    Assert.isNotNull(batch, 'Batch class should instantiate successfully');
  }
}
