@isTest
private class OnboardingFalloutWorkflowControllerTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider onboardingQueryMock;
  static String personaId = '0123456789';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    '0123456789' => 'MANUAL'
  };

  static void registerMocks() {
    onboardingQueryMock = Lib_MockProvider.forType(
      OnboardingQueryRepository.class
    );
  }

  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Id> cobPIDIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType)
  };

  static List<Id> cobAppsIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(CustomerOnboardingApplication__c.SObjectType)
  };

  static List<Id> cvIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ContentVersion.SObjectType)
  };

  static List<CustomerOnboardingApplication__c> coaAppRecord {
    get {
      List<CustomerOnboardingApplication__c> coaAppList = new List<CustomerOnboardingApplication__c>();
      for (Id caoAppId : cobAppsIds) {
        CustomerOnboardingApplication__c coaAppRec = new CustomerOnboardingApplication__c(
          Id = caoAppId,
          PersonaId__c = personaId,
          VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(personaId),
          OnboardingAttemptCount__c = 1,
          CXOnboardingStage__c = 'Assisted Selfie'
        );
        coaAppList.add(coaAppRec);
      }
      return coaAppList;
    }
  }

  static List<COBPrimaryIDDocument__c> cobPIDRecord {
    get {
      List<COBPrimaryIDDocument__c> cobPIDList = new List<COBPrimaryIDDocument__c>();
      for (Id cobPIDId : cobPIDIds) {
        COBPrimaryIDDocument__c cobPIDRec = new COBPrimaryIDDocument__c(
          Id = cobPIDId,
          //CustomerOnboardingApplication__c = cobPIDIds[0],
          IdDocumentType__c = 'Licence',
          PersonaId__c = personaId,
          DaonLocationUri__c = '/rest/v1/users/testUserId/idchecks/testIdCheck/documents/testDocId',
          idxExtractedFaceId__c = 'sampleFaceId',
          Verification_Status__c = 'abc',
          CustomerOnboardingApplication__r = new CustomerOnboardingApplication__c(
            //Id = caoAppId,
            PersonaId__c = personaId,
            PersonId__c = personaId,
            VerificationType__c = PERSONA_ID_VERIFICATION_TYPES.get(personaId),
            OnboardingAttemptCount__c = 1,
            CXOnboardingStage__c = 'Assisted Selfie'
          )
        );
        cobPIDList.add(cobPIDRec);
      }
      return cobPIDList;
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
          PersonaAttemptCount__c = '0123456789' + '1',
          Aegis_Workflow_Id__c = 'ssss',
          Subject = 'FAILED_DOC'
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<ContentVersion> cvList {
    get {
      Id recordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName()
        .get('DAON File')
        .getRecordTypeId();
      String base64Data;

      List<ContentVersion> cvList = new List<ContentVersion>();
      for (Id cvId : cvIds) {
        base64Data = EncodingUtil.urlDecode('test', 'UTF-8');
        ContentVersion cvRec = new ContentVersion(
          VersionData = EncodingUtil.base64Decode(base64Data),
          Title = 'DAON_FILE_TYPE_EXTRACTED_FACE',
          PathOnClient = 'DAON_FILE_TYPE_EXTRACTED_FACE' + '.jpg',
          RecordTypeID = recordTypeId,
          FirstPublishLocationId = cvId,
          UUID__c = UserInfo.getUserId() +
            '-DAON_FILE_TYPE_EXTRACTED_FACE-sampleFaceId',
          Document_Flag__c = '1'
        );
        cvList.add(cvRec);
      }
      return cvList;
    }
  }

  @isTest
  static void testFieldsStatus() {
    registerMocks();
    addCustomPermission();
    OnboardingWorkflowWrapper workflowDetails;
    Case caseRec = caseRecord[0];
    ContentVersion cVRec = cvList[0];
    CustomerOnboardingApplication__c cobApp = coaAppRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];

    onboardingQueryMock.mock('getCOBPIDRecord', cobPIDRec);
    onboardingQueryMock.mock('getCaseRecord', caseRec);
    onboardingQueryMock.mock(
      'fetchContentVersions',
      new List<ContentVersion>{ cVRec }
    );

    Test.startTest();
    workflowDetails = OnboardingFalloutWorkflowController.performOnboardingOperations(
      cobPIDRec.Id
    );
    Test.stopTest();

    Assert.areEqual(
      '0123456789',
      cobPIDRec.CustomerOnboardingApplication__r.PersonaId__c,
      'IDValue should match'
    );
    Assert.areEqual(
      true,
      workflowDetails.showCheckboxes,
      'Show required checkboxes should be true'
    );
  }

  @isTest
  static void testFetchOnboardingDocuments() {
    OnboardingWorkflowWrapper details;
    registerMocks();
    addCustomPermission();
    Case caseRec = caseRecord[0];
    ContentVersion cVRec = cvList[0];
    CustomerOnboardingApplication__c cobApp = coaAppRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];

    onboardingQueryMock.mock('getCOBPIDRecord', cobPIDRec);
    onboardingQueryMock.mock('getCaseRecord', caseRec);
    onboardingQueryMock.mock(
      'fetchContentVersions',
      new List<ContentVersion>{ cVRec }
    );

    OnboardingWorkflowWrapper workflowDetails = OnboardingFalloutWorkflowController.performOnboardingOperations(
      cobPIDRec.Id
    );
    Test.startTest();
    details = OnboardingFalloutWorkflowController.fetchOnboardingDocumentsLWC(
      JSON.serialize(workflowDetails)
    );
    Test.stopTest();

    Assert.areEqual(
      'sampleFaceId',
      details.idxExtractedFaceId,
      'Extracted Face Id should match'
    );
  }

  @isTest
  static void testApiCallToFetchImages() {
    registerMocks();
    addCustomPermission();
    OnboardingWorkflowWrapper workflowDetailsAPI;
    Case caseRec = caseRecord[0];
    ContentVersion cVRec = cvList[0];
    CustomerOnboardingApplication__c cobApp = coaAppRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];

    onboardingQueryMock.mock('getCOBPIDRecord', cobPIDRec);
    onboardingQueryMock.mock('getCaseRecord', caseRec);
    onboardingQueryMock.mock(
      'fetchContentVersions',
      new List<ContentVersion>{ cVRec }
    );

    OnboardingWorkflowWrapper workflowDetails = OnboardingFalloutWorkflowController.performOnboardingOperations(
      cobPIDRec.Id
    );
    OnboardingWorkflowWrapper details = OnboardingFalloutWorkflowController.fetchOnboardingDocumentsLWC(
      JSON.serialize(workflowDetails)
    );
    Test.startTest();
    workflowDetailsAPI = OnboardingFalloutWorkflowController.apiCallToFetchImagesLWC(
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
  static void testPopulateWorkflowDetails() {
    Case caseRec = caseRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    Test.startTest();
    OnboardingWorkflowWrapper workflowDetails = OnboardingFalloutWorkflowHelper.populateWorkflowDetails(
      cobPIDRec,
      caseRec
    );
    Test.stopTest();
    Assert.areEqual(
      cobPIDRec.Id,
      workflowDetails.cobPIDRecordId,
      'cobPIDRecordId is not set in workflowDetails wrapper'
    );
    Assert.areEqual(
      cobPIDRec.CustomerOnboardingApplication__r.PersonId__c,
      workflowDetails.IDValue,
      'IDValue not set in populateWorkflowDetails'
    );
  }

  @isTest
  static void testFetchIdentifierValues() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    Test.startTest();
    OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
      workflowDetails,
      cobPIDRec.DaonLocationUri__c
    );
    Test.stopTest();
    Assert.areEqual(
      'testUserId',
      workflowDetails.userId,
      'userId does not match'
    );
    Assert.areEqual(
      'testIdCheck',
      workflowDetails.idCheck,
      'idCheck does not match'
    );
    Assert.areEqual(
      'testDocId',
      workflowDetails.documentId,
      'documentId does not match'
    );
  }

  @isTest
  static void testFormRequestBody() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    ContentVersion cVRec = cvList[0];
    OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
      workflowDetails,
      cobPIDRec.DaonLocationUri__c
    );
    Test.startTest();
    OnboardingRequestModel.DAONFile daonFileData = OnboardingFalloutWorkflowHelper.formRequestBody(
      workflowDetails,
      'DAON_FILE_TYPE_EXTRACTED_FACE',
      cVRec.Id
    );
    Test.stopTest();
    Assert.areEqual(
      'DAON_FILE_TYPE_EXTRACTED_FACE',
      daonFileData.file_type,
      'file_type not set'
    );
  }

  @isTest
  static void testFormFileTypeData() {
    ContentVersion cVRec = cvList[0];
    Test.startTest();
    OnboardingWorkflowWrapper.FileTypes fileData = OnboardingFalloutWorkflowHelper.formFileTypeData(
      cVRec
    );
    Test.stopTest();
    Assert.areEqual(true, fileData.isImageDraft, 'Image is not draft');
  }

  @isTest
  static void testFormFilesList() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
      workflowDetails,
      cobPIDRec.DaonLocationUri__c
    );
    Test.startTest();
    List<OnboardingWorkflowWrapper.FileTypes> filesList = OnboardingFalloutWorkflowHelper.formFilesList(
      workflowDetails,
      cvList
    );
    Test.stopTest();
    Assert.areEqual(4, filesList.size(), 'Files size should be 4');
  }

  @isTest
  static void testLoadData() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    OnboardingWorkflowWrapper.FileTypes fileData = new OnboardingWorkflowWrapper.FileTypes();
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
      workflowDetails,
      cobPIDRec.DaonLocationUri__c
    );
    Test.startTest();
    OnboardingFalloutWorkflowHelper.loadData(
      'DAON_FILE_TYPE_FRONT_UNPROCESSED',
      fileData,
      workflowDetails
    );
    OnboardingFalloutWorkflowHelper.loadData(
      'DAON_FILE_TYPE_FRONT_PROCESSED',
      fileData,
      workflowDetails
    );
    OnboardingFalloutWorkflowHelper.loadData(
      'DAON_FILE_TYPE_EXTRACTED_FACE',
      fileData,
      workflowDetails
    );
    OnboardingFalloutWorkflowHelper.loadData(
      'DAON_FILE_TYPE_SELFIE',
      fileData,
      workflowDetails
    );
    Test.stopTest();
    Assert.isNotNull(
      workflowDetails.unProcessedImageData,
      'unProcessedImageData is null'
    );
    Assert.isNotNull(
      workflowDetails.processedImageData,
      'processedImageData is null'
    );
    Assert.isNotNull(
      workflowDetails.extractedFaceData,
      'extractedFaceData is null'
    );
    Assert.isNotNull(workflowDetails.selfieData, 'selfieData is null');
  }

  @isTest
  static void testRequestBodyAPICallout() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
      workflowDetails,
      cobPIDRec.DaonLocationUri__c
    );
    workflowDetails.fileTypesList = OnboardingFalloutWorkflowHelper.formFilesList(
      workflowDetails,
      cvList
    );

    Test.startTest();
    List<OnboardingRequestModel> daonList = OnboardingFalloutWorkflowHelper.requestBodyAPICallout(
      workflowDetails
    );
    Test.stopTest();
    Assert.areEqual(4, daonList.size(), 'Files size should be 4');
  }

  @isTest
  static void testGetPinWorkflowData() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    workflowDetails.idxRegistrationChallengeId = 'testidxRegistrationChallengeId';
    workflowDetails.idxChallengeType = 'testidxChallengeType';
    Test.startTest();
    OnboardingRequestModel.PinRecoveryChallenge pinRecChallenge = OnboardingFalloutWorkflowHelper.getPinWorkflowData(
      workflowDetails
    );
    OnboardingRequestModel.SelfieRecoveryChallenge selfieRecChallenge = OnboardingFalloutWorkflowHelper.getSelfieWorkflowData(
      workflowDetails
    );
    Test.stopTest();
    Assert.areEqual(
      'testidxRegistrationChallengeId',
      pinRecChallenge.idx_challenge_id,
      'pinRecChallenge wrapper not filled'
    );
    Assert.areEqual(
      'testidxChallengeType',
      selfieRecChallenge.idx_challenge_type,
      'selfieRecChallenge wrapper not filled'
    );
  }

  @isTest
  static void testGetChallengeIdForSelfie() {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    workflowDetails.idxRegistrationChallengeId = 'testidxRegistrationChallengeId';
    workflowDetails.idxChallengeType = 'SELFIE_RECOVERY_CHALLENGE_TYPE_REG_CHALLENGE';
    Test.startTest();
    String idxChallengeId = OnboardingFalloutWorkflowHelper.getChallengeIdForSelfie(
      workflowDetails
    );
    Test.stopTest();
    Assert.areEqual(
      'testidxRegistrationChallengeId',
      idxChallengeId,
      'testidxRegistrationChallengeId is not returned'
    );
  }

  private static void addCustomPermission() {
    onboardingQueryMock.mock('checkCustomPermission', true);
  }
}