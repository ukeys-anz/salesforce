/**
 * @author Greg Shaw (shawg2)
 * @since 06/2022
 * @description Test ContentDocumentBatch
 */

@IsTest
private class ContentDocumentBatchTest {
  @IsTest
  public static void testExecuteBatchJob() {
    Case oTestCase;
    List<Case> lstCases = new List<Case>();
    for (Integer i = 0; i < 10; i++) {
      lstCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = (Math.mod(i, 2) == 0
            ? IDRConstants.CLOSED_STATUS
            : IDRConstants.OPEN_STATUS),
          isEscalated = false
        )
      );
    }
    insert lstCases;
    for (Case oCase : lstCases) {
      if (oCase.Status == IDRConstants.CLOSED_STATUS) {
        oTestCase = oCase;
      }
    }
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test File Delete';
    cv.PathOnClient = 'Test File Delete' + '.txt';
    cv.VersionData = Blob.valueOf('Test File Delete functionality');

    insert cv;

    // retrieve file to create an association with case
    ContentDocument cd = [SELECT id FROM ContentDocument LIMIT 1];

    // insert Content document link
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = cd.Id;
    cdl.LinkedEntityId = oTestCase.Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;

    Test.startTest();
    ContentDocumentBatch batch = new ContentDocumentBatch();
    Id batchId = Database.executeBatch(batch);
    Test.stopTest();

    System.assertNotEquals(
      null,
      batchId,
      'Should have a batch Id for AuthSessionRemoverBatch job.'
    );
  }
}
