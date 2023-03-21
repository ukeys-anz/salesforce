/**
 * @author Emma Bindi
 * @since November 2022
 * @description Test class for CFaaSAPIRepository
 */
@isTest
public with sharing class CFaaSAPIRepositoryTest {
  @isTest
  static void testGetDownloadUrl() {
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

    Test.startTest();
    CFaaSAPIRepository cfaasAPI = new CFaaSAPIRepository();
    CFaaSDocumentModel.CFaaSDownloadUrl response = cfaasAPI.getDownloadURL(
      acc.OCV_Id__c,
      file.Document_Id__c
    );

    Test.stopTest();

    System.assertNotEquals(null, response.url, 'URL value was expected');
    System.assertNotEquals(null, response.otp, 'OTP value was expected');
    System.assertNotEquals(
      null,
      response.contentType,
      'Content type value was expected'
    );
  }

  @isTest
  static void testGetDocumentContent() {
    Faker faker = new Faker('AU');
    String url = faker.randomString(50);
    String otp = faker.randomString(40);
    String contentType = 'image/jpeg';

    Test.startTest();
    CFaaSAPIRepository cfaasAPI = new CFaaSAPIRepository();
    Blob response = cfaasAPI.fetchDocumentContent(url, otp, contentType);
    Test.stopTest();

    System.assertNotEquals(null, response, 'Response should not be null');
  }
}
