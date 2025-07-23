/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-15-2025
 **/
@IsTest
public with sharing class TrustMeDocumentDetailsControllerTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider trustMeQueryMock;
  static void registerMocks() {
    trustMeQueryMock = Lib_MockProvider.forType(
      TrustMeDocumentQueryRepository.class
    );
  }

  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Id> trustMeSectionIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(TrustMe_Docs_Tab_Section__mdt.SObjectType)
  };

  static List<Id> trustMeSectionDetailsIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(
      TrustMe_Docs_Tab_Section_Detail__mdt.SObjectType
    )
  };

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
  static void testGetEvaluationDetails() {
    registerMocks();
    trustMeQueryMock.mock('getCaseRecordById', caseRecord[0]);
    Test.startTest();
    TrustMeDocumentDetailsModel obj = TrustMeDocumentDetailsController.getEvaluationDetails(
      caseRecord[0].Id
    );
    Assert.areEqual(
      true,
      obj.addressDetails != null,
      'address node is not available'
    );
    Test.stopTest();
  }

  @isTest
  static void testGetEvaluationDetailsInsufficientAccessException() {
    registerMocks();
    List<TrustMe_Docs_Tab_Section_Detail__mdt> trustMeMdtList = trustMeSectionDetailsED;
    trustMeQueryMock.mock('getCaseRecordById', caseRecord[0]);
    trustMeQueryMock.mock('getEvaluationMetadataMapping', trustMeMdtList);
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 401;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getEvaluationDetails', res);
    try {
      Test.startTest();
      TrustMeDocumentDetailsController.getEvaluationDetails(caseRecord[0].Id);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Insufficent Access Exception expected'
      );
    }
  }

  @isTest
  static void testGetEvaluationDetailsServerException() {
    registerMocks();
    List<TrustMe_Docs_Tab_Section_Detail__mdt> trustMeMdtList = trustMeSectionDetailsED;
    trustMeQueryMock.mock('getCaseRecordById', caseRecord[0]);
    trustMeQueryMock.mock('getEvaluationMetadataMapping', trustMeMdtList);
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getEvaluationDetails', res);
    try {
      Test.startTest();
      TrustMeDocumentDetailsController.getEvaluationDetails(caseRecord[0].Id);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server Exception expected'
      );
    }
  }

  @isTest
  static void testGetEvaluationDetailsException() {
    try {
      Test.startTest();
      TrustMeDocumentDetailsController.getEvaluationDetails(caseRecord[0].Id);
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception expected'
      );
    }
  }

  @isTest
  static void testGetTrustMeDocuments() {
    registerMocks();
    trustMeQueryMock.mock('getCaseRecordById', caseRecord[0]);
    Lib_MockProvider.forType(TrustMeDocumentQueryRepository.class)
      .mock('contentVersionsByUUIDs', new List<ContentVersion>());
    Test.startTest();
    Map<String, String> result = TrustMeDocumentDetailsController.getTrustMeDocuments(
      trustMeDocumentRequestModel
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Result should contain entries');
  }

  @isTest
  static void testGetTrustMeDocumentsServerException() {
    registerMocks();
    trustMeQueryMock.mock('getCaseRecordById', caseRecord[0]);
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    Lib_MockProvider.forType(TrustMeService.class)
      .mock('getTrustMeDocuments', res);
    Lib_MockProvider.forType(TrustMeDocumentQueryRepository.class)
      .mock('contentVersionsByUUIDs', new List<ContentVersion>());
    try {
      Test.startTest();
      TrustMeDocumentDetailsController.getTrustMeDocuments(
        trustMeDocumentRequestModel
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Server Exception expected'
      );
    }
  }
}
