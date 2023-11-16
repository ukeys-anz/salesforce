/**
 * @author Farid Masjedi
 * @since Nov 2023
 * @description test for VerifiedContactDetails
 */
@IsTest
public with sharing class VerifiedContactDetailsTest {
  private final static Faker TESTFAKER = new Faker('AU');

  @TestSetup
  static void setup() {
    Account testAccount = new Account(
      Name = 'VerifiedContactDetails Account',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = true
    );
    insert testAccount;
  }

  @IsTest
  static void verifiedContactDetails() {
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'VerifiedContactDetails Account'
      LIMIT 1
    ];

    Test.startTest();
    List<ContactPointPhone> cPhones = new List<ContactPointPhone>();
    List<ContactPointEmail> cEmails = new List<ContactPointEmail>();

    for (Integer i = 0; i < 3; i++) {
      ContactPointEmail e = new ContactPointEmail(
        UsageType = 'Security Email',
        ParentId = acc.Id,
        Verification_Status__c = true,
        Verification_Date__c = Date.today(),
        EmailAddress = 'VerifiedContactDetailsTest' + i + '@email.com'
      );
      ContactPointPhone p = new ContactPointPhone(
        UsageType = 'Security Mobile',
        ParentId = acc.Id,
        Verification_Status__c = true,
        Verification_Date__c = Date.today(),
        TelephoneNumber = TESTFAKER.person.phone()
      );
      cPhones.add(p);
      cEmails.add(e);
    }
    insert cPhones;
    insert cEmails;

    List<sObject> contactDetails = VerifiedContactDetails.customerContactDetails(
      acc.Id,
      'Security Mobile',
      'Security Email'
    );
    System.assertEquals(
      contactDetails.size(),
      6,
      'All records should be added to the contact details list'
    );
    Test.stopTest();
  }

  @IsTest
  static void filterContactDetails() {
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'VerifiedContactDetails Account'
      LIMIT 1
    ];

    Test.startTest();
    List<ContactPointPhone> cPhones = new List<ContactPointPhone>();
    List<ContactPointEmail> cEmails = new List<ContactPointEmail>();

    for (Integer i = 0; i < 3; i++) {
      ContactPointEmail e = new ContactPointEmail(
        UsageType = i == 2 ? 'Security Email' : 'Fax',
        ParentId = acc.Id,
        Verification_Status__c = true,
        Verification_Date__c = Date.today(),
        EmailAddress = 'VerifiedContactDetailsTest' + i + '@email.com'
      );
      ContactPointPhone p = new ContactPointPhone(
        UsageType = i == 2 ? 'Security Mobile' : 'Business Phone',
        ParentId = acc.Id,
        Verification_Status__c = true,
        Verification_Date__c = Date.today(),
        TelephoneNumber = TESTFAKER.person.phone()
      );
      cPhones.add(p);
      cEmails.add(e);
    }

    insert cPhones;
    insert cEmails;

    List<sObject> contactDetails = VerifiedContactDetails.customerContactDetails(
      acc.Id,
      'Security Mobile',
      'Security Email'
    );
    System.assertEquals(
      contactDetails.size(),
      2,
      'Records should be filtered by UsageType'
    );
    Test.stopTest();
  }
}
