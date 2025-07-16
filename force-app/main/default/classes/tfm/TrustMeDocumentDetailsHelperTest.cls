/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-15-2025
 **/
@IsTest
public with sharing class TrustMeDocumentDetailsHelperTest {
  static Lib_MockProvider trustMeQueryMock;
  static Faker faker = new Faker('AU');

  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static void registerMocks() {
    trustMeQueryMock = Lib_MockProvider.forType(
      TrustMeDocumentQueryRepository.class
    );
  }
  static List<Id> trustMeSectionIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(TrustMe_Docs_Tab_Section__mdt.SObjectType)
  };

  static List<Id> trustMeSectionDetailsIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(
      TrustMe_Docs_Tab_Section_Detail__mdt.SObjectType
    )
  };

  static final Id CV1 = Lib_FakeIdGenerator.getMockId(
    ContentVersion.SObjectType
  );
  static final Id CV2 = Lib_FakeIdGenerator.getMockId(
    ContentVersion.SObjectType
  );

  static TrustMe_Docs_Tab_Section__mdt trustMeSectionED {
    get {
      TrustMe_Docs_Tab_Section__mdt rec = new TrustMe_Docs_Tab_Section__mdt();
      rec.MasterLabel = 'EV Provider Outcomes';
      rec.DeveloperName = 'EV_Provider_Outcomes';
      rec.Id = trustMeSectionIds[0];
      return rec;
    }
  }

  static List<TrustMe_Docs_Tab_Section_Detail__mdt> trustMeSectionDetailsED {
    get {
      List<TrustMe_Docs_Tab_Section_Detail__mdt> recList = new List<TrustMe_Docs_Tab_Section_Detail__mdt>();
      TrustMe_Docs_Tab_Section_Detail__mdt rec = new TrustMe_Docs_Tab_Section_Detail__mdt();
      rec.MasterLabel = 'Client ID';
      rec.API_Node__c = 'clientId';
      rec.TrustMe_Docs_Tab_Section__c = trustMeSectionED.Id;
      rec.TrustMe_Docs_Tab_Section__r = trustMeSectionED;
      rec.TrustMe_Docs_Tab_Section__r.DeveloperName = 'EV_Provider_Outcomes';
      rec.Id = trustMeSectionDetailsIds[0];
      recList.add(rec);
      return recList;
    }
  }
  static List<Case> caseRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Origin = 'Web',
          Type = 'Other',
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          Evaluation_Id__c = '1234003332',
          Subject = 'TrustMe Manual Review - Document',
          RecordTypeId = RTCase.trustMeManualReview,
          Status = 'ID and Selfie Check Passed'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }
  static TrustMeDocumentRequestModel trustMeDocumentRequestModel {
    get {
      List<TrustMeDocumentRequestModel.Attachments> attachmentList = new List<TrustMeDocumentRequestModel.Attachments>();
      TrustMeDocumentRequestModel.Attachments obj1 = new TrustMeDocumentRequestModel.Attachments();
      obj1.documentId = 'doc1';
      obj1.uri = 'https://trustme.anz/evaluation/5a88f9ff-d1ae-438b-9ac3-39103268a474/attachment/1234';
      obj1.fileType = 'FILE_TYPE_FRONT_PROCESSED';

      TrustMeDocumentRequestModel.Attachments obj2 = new TrustMeDocumentRequestModel.Attachments();
      obj2.documentId = 'doc2';
      obj2.uri = 'https://trustme.anz/evaluation/5a88f9ff-d1ae-438b-9ac3-39103268a474/attachment/1234';
      obj2.fileType = 'FILE_TYPE_FRONT_PROCESSED';
      attachmentList.add(obj1);
      attachmentList.add(obj2);
      TrustMeDocumentRequestModel obj = new TrustMeDocumentRequestModel();
      obj.requestedUser = userinfo.getUserId();
      obj.evaluationId = caseRecord[0].Evaluation_Id__c;
      obj.relatedId = caseRecord[0].Id;
      obj.attachments = attachmentList;
      return obj;
    }
  }
  @isTest
  static void testQueryCvByType() {
    Lib_MockProvider.forType(TrustMeDocumentQueryRepository.class)
      .mock('contentVersionsByUUIDs', new List<ContentVersion>());
    // Setup test data
    Map<String, String> uuidByType = new Map<String, String>{
      'FILE_TYPE_FRONT_UNPROCESSED' => 'uuid1',
      'FILE_TYPE_FRONT_PROCESSED' => 'uuid2'
    };
    Test.startTest();
    Map<String, ContentVersion> result = TrustMeDocumentDetailsHelper.queryCvByType(
      uuidByType
    );
    Test.stopTest();
    Assert.isTrue(result.size() == 2, 'Result should contain 2 entries');
  }

  @isTest
  static void testBuildUUIDByType() {
    registerMocks();
    List<TrustMe_Docs_Tab_Section_Detail__mdt> trustMeMdtList = trustMeSectionDetailsED;
    trustMeQueryMock.mock('getEvaluationMetadataMapping', trustMeMdtList);

    TrustMeDocumentRequestModel requestModel = trustMeDocumentRequestModel;
    Test.startTest();
    Map<String, String> result = TrustMeDocumentDetailsHelper.buildUUIDByType(
      requestModel
    );
    Test.stopTest();
    Assert.isTrue(result.size() == 1, 'Result should contain 2 entries');
  }

  @isTest
  static void testFilterIncomplete() {
    Map<String, ContentVersion> cvByType = new Map<String, ContentVersion>{
      'FILE_TYPE_FRONT_UNPROCESSED' => new ContentVersion(
        Document_Flag__c = '4'
      ),
      'FILE_TYPE_FRONT_PROCESSED' => new ContentVersion(Document_Flag__c = '3')
    };
    Test.startTest();
    Map<String, ContentVersion> result = TrustMeDocumentDetailsHelper.filterIncomplete(
      cvByType
    );
    Test.stopTest();

    Assert.areEqual(1, result.size(), 'Result should contain 1 entry');
    Assert.isTrue(
      result.containsKey('FILE_TYPE_FRONT_PROCESSED'),
      'Result should contain the incomplete entry'
    );
  }

  @isTest
  static void testBuildCvByType() {
    Map<String, ContentVersion> cvByUUID = new Map<String, ContentVersion>{
      'uuid1' => new ContentVersion(Id = CV1),
      'uuid2' => new ContentVersion(Id = CV2)
    };
    Map<String, String> uuidByType = new Map<String, String>{
      'FILE_TYPE_FRONT_UNPROCESSED' => 'uuid1',
      'FILE_TYPE_FRONT_PROCESSED' => 'uuid2'
    };

    Test.startTest();
    Map<String, ContentVersion> result = TrustMeDocumentDetailsHelper.buildCvByType(
      cvByUUID,
      uuidByType
    );
    Test.stopTest();

    Assert.areEqual(2, result.size(), 'Result should contain 2 entries');
    Assert.isTrue(
      result.get('FILE_TYPE_FRONT_UNPROCESSED').Id == CV1,
      'Result should contain the correct ContentVersion for FRONT_UNPROCESSED'
    );
    Assert.isTrue(
      result.get('FILE_TYPE_FRONT_PROCESSED').Id == CV2,
      'Result should contain the correct ContentVersion for FRONT_PROCESSED'
    );
  }

  @isTest
  static void testIsReady() {
    ContentVersion cvReady = new ContentVersion(Document_Flag__c = '4');
    ContentVersion cvNotReady = new ContentVersion(Document_Flag__c = '3');

    Assert.isTrue(
      TrustMeDocumentDetailsHelper.isReady(cvReady),
      'ContentVersion should be ready'
    );
    Assert.isFalse(
      TrustMeDocumentDetailsHelper.isReady(cvNotReady),
      'ContentVersion should not be ready'
    );
  }
  @isTest
  static void testBuildUrlByType() {
    Map<String, ContentVersion> cvByType = new Map<String, ContentVersion>{
      'FILE_TYPE_FRONT_UNPROCESSED' => new ContentVersion(
        Id = CV1,
        Document_Flag__c = '4'
      ),
      'FILE_TYPE_FRONT_PROCESSED' => new ContentVersion(
        Id = CV2,
        Document_Flag__c = '3'
      )
    };

    Test.startTest();
    Map<String, String> result = TrustMeDocumentDetailsHelper.buildUrlByType(
      cvByType
    );
    Test.stopTest();

    Assert.areEqual(2, result.size(), 'Result should contain 2 entries');
    Assert.isTrue(
      result.get('FILE_TYPE_FRONT_UNPROCESSED') ==
      (Label.DAONImagePreviewURL + CV1),
      'Result should contain the correct URL for FRONT_UNPROCESSED'
    );
    Assert.isNull(
      result.get('FILE_TYPE_FRONT_PROCESSED'),
      'Result should contain null for FRONT_PROCESSED'
    );
  }
}