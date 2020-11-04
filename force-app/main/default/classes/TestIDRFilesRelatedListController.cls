@isTest
public class TestIDRFilesRelatedListController {
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
    @isTest
    static void getCaseRelatedFilesTest(){
      case c = new case();
      c = [select id from case limit 1];   
      IDRFilesRelatedListController.getCaseRelatedFiles(c.id);
    }
    
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
        IDRFilesRelatedListController.searchFilesContent(testSearchList,docIdList);
    }
}