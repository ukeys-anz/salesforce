/**
 * @author Emma Bindi
 * @since November 2022
 * @description Test class for {@link CFaaSController}
 */
@isTest
public with sharing class CFaaSControllerTest {
  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );
    insert acc;

    CFaaS_File__c file = new CFaaS_File__c(
      Document_Id__c = faker.randomString(35),
      File_Description__c = faker.randomString(5) +
        ' ' +
        faker.randomString(7) +
        ' ' +
        faker.randomString(8),
      File_Extension__c = '.jpeg',
      File_Name__c = faker.randomString(7) + ' ' + faker.randomString(6),
      Date_Created__c = faker.randomPastDateTime(),
      Customer__c = acc.Id,
      Privacy_Classification__c = 'Medium',
      Security_Classification__c = 'PROTECTED',
      Integrity_Classification__c = 'Confidential'
    );

    insert file;
  }

  @isTest
  static void testGetCFaaSDocument() {
    Account acc = [
      SELECT OCV_ID__c
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    CFaaS_File__c file = [
      SELECT Document_Id__c, File_Extension__c, Security_Classification__c
      FROM CFaaS_File__c
      WHERE Customer__c = :acc.Id
      LIMIT 1
    ];

    Id cfaasFileRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
      .get('CFaaS File')
      .getRecordTypeId();
    ContentVersion cv = new ContentVersion();
    cv.Document_Flag__c = '4';
    cv.FirstPublishLocationId = file.Id;
    cv.UUID__c = file.Document_Id__c + '-' + UserInfo.getUserId();
    cv.title = 'test';
    cv.PathOnClient = 'test';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.RecordTypeId = cfaasFileRecordTypeId;
    insert cv;

    Test.startTest();

    CFaaSController.CFassFileResult result = CFaaSController.getCFaaSDocument(
      acc.OCV_ID__c,
      file.Document_Id__c,
      file.Id,
      file.Security_Classification__c
    );

    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Content Document Id should be returned to LWC'
    );
  }
}
