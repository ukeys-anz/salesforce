@IsTest
class QueryRTTest {
  static RecordTypeInfo personAccRT = SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount');

  @IsTest
  static void testGetRecordTypeByDevName() {
    Assert.areEqual(
      QueryRT.of(Account.SObjectType).get('PersonAccount'),
      personAccRT,
      'Record type does not match'
    );
  }

  @IsTest
  static void testGetRecordTypeIdByDevName() {
    Assert.areEqual(
      QueryRT.of(Account.SObjectType).getId('PersonAccount'),
      personAccRT.RecordTypeId,
      'Record type ID does not match'
    );
  }

  @IsTest
  static void testGetRecordTypeById() {
    Assert.areEqual(
      QueryRT.of(Account.SObjectType).get(personAccRT.RecordTypeId),
      personAccRT,
      'Record type does not match'
    );
  }
}
