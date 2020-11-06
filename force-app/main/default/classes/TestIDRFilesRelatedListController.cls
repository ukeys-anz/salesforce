/**
 * @author Himabindu Nekkanti
 * @since  11/2020
 * @description TestIDRFilesRelatedListController is the test class for  IDRFilesRelatedListController.
 *
 */
@isTest
public class TestIDRFilesRelatedListController {
  /**
   * @description setupData sets up the test data required for the test class.
   */
  @testSetup
  static void setupData() {
    case c = new case(subject = 'test subject');
    insert c;
    contentversion cv = new contentversion();
    cv.Title = 'loan.txt';
    cv.PathOnClient = 'loan.txt';
    cv.VersionData = blob.valueOf('Test file Search - idrsearch123');
    cv.FirstPublishLocationId = c.id;
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
