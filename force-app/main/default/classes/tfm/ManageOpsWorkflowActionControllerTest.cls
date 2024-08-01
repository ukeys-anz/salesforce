/**
 * @description       : Test class for ManageOpsWorkflowActionController
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 07-31-2024
 **/
@SuppressWarnings('PMD.LocalVariableNamingConventions')
@isTest
private with sharing class ManageOpsWorkflowActionControllerTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider onboardingActionQueryMock;
  static Lib_MockProvider dmlRepoMock;
  static String personaId = '0123456789';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    '0123456789' => 'MANUAL'
  };
  private static final String ONBOARDING_ACTION = Service.getStaticResource(
    'mock_OnboardingAction'
  );

  static void registerMocks() {
    onboardingActionQueryMock = Lib_MockProvider.forType(
      IDOpsQueryRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Id> cobPIDIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType)
  };

  static List<Id> cobAppsIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(CustomerOnboardingApplication__c.SObjectType)
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
          CustomerOnboardingApplication__c = cobAppsIds[0]
        );
        cobPIDList.add(cobPIDRec);
      }
      return cobPIDList;
    }
  }

  static List<Case> caseRecord {
    get {
      List<Case> cases = new List<Case>();

      Case newCase = new Case(
        Id = caseIds[0],
        Origin = 'Web',
        Type = 'Other',
        Priority = 'Standard',
        IDR_NC_Is_Consent_Obtained__c = false,
        IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
        IDR_Product_Category__c = 'Not product related',
        Description = faker.randomString(10),
        External_Case_ID__c = '0123456789' + '1',
        Aegis_Workflow_Id__c = 'ssss',
        Subject = 'FAILED_DOC',
        PersonaId__c = personaId,
        Status = 'ID Ops: Daon OK',
        RecordType = new RecordType(
          Name = 'PIN_Recovery',
          DeveloperName = 'PIN_Recovery'
        )
      );
      cases.add(newCase);

      return cases;
    }
  }

  static List<Case> caseRecordChild {
    get {
      List<Case> cases = new List<Case>();

      Case newCase = new Case(
        Id = caseIds[1],
        Origin = 'Web',
        Type = 'Other',
        Priority = 'Standard',
        IDR_NC_Is_Consent_Obtained__c = false,
        IDR_Complainant_Desired_Outcome__c = faker.randomString(10),
        IDR_Product_Category__c = 'Not product related',
        Description = faker.randomString(10),
        External_Case_ID__c = '0123456789' + '1',
        Aegis_Workflow_Id__c = 'ssss',
        Subject = 'FAILED_DOC',
        PersonaId__c = personaId,
        Status = 'ID Ops: Daon OK',
        RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
        CustomerOnboardingApplication__c = null
      );
      cases.add(newCase);

      return cases;
    }
  }

  static ManageOpsWorkflowRequestModel requestBody() {
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    manageOpsRequest.case_id = caseRecord[0].Id;
    return manageOpsRequest;
  }

  static void dmlInsertRepoMocksTrue() {
    dmlRepoMock.mock(
      'insertRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
  }

  static void dmlUpdateRepoMocksTrue() {
    dmlRepoMock.mock(
      'updateRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );
  }

  static void dmlInsertRepoMocksFalse() {
    dmlRepoMock.mock(
      'insertRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":false}')
      }
    );
  }

  static void dmlUpdateRepoMocksFalse() {
    dmlRepoMock.mock(
      'updateRecords',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":false}')
      }
    );
  }

  static Map<String, String> testUpdateCaseStatusOnboardingCommonFunction() {
    Case caseRec = caseRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    Case caseChild = caseRecordChild[0];
    caseChild.ParentId = caseRecord[0].Id;
    onboardingActionQueryMock.mock('getCOBPIDRecord', cobPIDRec);
    onboardingActionQueryMock.mock('getCaseRecord', caseRec);
    ManageOpsWorkflowRequestModel manageOpsRequest = requestBody();
    Map<String, String> returnMap = ManageOpsWorkflowActionController.updateCaseStatusOnboarding(
      'testIdValue',
      manageOpsRequest,
      cobPIDRecord[0].Id,
      'ID Ops: Daon OK',
      'Confirmed Fraud'
    );
    return returnMap;
  }

  static Map<String, String> testUpdateCaseStatusPinAndSelfieCommonFunction() {
    Case caseRec = caseRecord[0];
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    Case caseChild = caseRecordChild[0];
    caseChild.ParentId = caseRecord[0].Id;
    onboardingActionQueryMock.mock('getCOBPIDRecord', cobPIDRec);
    onboardingActionQueryMock.mock('getCaseRecord', caseRec);
    ManageOpsWorkflowRequestModel manageOpsRequest = requestBody();
    Map<String, String> returnMap = ManageOpsWorkflowActionController.updateCaseStatusPinAndSelfie(
      'testIdValue',
      manageOpsRequest,
      'ID Ops: Daon OK'
    );
    return returnMap;
  }

  static void manageOpsExceptionCommonFunction() {
    String exceptionMsg = 'You don\'t have required permission to perform this action.';
    Integer statusCode = 401;
    String error = TFMConstants.INSUFFICIENT_ACCESS_ERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
  }

  @isTest
  static void testUpdateCaseStatusOnboarding() {
    registerMocks();
    dmlInsertRepoMocksTrue();
    dmlUpdateRepoMocksTrue();

    Test.startTest();
    Map<String, String> returnMap = testUpdateCaseStatusOnboardingCommonFunction();
    Test.stopTest();
    Assert.areEqual(
      'Success',
      returnMap.get('status'),
      'Operation is not successful.'
    );
  }
  @isTest
  static void callRibbionFlowForOnboardingTestException() {
    Case caseRec = caseRecord[0];
    Test.startTest();
    Boolean response = ManageOpsWorkflowActionController.callRibbionFlowForOnboarding(
      'failedReason',
      'ID Ops: Daon OK',
      caseRec
    );
    Test.stopTest();
    Assert.areEqual(false, response, 'Operation is successful.');
  }
  @isTest
  static void setResponseForOnboardingTest() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForOnboarding(
      true,
      true,
      true
    );
    Test.stopTest();
    Assert.areEqual(
      'Case status updated successfully',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }
  @isTest
  static void setResponseForOnboardingTestException() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForOnboarding(
      false,
      false,
      false
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while creating comments, updating COB Primary ID Document record & updating case status',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void setResponseForOnboardingTestExceptionCOBPID() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForOnboarding(
      true,
      true,
      false
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while - updating COB Primary ID Document record',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }
  @isTest
  static void setResponseForOnboardingTestExceptionRibbionFlow() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForOnboarding(
      false,
      true,
      true
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while - updating case status',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }
  @isTest
  static void setResponseForOnboardingTestExceptionCaseComment() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForOnboarding(
      true,
      false,
      true
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while - creating comments',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void testUpdateCaseStatusPinAndSelfie() {
    registerMocks();
    dmlUpdateRepoMocksTrue();
    dmlInsertRepoMocksTrue();

    Test.startTest();
    Map<String, String> returnMap = testUpdateCaseStatusPinAndSelfieCommonFunction();
    Test.stopTest();
    Assert.areEqual(
      'Success',
      returnMap.get('status'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void testUpdateCaseStatusPinAndSelfieException() {
    registerMocks();
    dmlUpdateRepoMocksTrue();
    dmlInsertRepoMocksTrue();
    manageOpsExceptionCommonFunction();

    Test.startTest();
    Map<String, String> returnMap = testUpdateCaseStatusPinAndSelfieCommonFunction();
    Test.stopTest();
    Assert.areEqual(
      'Error',
      returnMap.get('status'),
      'Operation is successful.'
    );
  }

  @isTest
  static void makeAegisCalloutForSelfieRecordTest() {
    Map<String, String> response = new Map<String, String>();
    ManageOpsWorkflowRequestModel manageOpsRequest = requestBody();
    Case caseRec = caseRecord[0];
    caseRec.RecordType = new RecordType(
      Name = 'Selfie_Recovery',
      DeveloperName = 'Selfie_Recovery'
    );
    Test.startTest();
    response = ManageOpsWorkflowActionController.makeAegisCalloutForPinAndSelfie(
      'testIdValue',
      manageOpsRequest,
      caseRec
    );
    Test.stopTest();
    Assert.areEqual(
      'Success',
      response.get('status'),
      'Operation is successful.'
    );
  }

  @isTest
  static void makeAegisCalloutForPinAndSelfieTest() {
    Map<String, String> response = new Map<String, String>();
    ManageOpsWorkflowRequestModel manageOpsRequest = requestBody();
    Case caseRec = caseRecord[0];
    Test.startTest();
    response = ManageOpsWorkflowActionController.makeAegisCalloutForPinAndSelfie(
      'testIdValue',
      manageOpsRequest,
      caseRec
    );
    Test.stopTest();
    Assert.areEqual(
      'Success',
      response.get('status'),
      'Operation is successful.'
    );
  }

  @isTest
  static void setResponseForPinAndSelfieTest() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForPinAndSelfie(
      true,
      true
    );
    Test.stopTest();
    Assert.areEqual(
      'Case status updated successfully',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void setResponseForPinAndSelfieTestCreateCommentExce() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForPinAndSelfie(
      true,
      false
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while - creating comments',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void setResponseForPinAndSelfieTestCaseExce() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForPinAndSelfie(
      false,
      true
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while - updating case status',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void setResponseForPinAndSelfieTestException() {
    Map<String, String> response = new Map<String, String>();
    Test.startTest();
    response = ManageOpsWorkflowActionController.setResponseForPinAndSelfie(
      false,
      false
    );
    Test.stopTest();
    Assert.areEqual(
      'Error occurred while updating case and creating comments',
      response.get('responseMessage'),
      'Operation is not successful.'
    );
  }

  @isTest
  static void testCreateCaseComment() {
    Case caseRec = caseRecord[0];
    Test.startTest();
    CaseComment CaseCommentObj = ManageOpsWorkflowActionController.setCaseComment(
      caseRec.Id,
      'case comments testing'
    );
    Test.stopTest();
    Assert.areEqual(
      'case comments testing',
      CaseCommentObj.CommentBody,
      'Operation is not successful.'
    );
  }

  @isTest
  static void testUpdateCOBPIDRecord() {
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    Test.startTest();
    ManageOpsWorkflowActionController.setCOBPIDRecord(
      'Failed Message',
      'Confirmed Fraud',
      'ID Ops: Daon OK',
      cobPIDRec
    );
    Test.stopTest();
    Assert.areEqual(
      'ID Ops: Daon OK',
      cobPIDRec.Verification_Status__c,
      'Operation is not successful.'
    );
  }

  @isTest
  static void updateCaseRecordTest() {
    Case caseRec = caseRecord[0];
    Test.startTest();
    ManageOpsWorkflowActionController.setCaseRecord(
      caseRec,
      'Failed Message',
      'Confirmed Fraud'
    );
    Test.stopTest();
    Assert.areEqual(
      'Failed Message',
      caseRec.Status,
      'Operation is not successful.'
    );
  }
}