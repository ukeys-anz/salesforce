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

    //Create NonCFaaS file
    List<ContentVersion> cvList = new List<ContentVersion>();

    ContentVersion cv1 = new ContentVersion();
    cv1.Title = 'Test File Delete NonCFaaS';
    cv1.PathOnClient = 'Test File Delete NonCFaaS' + '.txt';
    cv1.VersionData = Blob.valueOf('Test File Delete functionality');
    cv1.RecordTypeId = IDRConstants.COMPLAINT_FILE_RT_ID;
    cvList.add(cv1);

    //Create CFaaS file
    ContentVersion cv2 = new ContentVersion();
    cv2.Title = 'Test File Delete CFaaS';
    cv2.PathOnClient = 'Test File Delete CFaaS' + '.txt';
    cv2.VersionData = Blob.valueOf('Test File Delete functionality');
    cv2.RecordTypeId = IDRConstants.CFAAS_FILE_RT_ID;
    cvList.add(cv2);

    insert cvList;

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
   * @description Test the file delete restriction for non-CFaaS
   */
  @isTest
  static void testFileDeleteNonCFaaS() {
    List<ContentDocument> cdList = [
      SELECT id
      FROM ContentDocument
      WHERE
        Id NOT IN (
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE RecordTypeID = :IDRConstants.CFAAS_FILE_RT_ID
        )
      LIMIT 1
    ];

    ContentDocumentTriggerHandler.restrictFileDeleteAction(cdList);

    List<Database.Error> errors = cdList[0].getErrors();

    System.assert(
      errors[0].getMessage().contains(IDRConstants.RESTRICTED_ACTION_MESSAGE),
      'Exception should contain the' + IDRConstants.RESTRICTED_ACTION_MESSAGE
    );
  }

  /**
   * @description Test the file delete restriction for CFaaS
   */
  @isTest
  static void testFileDeleteCFaaS() {
    List<ContentDocument> cdList = [
      SELECT id
      FROM ContentDocument
      WHERE
        Id IN (
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE RecordTypeID = :IDRConstants.CFAAS_FILE_RT_ID
        )
      LIMIT 1
    ];

    ContentDocumentTriggerHandler.restrictFileDeleteAction(cdList);

    System.assert(!cdList[0].hasErrors(), 'No exception error should occur.');
  }
}
