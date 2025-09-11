/**
 * @author Olivier Saier
 * @since 10/2021
 * @group CCRM (Commercial CRM)
 * @description AbnAcnUtilTest is the test class to cover tests for {@link AbnAcnUtil.cls}
 */
@isTest
private class AbnAcnUtilTest {
  @isTest
  static void validateABNTest() {
    //GIVEN List of Lead Records & lead oldMap
    List<Lead> listLead = new List<Lead>{
      new Lead(Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType))
    };
    Map<Id, Lead> leadOldMap = new Map<Id, Lead>();
    leadOldMap.put(listLead[0].Id, listLead[0]);
    listLead[0].Registered_Company__c = '';
    listLead[0].ABN__c = '11005357522';

    //WHEN calling a validateABN method
    Test.startTest();
    AbnAcnUtil.validateABN(listLead, leadOldMap);
    Test.stopTest();

    //THEN it should return formatted value
    Assert.areEqual(
      '11 005 357 522',
      listLead[0].ABN__c,
      'ABN should be properly formatted'
    );
  }
  @isTest
  static void validateACNTest() {
    //GIVEN List of Lead Records & lead oldMap
    List<Lead> listLead = new List<Lead>{
      new Lead(Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType))
    };
    Map<Id, Lead> leadOldMap = new Map<Id, Lead>();
    leadOldMap.put(listLead[0].Id, listLead[0]);
    listLead[0].Registered_Company__c = '';
    listLead[0].ACN__c = '004085616';

    //WHEN calling a validateABN method
    Test.startTest();
    AbnAcnUtil.validateACN(listLead, leadOldMap);
    Test.stopTest();

    //THEN it should return formatted value
    Assert.areEqual(
      '004 085 616',
      listLead[0].ACN__c,
      'ACN should be properly formatted'
    );
  }
  @isTest
  static void validateAndFormatRecordABNExceptionTest() {
    //GIVEN List of Lead Records & lead oldMap
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Registered_Company__c = '',
      ABN__c = '1100535752233'
    );
    String fieldName = 'ABN__c';

    //WHEN Calling validateAndFormatRecordABN THEN no exceptions should be thrown
    Boolean exceptionThrown = false;
    try {
      Test.startTest();
      AbnAcnUtil.validateAndFormatRecordABN(leadRec, fieldName);
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
      Assert.areEqual(
        false,
        exceptionThrown,
        'No exception should be thrown, but catch block should be covered'
      );
    }
  }
  @isTest
  static void validateAndFormatRecordACNExceptionTest() {
    //GIVEN List of Lead Records & lead oldMap
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Registered_Company__c = '',
      ACN__c = '00408561677'
    );
    String fieldName = 'ACN__c';

    //WHEN Calling validateAndFormatRecordACN THEN no exceptions should be thrown
    Boolean exceptionThrown = false;
    try {
      Test.startTest();
      AbnAcnUtil.validateAndFormatRecordACN(leadRec, fieldName);
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
      Assert.areEqual(
        false,
        exceptionThrown,
        'No exception should be thrown, but catch block should be covered'
      );
    }
  }
  @isTest
  static void validateAndFormatRecordARBNTest() {
    //GIVEN Lead Record and ARBN Field
    Account accRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      ARBN__c = '444555666'
    );
    String fieldName = 'ARBN__c';

    //WHEN calling a validateAndFormatRecordARBN method
    Test.startTest();
    AbnAcnUtil.validateAndFormatRecordARBN(accRec, fieldName);
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.areEqual(
      '444 555 666',
      accRec.ARBN__c,
      'ARBN should be properly formatted'
    );
  }
  @isTest
  static void validateAndFormatRecordARBNExceptionTest() {
    //GIVEN Lead Record and ARBN Field
    Account accRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      ARBN__c = '44455566677'
    );
    String fieldName = 'ARBN__c';

    //WHEN Calling validateAndFormatRecordARBN THEN no exceptions should be thrown
    Boolean exceptionThrown = false;
    try {
      Test.startTest();
      AbnAcnUtil.validateAndFormatRecordARBN(accRec, fieldName);
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
      Assert.areEqual(
        false,
        exceptionThrown,
        'No exception should be thrown, but catch block should be covered'
      );
    }
  }
  @isTest
  static void isABNValueEnteredNegativeTest() {
    //GIVEN new and old Lead records
    Lead newlead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
    );
    Lead oldLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
    );

    //WHEN calling a isABNValueEntered method
    Test.startTest();
    Boolean isAbnValueEntered = AbnAcnUtil.isABNValueEntered(newLead, oldLead);
    Test.stopTest();

    //THEN it shouldn't return value True
    Assert.areEqual(false, isAbnValueEntered, 'Method should not return True');
  }
  @isTest
  static void isACNValueEnteredNegativeTest() {
    //GIVEN new and old Lead records
    Lead newlead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
    );
    Lead oldLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
    );

    //WHEN calling a isACNValueEntered method
    Test.startTest();
    Boolean isAcnValueEntered = AbnAcnUtil.isACNValueEntered(newLead, oldLead);
    Test.stopTest();

    //THEN it shouldn't return value True
    Assert.areEqual(false, isAcnValueEntered, 'Method should not return True');
  }
}
