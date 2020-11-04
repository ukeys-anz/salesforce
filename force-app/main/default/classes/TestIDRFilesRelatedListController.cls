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
        case c = new case(subject='test subject');
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
    static void getCaseRelatedFilesTest(){
      case c = new case();
      c = [select id from case limit 1];   
      IDRFilesRelatedListController.getCaseRelatedFiles(c.id);
    }
    /**
   * @description searchFileContentTest covers the functionality of searchFileContent method
   */
    @isTest
    static void searchFileContentTest(){
        list<string> testSearchList = new list<string>();
        testSearchList.add('Test');
        
        contentversion cv = new contentversion();
      	cv = [select contentdocumentId from contentversion limit 1]; 
       	list<id> docIdList = new list<id>();
        docIdlist.add(cv.ContentDocumentId);
        
      	IDRFilesRelatedListController.searchFilesContent(testSearchList,docIdList);
        
        testSearchList.add('idrsearch123');
        IDRFiles
        RelatedListController.searchFilesContent(testSearchList,docIdList);
    }
}