/**
 * @author Emma Bindi
 * @date November 2022
 * @description Test class for {@link ContentDownloadHandlerFactoryImpl}
 */
@isTest
public with sharing class ContentDownloadHandlerFactoryImplTest {
  @TestSetup
  static void setup() {
    // Add Logging Setting as ANZx Standard User
    Profile anzxUserProfile = CommonUtil.getProfileByName('ANZx Standard User');

    User anzxUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'ANZx_User_Test',
        'ProfileId' => anzxUserProfile.Id
      }
    );
    insert anzxUser;

    System.runAs(anzxUser) {
      LoggingSettings__c userCustomSetting = new LoggingSettings__c(
        DefaultSaveMethod__c = 'QUEUEABLE',
        DefaultLoggingLevel__c = 'DEBUG',
        SecureLogEnabled__c = true,
        SetupOwnerId = anzxUser.Id
      );
      insert userCustomSetting;
    }

    Faker faker = new Faker('AU');
    Account acc = new Account(
      Name = 'TestAccount',
      Display_Name__c = 'TestAccount',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      External_Id__c = faker.randomString(10)
    );
    insert acc;
  }

  @isTest
  static void testCFaaSFileDownloadLogging() {
    // GIVEN a ContentVersion of CFaaS File record type is inserted
    Faker faker = new Faker('AU');

    Account acc = [
      SELECT OCV_ID__c
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

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

    Id cfaasFileRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
      .get('CFaaS File')
      .getRecordTypeId();

    ContentVersion cv = new ContentVersion();
    cv.VersionData = Blob.valueOf('Test Content');
    cv.Title = file.Document_Id__c + ' - ' + file.Security_Classification__c;
    cv.PathOnClient = file.Document_Id__c + '.' + file.File_Extension__c;
    cv.RecordTypeId = cfaasFileRecordTypeId;
    cv.FirstPublishLocationId = file.Id;

    Database.SaveResult saveResult = Database.insert(cv, false);

    List<Id> idList = new List<Id>{ cv.Id };

    User anzxUser = [
      SELECT Id, FirstName
      FROM User
      WHERE FirstName = 'ANZx_User_Test'
      LIMIT 1
    ];

    // WHEN the file is accessed in the UI
    Test.startTest();
    System.runAs(anzxUser) {
      ContentDownloadHandlerFactoryImpl downloadHandlerFactory = new ContentDownloadHandlerFactoryImpl();

      Sfc.ContentDownloadHandler handler = downloadHandlerFactory.getContentDownloadHandler(
        idList,
        Sfc.ContentDownloadContext.S1
      );
      System.assertEquals(
        true,
        handler.isDownloadAllowed,
        'Download should be allowed'
      );
    }
    Test.stopTest();

    List<LogEntry__c> logEntryList = [
      SELECT
        LogMessage__c,
        Origin__c,
        RecordObjectName__c,
        RecordId__c,
        LoggingLevel__c
      FROM LogEntry__c
      LIMIT 1
    ];

    // THEN a log entry recording the download activity should exist
    System.assertNotEquals(0, logEntryList.size(), 'Log entry should exist');
  }

  @isTest
  static void testDefaultFileDownload() {
    // GIVEN a ContentVersion which is NOT a CFaaS File record type is inserted
    Account acc = [
      SELECT OCV_ID__c
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    Id defaultFileRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
      .get('File')
      .getRecordTypeId();

    ContentVersion cv = new ContentVersion();
    cv.VersionData = Blob.valueOf('Test Content');
    cv.Title = 'Test Default File Type';
    cv.PathOnClient = 'TestFile.jpeg';
    cv.RecordTypeId = defaultFileRecordTypeId;
    cv.FirstPublishLocationId = acc.Id;

    Database.SaveResult saveResult = Database.insert(cv, false);

    List<Id> idList = new List<Id>{ cv.Id };

    User anzxUser = [
      SELECT Id, FirstName
      FROM User
      WHERE FirstName = 'ANZx_User_Test'
      LIMIT 1
    ];

    // WHEN the file is accessed in the UI
    Test.startTest();
    System.runAs(anzxUser) {
      ContentDownloadHandlerFactoryImpl downloadHandlerFactory = new ContentDownloadHandlerFactoryImpl();
      Sfc.ContentDownloadHandler handler = downloadHandlerFactory.getContentDownloadHandler(
        idList,
        Sfc.ContentDownloadContext.S1
      );
      System.assertEquals(
        true,
        handler.isDownloadAllowed,
        'Download should be allowed'
      );
    }
    Test.stopTest();

    List<LogEntry__c> logEntryList = [
      SELECT
        LogMessage__c,
        Origin__c,
        RecordObjectName__c,
        RecordId__c,
        LoggingLevel__c
      FROM LogEntry__c
      LIMIT 1
    ];

    // THEN there should not be any log entry recording the download activity
    System.assertEquals(0, logEntryList.size(), 'Log entry should not exist');
  }
}
