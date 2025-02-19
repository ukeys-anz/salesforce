@isTest
public class DAONFileControllerTest {
  static final Id CV1 = Lib_FakeIdGenerator.getMockId(
    ContentVersion.SObjectType
  );
  static final Id CV2 = Lib_FakeIdGenerator.getMockId(
    ContentVersion.SObjectType
  );
  static DAONFileRequestBuilder builder {
    get {
      if (builder != null) {
        return builder;
      }
      builder = new DAONFileRequestBuilder();
      builder.customerId = 'testCustomerId';
      builder.customerIdType = 'testCustomerIdType';
      builder.idxUserId = 'testIdxUserId';
      builder.idxIdCheckId = 'testIdxIdCheckId';
      builder.idxDocumentId = 'testIdxDocumentId';
      builder.idxExtractedFaceId = 'testIdxExtractedFaceId';
      builder.workflowId = 'testWorkflowId';
      builder.challengeId = 'testChallengeId';
      builder.challengeType = 'SELFIE_RECOVERY_CHALLENGE_TYPE_REG_CHALLENGE';
      return builder;
    }
    set;
  }

  @isTest
  static void testGetDocuments() {
    Lib_MockProvider.forType(DAONFileRepository.class)
      .mock('contentVersionsByUUIDs', new List<ContentVersion>());
    List<String> fileTypes = new List<String>{
      'DAON_FILE_TYPE_FRONT_UNPROCESSED',
      'DAON_FILE_TYPE_FRONT_PROCESSED'
    };

    Test.startTest();
    Map<String, String> result = DAONFileController.getDocuments(
      builder,
      fileTypes
    );
    Test.stopTest();

    Assert.areEqual(2, result.size(), 'Result should contain entries');
  }

  @isTest
  static void testQueryCvByType() {
    Lib_MockProvider.forType(DAONFileRepository.class)
      .mock('contentVersionsByUUIDs', new List<ContentVersion>());
    // Setup test data
    Map<DAONFileType, String> uuidByType = new Map<DAONFileType, String>{
      DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED => 'uuid1',
      DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED => 'uuid2'
    };

    Test.startTest();
    Map<DAONFileType, ContentVersion> result = DAONFileController.queryCvByType(
      uuidByType
    );
    Test.stopTest();

    Assert.isTrue(result.size() == 2, 'Result should contain 2 entries');
  }

  @isTest
  static void testFilterIncomplete() {
    Map<DAONFileType, ContentVersion> cvByType = new Map<DAONFileType, ContentVersion>{
      DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED => new ContentVersion(
        Document_Flag__c = '4'
      ),
      DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED => new ContentVersion(
        Document_Flag__c = '3'
      )
    };

    Test.startTest();
    Map<DAONFileType, ContentVersion> result = DAONFileController.filterIncomplete(
      cvByType
    );
    Test.stopTest();

    Assert.areEqual(1, result.size(), 'Result should contain 1 entry');
    Assert.isTrue(
      result.containsKey(DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED),
      'Result should contain the incomplete entry'
    );
  }

  @isTest
  static void testBuildCvByType() {
    Map<String, ContentVersion> cvByUUID = new Map<String, ContentVersion>{
      'uuid1' => new ContentVersion(Id = CV1),
      'uuid2' => new ContentVersion(Id = CV2)
    };
    Map<DAONFileType, String> uuidByType = new Map<DAONFileType, String>{
      DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED => 'uuid1',
      DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED => 'uuid2'
    };

    Test.startTest();
    Map<DAONFileType, ContentVersion> result = DAONFileController.buildCvByType(
      cvByUUID,
      uuidByType
    );
    Test.stopTest();

    Assert.areEqual(2, result.size(), 'Result should contain 2 entries');
    Assert.isTrue(
      result.get(DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED).Id == CV1,
      'Result should contain the correct ContentVersion for FRONT_UNPROCESSED'
    );
    Assert.isTrue(
      result.get(DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED).Id == CV2,
      'Result should contain the correct ContentVersion for FRONT_PROCESSED'
    );
  }

  @isTest
  static void testIsReady() {
    ContentVersion cvReady = new ContentVersion(Document_Flag__c = '4');
    ContentVersion cvNotReady = new ContentVersion(Document_Flag__c = '3');

    Assert.isTrue(
      DAONFileController.isReady(cvReady),
      'ContentVersion should be ready'
    );
    Assert.isFalse(
      DAONFileController.isReady(cvNotReady),
      'ContentVersion should not be ready'
    );
  }

  @isTest
  static void testBuildUrlByType() {
    Map<DAONFileType, ContentVersion> cvByType = new Map<DAONFileType, ContentVersion>{
      DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED => new ContentVersion(
        Id = CV1,
        Document_Flag__c = '4'
      ),
      DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED => new ContentVersion(
        Id = CV2,
        Document_Flag__c = '3'
      )
    };

    Test.startTest();
    Map<String, String> result = DAONFileController.buildUrlByType(cvByType);
    Test.stopTest();

    Assert.areEqual(2, result.size(), 'Result should contain 2 entries');
    Assert.isTrue(
      result.get('DAON_FILE_TYPE_FRONT_UNPROCESSED') ==
      (Label.DAONImagePreviewURL + CV1),
      'Result should contain the correct URL for FRONT_UNPROCESSED'
    );
    Assert.isNull(
      result.get('DAON_FILE_TYPE_FRONT_PROCESSED'),
      'Result should contain null for FRONT_PROCESSED'
    );
  }
}
