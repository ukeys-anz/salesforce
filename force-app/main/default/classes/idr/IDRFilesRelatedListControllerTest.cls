/**
 * @author Himabindu Nekkanti
 * @since  11/2020
 * @description TestIDRFilesRelatedListController is the test class for  IDRFilesRelatedListController.
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
public class IDRFilesRelatedListControllerTest {
  /**
   * @description setupData sets up the test data required for the test class.
   */
  @testSetup
  static void setupData() {
    case c = new case(
      subject = 'test subject',
      RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    );
    insert c;
    contentversion cv = new contentversion();
    cv.Title = 'loan.txt';
    cv.PathOnClient = 'loan.txt';
    cv.VersionData = blob.valueOf('Test file Search - idrsearch123');
    cv.Document_Flag__c = '1;7';
    cv.Date_of_Document__c = datetime.now();
    cv.Party_who_sent_created_file__c = 'Internal business unit';
    cv.Document_Category__c = 'Internal Correspondence';
    cv.FirstPublishLocationId = c.id;
    cv.RecordTypeId = IDRConstants.COMPLAINT_FILE_RT_ID;
    insert cv;
  }
  /**
   * @description getCaseRelatedFilesTest covers the functionality of getCaseRelatedFiles method
   */
  @isTest
  static void getCaseRelatedFilesTest() {
    case c = new case();
    c = [SELECT id FROM case LIMIT 1];
    list<IDRFilesRelatedListdata> dataList = new List<IDRFilesRelatedListdata>();
    dataList = IDRFilesRelatedListController.getCaseRelatedFiles(c.id);
    system.assertEquals(1, datalist.size());
  }
  /**
   * @description searchFileContentTest covers the functionality of searchFileContent method
   */
  @isTest
  static void searchFileContentTest() {
    list<string> testSearchList = new List<string>();
    testSearchList.add('Test');

    contentversion cv = new contentversion();
    cv = [SELECT contentdocumentId FROM contentversion LIMIT 1];
    list<id> docIdList = new List<id>();
    docIdlist.add(cv.ContentDocumentId);

    list<string> retlist1 = new List<string>();
    retlist1 = IDRFilesRelatedListController.searchFilesContent(
      testSearchList,
      docIdList
    );

    list<string> retlist2 = new List<string>();
    testSearchList.add('idrsearch123');
    retlist2 = IDRFilesRelatedListController.searchFilesContent(
      testSearchList,
      docIdList
    );
    //salesforce test class limitation- sosl will always return zero items when executed from test class
    //https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
    system.assertEquals(0, retlist1.size());
    system.assertEquals(0, retlist2.size());
  }
}
