/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To test ContentDocumentTriggerHandler
 */
@isTest
public class TestContentDocumentTriggerHandler {
  /**
   * @description Test data setup required for this test class
   */
  @testSetup
  static void setup() {
    //Create Case
    Case testCase = new Case();

    testCase.IDR_Account_Card_Policy_Number__c = '000001234';
    testCase.Description = 'Test decription';
    testCase.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    testCase.IDR_Customer_Number__c = '1234567890';
    testCase.Status = IDRConstants.OPEN_STATUS;

    insert testCase;

    //Create a file
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test File Delete';
    cv.PathOnClient = 'Test File Delete' + '.txt';
    cv.VersionData = Blob.valueOf('Test File Delete functionality');
    cv.RecordTypeId = IDRConstants.COMPLAINT_FILE_RT_ID;

    insert cv;

    // retrieve file to create an association with case
    ContentDocument cd = [SELECT id FROM ContentDocument LIMIT 1];

    // insert Content document link
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = cd.Id;
    cdl.LinkedEntityId = testCase.Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;
  }

  /**
   * @description Test the file delete functionality
   */
  @isTest
  static void testFileDelete() {
    ContentDocument cd = [SELECT id FROM ContentDocument LIMIT 1];
    try {
      delete cd;
    } catch (Exception e) {
      System.assertEquals(
        e.getMessage().contains(IDRConstants.RESTRICTED_ACTION_MESSAGE),
        true,
        'Error message should be as expected.'
      );
    }
  }
}
