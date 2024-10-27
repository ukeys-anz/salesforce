/**
 * @description Test class for COBCaseStatusPathController
 * @author Jasmine Nguyen
 * @since 01/2023
 */
@isTest
public with sharing class COBCaseStatusPathControllerTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';
  private static final String DAON_FALLOUT_NO_MATCH_SUBJECT = 'ID Ops Assistance - Daon Fallout: NO_MATCH';
  private static String personaId = '0123456789';
  private static final Map<String, String> PERSONA_ID_VERIFICATION_TYPES = new Map<String, String>{
    '0123456789' => 'MANUAL'
  };

  private static Lib_MockProvider dmlRepoMock;
  private static Lib_MockProvider stravinskyApiRepoMock;
  private static Lib_MockProvider cobCaseRepoMock;
  private static Lib_MockProvider onboardingActionQueryMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    stravinskyApiRepoMock = Lib_MockProvider.forType(
      StravinskyAPIRepository.class
    );
    cobCaseRepoMock = Lib_MockProvider.forType(COBCaseRepository.class);
    onboardingActionQueryMock = Lib_MockProvider.forType(
      IDOpsQueryRepository.class
    );
  }

  static List<Id> cobPIDIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(COBPrimaryIDDocument__c.SObjectType)
  };

  static List<Id> cobAppsIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(CustomerOnboardingApplication__c.SObjectType)
  };

  static Case cobIdOpsCase = new Case(
    RecordTypeId = RTCase.idOpsAssistance,
    Status = COBCaseConstants.COB_DAON_FALLOUT_STATUS,
    Subject = DAON_FALLOUT_NO_MATCH_SUBJECT,
    PersonaId__c = FAKER.randomString(15),
    Status_Update_Error__c = 'Previous case status update error'
  );

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

  @isTest
  private static void testIDOpsUpdateStatusSuccessful() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    dmlRepoMock.mock('updateRecords', saveResults);
    onboardingActionQueryMock.mock('getCOBPIDRecordUsingCOA', cobPIDRec);
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    stravinskyApiRepoMock.mock('triggerTemporalCaseWorkflow', cobStage);

    cobCaseRepoMock.mock('queryCountOpenChildren', 0);

    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatus = COBCaseStatusPathController.updateStatus(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase,
      false
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('queryCountOpenChildren').isEmpty(),
      'queryCountOpenChildren should have been called.'
    );
    Assert.isFalse(
      stravinskyApiRepoMock.getHistories('triggerTemporalCaseWorkflow')
        .isEmpty(),
      'triggerTemporalCaseWorkflow should have been called.'
    );
    Assert.isFalse(
      dmlRepoMock.getHistories('updateRecords').isEmpty(),
      'updateRecords should have been called.'
    );

    Assert.isTrue(
      cobCaseUpdateStatus.isCaseUpdated,
      'Case should have been updated.'
    );
    Assert.areEqual(
      FAILED_REASON,
      cobCaseUpdateStatus.cobVerificationFailedReason,
      'Case Update Status\'s Verification Failed Reason should have been updated with: ' +
      FAILED_REASON
    );
  }

  @isTest
  private static void testIDOpsBlockUpdateFromUI() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };
    COBPrimaryIDDocument__c cobPIDRec = cobPIDRecord[0];
    dmlRepoMock.mock('updateRecords', saveResults);
    onboardingActionQueryMock.mock('getCOBPIDRecordUsingCOA', cobPIDRec);
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    stravinskyApiRepoMock.mock('triggerTemporalCaseWorkflow', cobStage);

    cobCaseRepoMock.mock('queryCountOpenChildren', 0);

    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        COBCaseConstants.COB_DAON_FALLOUT_STATUS,
        cobIdOpsCase,
        true
      );
      if (System.Label.BlockManualStatusUpdateIdOpsCase == 'true') {
        Assert.fail('Exception should be thrown');
      }
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }
  @isTest
  private static void testUpdateStatusNoPersonaIDException() {
    cobIdOpsCase.PersonaId__c = '';

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        COBCaseConstants.COB_DAON_FALLOUT_STATUS,
        cobIdOpsCase
      );
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testUpdateStatusValidationError() {
    cobIdOpsCase.Status = COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS;

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        COBCaseConstants.COB_DAON_FALLOUT_STATUS,
        cobIdOpsCase
      );
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testMakeTemporalCalloutError() {
    registerMocks();
    stravinskyApiRepoMock
      .mockException(
        'triggerTemporalCaseWorkflow',
        new CalloutException('Error calling out')
      );

    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase,
      true
    );
    Test.stopTest();

    Assert.isFalse(isCalloutSucccesful, 'Callout should have failed.');
    Assert.areEqual(
      2,
      stravinskyApiRepoMock.getHistories('triggerTemporalCaseWorkflow').size(),
      'Workflow should be triggered twice, once for the initial call and once for the retry.'
    );
    Assert.areEqual(
      'Error calling out',
      cobIdOpsCase.Status_Update_Error__c,
      'Case.Status_Update_Error__c should be updated with callout error'
    );
  }

  @isTest
  private static void testMakeTemporalCalloutSuccessful() {
    registerMocks();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    stravinskyApiRepoMock.mock('triggerTemporalCaseWorkflow', cobStage);

    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase,
      false
    );
    Test.stopTest();

    Assert.isTrue(isCalloutSucccesful, 'Callout should have been successful.');
    Assert.areEqual(
      true,
      String.isBlank(cobIdOpsCase.Status_Update_Error__c),
      'Status Update Error field should be blank.'
    );
    Assert.areEqual(
      1,
      stravinskyApiRepoMock.getHistories('triggerTemporalCaseWorkflow').size(),
      'Workflow should be triggered once only.'
    );
    Assert.areEqual(
      FAILED_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Case Onboarding Verification Failed Reason should have been updated with: ' +
      FAILED_REASON
    );
  }

  @isTest
  private static void testMakeTemporalCalloutWithouEndpoint() {
    cobIdOpsCase.Status = COBCaseConstants.COB_POTENTIAL_FRAUD_STATUS;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase,
      false
    );
    Test.stopTest();

    Assert.isTrue(isCalloutSucccesful, 'Callout should have been successful.');
  }

  @isTest
  private static void testHandleCaseUpdateSuccessful() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };
    dmlRepoMock.mock('updateRecords', saveResults);

    Exception ex;
    Test.startTest();
    try {
      COBCaseStatusPathController.handleCaseUpdate(cobIdOpsCase);
    } catch (Exception e) {
      ex = e;
      Assert.fail('Exception shouldn\'t be thrown');
    }
    Test.stopTest();

    Assert.isNull(ex, 'Case should have been updated.');
  }

  @isTest
  private static void testHandleCaseUpdateDMLError() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"success":false,"id":"5008r00000EhhODAAZ","errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"TestErrorMessage","fields":[]}]}'
      )
    };
    dmlRepoMock.mock('updateRecords', saveResults);

    Test.startTest();
    try {
      COBCaseStatusPathController.handleCaseUpdate(cobIdOpsCase);
      Assert.fail('Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryDaonFalloutStageAssistedSelfie() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ASSISTED_SELFIE;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      COBCaseConstants.COB_DAON_FALLOUT_STATUS
    );
    Assert.isNull(
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryEquifaxFalloutStageAssistedKyc() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ASSISTED_KYC;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS
    );
    Assert.isNull(
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryStageAckIdCheck() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ACK_ID_CHECK;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_ID_CHECK_OK_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      COBCaseConstants.COB_ID_CHECK_OK_STATUS
    );
    Assert.isNull(
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryStageTnc() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_TNC;
    cobStage.reason = FAILED_REASON;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_FAILED_OK_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      COBCaseConstants.COB_FAILED_OK_STATUS
    );
    Assert.areEqual(
      FAILED_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' + FAILED_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryConfirmedFraud() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_TERMINATED;
    cobStage.reason = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryConfirmedFraudWatchlistHit() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_TERMINATED;
    cobStage.reason = COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultFailedStatus() {
    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_FAILED_OK_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' + COBCaseConstants.COB_FAILED_OK_STATUS
    );
    Assert.areEqual(
      FAILED_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' + FAILED_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultConfirmedFraudStatus() {
    cobIdOpsCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultConfirmedFraudStatusWatchlistHit() {
    cobIdOpsCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
    cobIdOpsCase.Subject = COBCaseConstants.DAON_FALLOUT_WATCHLIST_HIT_SUBJECT;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' +
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultIDOpsDaonOK() {
    cobIdOpsCase.Status = COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS
    );
    Assert.isNull(
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalErrorNullErrorMessage() {
    Test.startTest();
    COBCaseStatusPathController.setCaseStatusFromTemporalError(
      cobIdOpsCase,
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      null
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseStatusPathController.CALLOUT_ERROR,
      cobIdOpsCase.Status_Update_Error__c,
      'Status Update Error field should have been updated with : ' +
      COBCaseStatusPathController.CALLOUT_ERROR
    );
  }
}
