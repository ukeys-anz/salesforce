@isTest
private with sharing class ContentVersionTriggerHandlerTest {
  @TestSetup
  static void testSetup() {
    ContentVersion[] newFiles = new List<ContentVersion>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newFiles.add(
        new ContentVersion(
          Title = 'Test',
          PathOnClient = '/test.pdf',
          VersionData = Blob.valueOf('Test'),
          Description = 'Test description 1234-5678-9101-7632-3321 check mask',
          RecordTypeId = IDRConstants.COMPLAINT_FILE_RT_ID
        )
      );
    }
    insert newFiles;
  }

  @isTest
  static void testContentVersionFieldMasking() {
    //GIVEN files
    //WHEN they're inserted
    //THEN long numbers in free text fields are masked, showing only the last four digits
    Test.startTest();
    ContentVersion cv = [SELECT Description FROM ContentVersion LIMIT 1];
    System.assertEquals(
      'Test description ****************3321 check mask',
      cv.Description,
      'Description should be masked.'
    );
    //AND WHEN updated
    cv.Description = '1234-5678-9101-7632-3321';
    update cv;
    //THEN long numbers in free text fields are masked, showing only the last four digits
    cv = [SELECT Description FROM ContentVersion LIMIT 1];
    System.assertEquals(
      '****************3321',
      cv.Description,
      'Description should be masked.'
    );
    Test.stopTest();
  }

  @isTest
  static void testUUID() {
    //GIVEN files
    //WHEN they're inserted
    //THEN UUIDs have been generated
    //(Uniqueness and pattern have already been tested in CommonUtilTest)
    Test.startTest();
    ContentVersion cv = [SELECT UUID__c FROM ContentVersion LIMIT 1];
    System.assertEquals(
      false,
      String.isBlank(cv.UUID__c),
      'A UUID should have been generated'
    );
    Test.stopTest();
  }
}
