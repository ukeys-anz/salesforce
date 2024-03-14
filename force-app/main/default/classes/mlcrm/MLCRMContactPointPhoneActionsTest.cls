/**
 * @author Ankit Garg
 * @since 31 July 2023
 * @description test class for MLCRMContactPointPhoneActions
 * @group MLCRM
 */
@isTest
public with sharing class MLCRMContactPointPhoneActionsTest {
  @isTest
  static void testUpdateContactPointPhoneMobile() {
    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = TestDataFactory.createAccount(
        faker.person.firstName(),
        true
      );
      ContactPointPhone testContactPointPhone = new ContactPointPhone();
      testContactPointPhone.TelephoneNumber = '+61512345678';
      testContactPointPhone.ParentId = acc.Id;
      testContactPointPhone.UsageType = MLCRMConstants.PHONETYPE_MOBILE;
      insert testContactPointPhone;

      //WHEN
      testContactPointPhone.ActiveToDate = System.today() - 1;
      update testContactPointPhone;

      //THEN
      ContactPointPhone cpp = [
        SELECT ParentId, Previous_Related_Account__c
        FROM ContactPointPhone
      ];
      System.assertEquals(null, cpp.ParentId, 'Parent Id set to null');

      System.assertEquals(
        acc.Id,
        cpp.Previous_Related_Account__c,
        'Previous account id should match'
      );
    }
  }
  @isTest
  static void testUnlinkProspectParentOnDeactivation() {
    System.runAs(MLCRMTestDataFactory.getAdminUser()) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = MLCRMTestDataFactory.createAccountRecords(1, null, true)[0];
      ContactPointPhone testContactPointPhone = new ContactPointPhone();
      testContactPointPhone.TelephoneNumber = '+61212345678';
      testContactPointPhone.ParentId = acc.Id;
      testContactPointPhone.UsageType = 'Home';
      insert testContactPointPhone;

      //WHEN
      testContactPointPhone.ActiveToDate = System.today() - 1;
      update testContactPointPhone;

      //THEN
      ContactPointPhone cpp = [
        SELECT ParentId, Previous_Related_Account__c
        FROM ContactPointPhone
      ];
      System.assertEquals(null, cpp.ParentId, 'Parent Id set to null');

      System.assertEquals(
        acc.Id,
        cpp.Previous_Related_Account__c,
        'Previous account id should match'
      );
    }
  }
  @isTest
  static void testUpdateContactPointPhoneExisting() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = MLCRMTestDataFactory.createAccountRecords(1, null, true)[0];
      ContactPointPhone testContactPointPhone = new ContactPointPhone();
      testContactPointPhone.TelephoneNumber = '+61212345678';
      testContactPointPhone.ParentId = acc.Id;
      testContactPointPhone.UsageType = 'Home';
      insert testContactPointPhone;

      String expMsg = System.Label.MLCRM_ExistingContactPointPhoneError;
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone3 = new ContactPointPhone();
        testContactPointPhone3.TelephoneNumber = '+61212345678';
        testContactPointPhone3.ParentId = acc.Id;
        testContactPointPhone3.UsageType = 'Home';
        insert testContactPointPhone3;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Contact Phone inserted successfully'
      );
    }
  }
  @isTest
  static void testUpdateContactPointPhonePatternError() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = MLCRMTestDataFactory.createAccountRecords(1, null, true)[0];

      String expMsg = 'Please enter Phone Number in +61212345678 format.';
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone2 = new ContactPointPhone();
        testContactPointPhone2.TelephoneNumber = '+6112345678';
        testContactPointPhone2.ParentId = acc.Id;
        testContactPointPhone2.UsageType = 'Home';
        insert testContactPointPhone2;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Contact Phone inserted successfully'
      );
    }
  }

  @isTest
  static void testUpdateContactPointPhonePatternMobileError() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      //GIVEN
      Faker faker = new Faker('AU');
      Account acc = MLCRMTestDataFactory.createAccountRecords(1, null, true)[0];
      String expMsg = 'Please enter Mobile Number in +61412345678/+61512345678 format.';
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone2 = new ContactPointPhone();
        testContactPointPhone2.TelephoneNumber = '+6112345678';
        testContactPointPhone2.ParentId = acc.Id;
        testContactPointPhone2.UsageType = MLCRMConstants.PHONETYPE_MOBILE;
        insert testContactPointPhone2;
      } catch (DMLException e) {
        actualMsg = e.getDmlMessage(0);
      }
      Test.stopTest();
      System.assertEquals(
        expMsg,
        actualMsg,
        'Contact Phone inserted successfully'
      );
    }
  }
}
