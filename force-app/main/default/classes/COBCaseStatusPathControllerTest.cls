/**
 * @description Test class for COBCaseStatusPathController
 * @author Jasmine Nguyen
 * @since 01/2023
 */
@isTest
public with sharing class COBCaseStatusPathControllerTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String MOCK_ERROR = 'Current case status update error';
  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';
  private static final String DAON_FALLOUT_NO_MATCH_SUBJECT = 'ID Ops Assistance - Daon Fallout: NO_MATCH';

  private static Lib_MockProvider dmlRepoMock;
  private static Lib_MockProvider stravinskyApiRepoMock;
  private static Lib_MockProvider cobCaseRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    stravinskyApiRepoMock = Lib_MockProvider.forType(
      StravinskyAPIRepository.class
    );
    cobCaseRepoMock = Lib_MockProvider.forType(COBCaseRepository.class);
  }

  static Case cobIdOpsCase = new Case(
    RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
    Status = GetHelpConstants.COB_DAON_FAILED_STATUS,
    Subject = DAON_FALLOUT_NO_MATCH_SUBJECT,
    PersonaId__c = FAKER.randomString(15),
    Status_Update_Error__c = 'Previous case status update error'
  );

  @isTest
  private static void testIDOpsUpdateStatusSuccessful() {
    registerMocks();
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
      TestUtil.getMockSaveResult(
        '{"id":"5008r00000EhhODAAZ","success":true,"errors":[]}'
      )
    };
    dmlRepoMock.mock('updateRecords', saveResults);

    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    stravinskyApiRepoMock.mock('triggerTemporalCaseWorkflow', cobStage);

    cobCaseRepoMock.mock('queryCountOpenChildren', 0);

    cobIdOpsCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatus = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobIdOpsCase
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
  private static void testUpdateStatusNoPersonaIDException() {
    cobIdOpsCase.PersonaId__c = '';

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
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
    cobIdOpsCase.Status = GetHelpConstants.COB_EQUIFAX_FAILED_STATUS;

    Exception resultException;
    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
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

    cobIdOpsCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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

    cobIdOpsCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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
    cobIdOpsCase.Status = GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_DAON_FAILED_STATUS
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
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS
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
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS
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
      GetHelpConstants.COB_FAILED_OK_STATUS,
      cobIdOpsCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_FAILED_OK_STATUS
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
    cobStage.reason = COBCaseStatusPathController.CONFIRMED_FRAUD_REASON;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultRetryConfirmedFraudWatchlistHit() {
    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_TERMINATED;
    cobStage.reason = COBCaseStatusPathController.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseStatusPathController.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseStatusPathController.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultFailedStatus() {
    cobIdOpsCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
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
      GetHelpConstants.COB_FAILED_OK_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' + GetHelpConstants.COB_FAILED_OK_STATUS
    );
    Assert.areEqual(
      FAILED_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' + FAILED_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultConfirmedFraudStatus() {
    cobIdOpsCase.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = COBCaseStatusPathController.CONFIRMED_FRAUD_REASON;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' +
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultConfirmedFraudStatusWatchlistHit() {
    cobIdOpsCase.Status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;
    cobIdOpsCase.Subject = COBCaseStatusPathController.DAON_FALLOUT_WATCHLIST_HIT_SUBJECT;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should be: ' +
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseStatusPathController.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON,
      cobIdOpsCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseStatusPathController.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultIDOpsDaonOK() {
    cobIdOpsCase.Status = GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobIdOpsCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
      cobIdOpsCase.Status,
      'The COB case status should remain: ' +
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS
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
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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
