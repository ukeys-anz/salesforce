@isTest
private with sharing class PinAndSelfieWorkflowControllerTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider dmlRepoMock;
  static String personaId = '0123456789';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    '0123456789' => 'MANUAL'
  };

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(IDOpsQueryRepository.class);
  }
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Id> cOAIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(CustomerOnboardingApplication__c.SObjectType)
  };

  static List<Id> cvIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ContentVersion.SObjectType)
  };

  static List<CustomerOnboardingApplication__c> coARecord {
    get {
      List<CustomerOnboardingApplication__c> cOAList = new List<CustomerOnboardingApplication__c>();
      for (Id coaId : cOAIds) {
        CustomerOnboardingApplication__c cOARec = new CustomerOnboardingApplication__c(
          PersonaId__c = personaId,
          VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(personaId),
          OnboardingAttemptCount__c = 1,
          CXOnboardingStage__c = 'Assisted Selfie'
        );
        cOAList.add(cOARec);
      }
      return cOAList;
    }
  }

  static List<Case> caseSelfieRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          External_Case_ID__c = '0123456789' + '-1',
          Aegis_Workflow_Id__c = 'ssss',
          Subject = 'FAILED_DOC',
          Daon_User_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Check_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Document_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Auth_Request_Id__c = 'Q0RDNENGNEEtMkEwOS00MUVDLTfake',
          Daon_Reg_Challenge_Id__c = 'Q0RDNENGNEEtMkEwOS00fake'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<Case> casePINRecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Priority = 'Standard',
          IDR_NC_Is_Consent_Obtained__c = false,
          IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
          IDR_Product_Category__c = 'Not product related',
          Description = faker.randomString(10),
          External_Case_ID__c = '0123456789' + '-1',
          Aegis_Workflow_Id__c = 'ssss',
          Subject = 'FAILED_DOC',
          Daon_User_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Check_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Document_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          Daon_Auth_Request_Id__c = 'Q0RDNENGNEEtMkEwOS00MUVDLTfake',
          Daon_Reg_Challenge_Id__c = 'Q0RDNENGNEEtMkEwOS00fake',
          RecordTypeID = Schema.sObjectType.Case.getRecordTypeInfosByName()
            .get('PIN Recovery')
            .getRecordTypeId()
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<ContentVersion> cvList {
    get {
      List<ContentVersion> cvList = new List<ContentVersion>();
      for (Id cvId : cvIds) {
        ContentVersion cvRec = new ContentVersion(
          Title = 'DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED',
          PathOnClient = '500Bm00000DnNKFAKE' + '.jpg',
          RecordTypeID = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
            .get('DAON File')
            .getRecordTypeId(),
          FirstPublishLocationId = cvId,
          UUID__c = UserInfo.getUserId() +
            '-DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED-Q0RDNENGNEEtMkEwOS00fake',
          Document_Flag__c = '1'
        );
        cvList.add(cvRec);
      }
      return cvList;
    }
  }

  @isTest
  static void testFetchOnboardingDocuments() {
    registerMocks();
    Case caseRec = caseSelfieRecord[0];
    ContentVersion cVRec = cvList[0];
    OnboardingWorkflowWrapper workflowDetailsAPI;
    //override "getCaseRecord" mock with a new return value
    dmlRepoMock.mock('getCaseRecord', caseRec);
    //override "getCVRecord" mock with a new return value
    dmlRepoMock.mock('getCVRecord', new List<ContentVersion>{ cVRec });

    OnboardingWorkflowWrapper workflowDetails = PinAndSelfieWorkflowController.performOnboardingOperations(
      caseRec.Id
    );
    OnboardingWorkflowWrapper details = PinAndSelfieWorkflowController.fetchOnboardingDocumentsLWC(
      JSON.serialize(workflowDetails)
    );
    Test.startTest();
    workflowDetailsAPI = PinAndSelfieWorkflowController.apiCallToFetchImagesLWC(
      JSON.serialize(details)
    );
    Test.stopTest();

    Assert.areEqual(
      'Success',
      workflowDetailsAPI.responseMsg,
      'API should return success'
    );
  }
  @isTest
  static void testFieldsStatus() {
    registerMocks();
    OnboardingWorkflowWrapper details;
    Case caseRec = caseSelfieRecord[0];
    ContentVersion cVRec = cvList[0];

    //override "getCaseRecord" mock with a new return value
    dmlRepoMock.mock('getCaseRecord', caseRec);
    //override "getCVRecord" mock with a new return value
    dmlRepoMock.mock('getCVRecord', new List<ContentVersion>{ cVRec });

    System.runAs(new User(Id = UserInfo.getUserId())) {
      Test.startTest();
      details = PinAndSelfieWorkflowController.performOnboardingOperations(
        caseRec.Id
      );
      Test.stopTest();
    }

    Assert.areEqual(caseRec.Id, details.caseId, 'Case is not matching');
  }

  @isTest
  static void testFetchPINOnboardingDocuments() {
    registerMocks();
    Case caseRec = casePINRecord[0];
    ContentVersion cVRec = cvList[0];
    OnboardingWorkflowWrapper workflowDetailsAPI;

    //override "getCaseRecord" mock with a new return value
    dmlRepoMock.mock('getCaseRecord', caseRec);
    //override "getCVRecord" mock with a new return value
    dmlRepoMock.mock('getCVRecord', new List<ContentVersion>{ cVRec });

    OnboardingWorkflowWrapper workflowDetails = PinAndSelfieWorkflowController.performOnboardingOperations(
      caseRec.Id
    );
    OnboardingWorkflowWrapper details = PinAndSelfieWorkflowController.fetchOnboardingDocumentsLWC(
      JSON.serialize(workflowDetails)
    );
    details.isPinWorkflow = true;
    Test.startTest();
    workflowDetailsAPI = PinAndSelfieWorkflowController.apiCallToFetchImagesLWC(
      JSON.serialize(details)
    );
    Test.stopTest();

    Assert.areEqual(
      'Success',
      workflowDetailsAPI.responseMsg,
      'API should return success'
    );
  }
  @isTest
  static void testpopulateWorkflowDetails() {
    registerMocks();
    Case caseRec = casePINRecord[0];
    OnboardingWorkflowWrapper workflowDetails;

    //override "getCaseRecord" mock with a new return value
    dmlRepoMock.mock('getCaseRecord', caseRec);
    Test.startTest();
    workflowDetails = PinAndSelfieWorkflowController.populateWorkflowDetails(
      caseRec
    );
    Test.stopTest();
    Assert.areEqual(
      caseRec.Id,
      workflowDetails.caseId,
      'OnboardingWorkflowWrapper is empty'
    );
  }
}
