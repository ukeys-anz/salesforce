/**
 * @author Karen Valeriano
 * @since November 2022
 * @description test class for CFaasFilesCleanup class
 */
@isTest
public with sharing class CFaasFilesCleanupTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    //Add five CFaaS_Files records linked to test Account and ResidentialLoanApplication
    List<CFaaS_File__c> cfaasFileList = new List<CFaaS_File__c>();
    List<String> fileExtList = new List<String>{
      '.pdf',
      '.docx',
      '.jpeg',
      '.png'
    };

    for (Integer i = 0; i < 5; i++) {
      cfaasFileList.add(
        new CFaaS_File__c(
          Document_Id__c = faker.randomString(10),
          File_Description__c = faker.randomString(5) +
            ' ' +
            faker.randomString(7) +
            ' ' +
            faker.randomString(8),
          File_Extension__c = fileExtList[faker.randomIntegerBetween(0, 3)],
          File_Name__c = faker.randomString(7) + ' ' + faker.randomString(6),
          Date_Created__c = faker.randomPastDateTime(),
          Privacy_Classification__c = 'Medium',
          Security_Classification__c = 'PROTECTED',
          Integrity_Classification__c = 'Confidential'
        )
      );
    }

    insert cfaasFileList;

    //Add ContentVersion for the test CFaaS_file records. Five records will be added.
    List<ContentVersion> cvList = new List<ContentVersion>();
    Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
      .get('CFaaS File')
      .getRecordTypeId();
    String base64Data;

    for (CFaaS_File__c file : cfaasFileList) {
      base64Data = EncodingUtil.urlDecode(file.File_Name__c, 'UTF-8');

      cvList.add(
        new ContentVersion(
          VersionData = EncodingUtil.base64Decode(base64Data),
          Title = file.File_Name__c,
          PathOnClient = file.File_Name__c,
          RecordTypeID = recordTypeId,
          FirstPublishLocationId = file.Id
        )
      );
    }

    insert cvList;
  }

  /**
   * @description Test Cleanup class based from elapsed Date and hours/minutes
   */
  @isTest
  static void testCleanupByElapsedDate() {
    Datetime now = Datetime.now();

    // GIVEN that files are created a second ago
    List<ContentVersion> listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE
        FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
        AND CreatedDate < :now
    ];

    // WHEN the cleanup is processed to delete files created today a second ago
    Test.startTest();
    Datetime dt = now.addSeconds(-1);
    CFaasFilesCleanup.processCleanup(dt);
    Test.stopTest();

    listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE
        FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
        AND CreatedDate < :now
    ];

    // THEN the files will be deleted
    System.assertEquals(
      0,
      listContentVersion.size(),
      'Elapsed files should be deleted.'
    );
  }

  /**
   * @description Test Cleanup elapsed time calculation
   */
  @isTest
  static void testElapsedTimeCalculation() {
    // GIVEN that files are created a second ago
    List<ContentVersion> listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
    ];

    // WHEN the elapsed time is set to 2 hours and 30 minutes
    Test.startTest();
    Integer hours = 2;
    Integer minutes = 30;

    CFaasFilesCleanup.processCleanup(hours, minutes); //will set the elapsedDatetime to 2.5 hours ago today

    Test.stopTest();

    //Query the records again
    listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
    ];

    // THEN No files will be deleted because no files were created 2.5 hours ago
    System.assertEquals(
      5,
      listContentVersion.size(),
      'No files should be deleted.'
    );
  }

  /**
   * @description Test Cleanup class with no elapsed files yet
   */
  @isTest
  static void testCleanupWithNoElapsedFiles() {
    Datetime now = Datetime.now();

    // GIVEN that files are created
    List<ContentVersion> listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
    ];

    // WHEN the cleanup is processed to delete files older than today's date
    Test.startTest();
    Datetime dt = now.addDays(-10);
    CFaasFilesCleanup.processCleanup(dt);
    Test.stopTest();

    listContentVersion = [
      SELECT Id, Title, CreatedDate
      FROM ContentVersion
      WHERE FirstPublishLocationId IN (SELECT Id FROM CFaaS_File__c)
    ];

    // THEN no files will be deleted
    System.assertEquals(
      listContentVersion.size(),
      5,
      'No files should be deleted.'
    );
  }
}
