/**
 * @description       : Test Class for FilesCleanupTest
 * @author            : Anuj Jain - JOIN Squad
 * @group             :
 * @last modified on  : 07-29-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
@IsTest
public with sharing class DAONFilesCleanupTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider daonFilesQueryMock;
  static Lib_MockProvider daonFilesdmlRepoMock;

  static void registerMocks() {
    daonFilesQueryMock = Lib_MockProvider.forType(IDOpsQueryRepository.class);
    daonFilesdmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static List<Id> contentVersionIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ContentVersion.SObjectType)
  };
  static List<Id> contentDocumentIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ContentDocument.SObjectType)
  };

  static List<ContentVersion> contentVersionRecords {
    get {
      if (contentVersionRecords != null) {        
        return contentVersionRecords;
    }
      List<ContentVersion> cvList = new List<ContentVersion>();

      String recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
        .get('DAON_File')
        .getRecordTypeId();
      for (Integer i = 0; i < 10; i++) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document' + i;
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.RecordTypeId = recordTypeId;
        cv.ContentDocumentId = contentDocumentIds[0];
        cvList.add(cv);
      }
      return cvList;
    }
  }

  static List<ContentDocument> contentDocumentRecords {
    get {
      if (contentDocumentRecords != null) {        
        return contentDocumentRecords;
    }
      List<ContentDocument> contentDocumentList = new List<ContentDocument>();
      ContentDocument contentDocObj = new ContentDocument();
      contentDocObj.Id = contentDocumentIds[0];
      contentDocumentList.add(contentDocObj);
      return contentDocumentList;
    }
  }

  static List<ContentDocumentLink> contentDocumentLinkRecords {
    get {
      if (contentDocumentLinkRecords != null) {        
        return contentDocumentLinkRecords;
    }
      List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.ContentDocumentId = contentDocumentIds[0];
      cdl.ShareType = 'V';
      cdl.Visibility = 'AllUsers';
      contentDocumentLinkList.add(cdl);
      return contentDocumentLinkList;
    }
  }

  static void dmlDeleteRepoMocksTrue() {
    daonFilesdmlRepoMock.mock(
      'deleteRecords',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult('{"success":true}')
      }
    );
  }

  @isTest
  static void testCleanupByElapsedDate() {
    registerMocks();
    daonFilesQueryMock.mock('checkCustomPermission', true);
    dmlDeleteRepoMocksTrue();
    Datetime dateTimeObj = Datetime.now();
    daonFilesQueryMock.mock(
      'getContentDocumentsRecord',
      contentDocumentRecords
    );
    Test.startTest();
    DAONFilesCleanup.processCleanup(dateTimeObj);
    Test.stopTest();
    List<ContentDocument> cdList = (List<ContentDocument>) daonFilesdmlRepoMock.getHistory(
        'deleteRecords'
      )
      .getParam('records');
    Assert.areEqual(1, cdList.size(), '1 content document should be deleted');
  }

  @isTest
  static void testElapsedTimeCalculation() {
    registerMocks();
    daonFilesQueryMock.mock('checkCustomPermission', true);
    dmlDeleteRepoMocksTrue();
    Datetime dateTimeObj = Datetime.now();
    Integer hours = 2;
    Integer minutes = 30;
    daonFilesQueryMock.mock(
      'getContentDocumentsRecord',
      contentDocumentRecords
    );
    List<ContentVersion> listContentVersion = contentVersionRecords;
    Test.startTest();
    DAONFilesCleanup.processCleanup(hours, minutes);
    Test.stopTest();
    List<ContentDocument> cdList = (List<ContentDocument>) daonFilesdmlRepoMock.getHistory(
        'deleteRecords'
      )
      .getParam('records');
    Assert.areEqual(1, cdList.size(), '1 content document should be deleted');
  }

  @isTest
  static void testCleanupWithNoElapsedFiles() {
    Datetime dateTimeObj = Datetime.now();
    Datetime dt = dateTimeObj.addDays(-10);

    registerMocks();
    daonFilesQueryMock.mock('checkCustomPermission', true);
    dmlDeleteRepoMocksTrue();
    daonFilesQueryMock.mock(
      'getContentDocumentsRecord',
      new List<ContentDocument>()
    );
    List<ContentVersion> listContentVersion = contentVersionRecords;
    Test.startTest();
    DAONFilesCleanup.processCleanup(dt);
    Test.stopTest();
    List<ContentDocument> cdList = (List<ContentDocument>) daonFilesdmlRepoMock.getHistory(
        'deleteRecords'
      )
      .getParam('records');

    Assert.areEqual(0, cdList.size(), 'List returned more than 0 records.');
  }
}