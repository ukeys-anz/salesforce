/**
 * @author Ankit Garg
 * @since 31 July 2023
 * @description test class for MLCRMContactPointPhoneActions
 * @group MLCRM
 */
@isTest
public with sharing class MLCRMContactPointPhoneActionsTest {
  @testSetup
  static void setup() {
    User ocvIntegrationUser = CCRMTestDataFactory.createOCVIntegrationUser();
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();
    System.runAs(ocvIntegrationUser) {
      //GIVEN
      Faker faker = new Faker('AU');
      List<Account> accList = new List<Account>();
      accList.add(TestDataFactory.createAccount('firstName', false));
      insert accList;
    }
    System.runAs(mlUser) {
      Account acc = MLCRMTestDataFactory.createAccountRecords(1, null, true)[0];
    }
    System.runAs(ocvIntegrationUser) {
      Account acc = [SELECT id FROM account WHERE LastName = 'surname' LIMIT 1];
      ContactPointPhone testContactPointPhone = MLCRMTestDataFactory.getContactPointPhoneRecords(
        1,
        '+61212345688',
        acc.Id,
        'Home'
      )[0];
      insert testContactPointPhone;
    }

  }
  @isTest
  static void testUpdateContactPointPhoneMobile() {
    System.runAs(CCRMTestDataFactory.getOCVIntegrationUser()) {
      //GIVEN
      Account acc = [SELECT id FROM account WHERE name = 'firstName' LIMIT 1];
      ContactPointPhone testContactPointPhone = MLCRMTestDataFactory.getContactPointPhoneRecords(
        1,
        '+61512345678',
        acc.Id,
        MLCRMConstants.PHONETYPE_MOBILE
      )[0];
      insert testContactPointPhone;

      //WHEN
      testContactPointPhone.ActiveToDate = System.today() - 1;
      update testContactPointPhone;

      //THEN
      ContactPointPhone cpp = [
        SELECT ParentId, Previous_Related_Account__c
        FROM ContactPointPhone
        WHERE Previous_Related_Account__c != NULL
        LIMIT 1
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
  static void unlinkProspectParentOnDeactivationTest() {
    System.runAs(CCRMTestDataFactory.getOCVIntegrationUser()) {
      //GIVEN
      Account acc = [SELECT id FROM account WHERE LastName = 'surname' LIMIT 1];
      ContactPointPhone testContactPointPhone = MLCRMTestDataFactory.getContactPointPhoneRecords(
        1,
        '+61212345678',
        acc.Id,
        'Home'
      )[0];
      insert testContactPointPhone;

      //WHEN
      testContactPointPhone.ActiveToDate = System.today() - 1;
      update testContactPointPhone;

      //THEN
      ContactPointPhone cpp = [
        SELECT ParentId, Previous_Related_Account__c
        FROM ContactPointPhone
        WHERE Previous_Related_Account__c != NULL
        LIMIT 1
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
      Account acc = [SELECT id FROM account WHERE LastName = 'surname' LIMIT 1];
      String expMsg = System.Label.MLCRM_ExistingContactPointPhoneError;
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone3 = MLCRMTestDataFactory.getContactPointPhoneRecords(
          1,
          '+61212345688',
          acc.Id,
          'Home'
        )[0];
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
  static void validatePhonesTestPatternHomePhoneError() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      //GIVEN
      Account accRecord = MLCRMTestDataFactory.createAccountRecords(
        1,
        null,
        false
      )[0];
      accRecord.OCV_ID__c = 'OCV12123';
      insert accRecord;
      String expMsg = 'Please enter Phone Number in +61212345678 format.';
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone2 = MLCRMTestDataFactory.getContactPointPhoneRecords(
          1,
          '+6112345678',
          accRecord.Id,
          'Home'
        )[0];
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
  static void validatePhonesTestPatternMobileError() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      //GIVEN
      Account accRecord = MLCRMTestDataFactory.createAccountRecords(
        1,
        null,
        false
      )[0];
      accRecord.OCV_ID__c = 'OCV12321';
      insert accRecord;
      String expMsg = 'Please enter Mobile Number in +61412345678/+61512345678 format.';
      String actualMsg = '';
      Test.startTest();
      try {
        ContactPointPhone testContactPointPhone2 = new ContactPointPhone();
        testContactPointPhone2.TelephoneNumber = '+6112345678';
        testContactPointPhone2.ParentId = accRecord.Id;
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
