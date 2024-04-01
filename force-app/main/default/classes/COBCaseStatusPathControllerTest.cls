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

  @testSetup
  static void setup() {
    Case cobIdOpsCase = new Case();
    cobIdOpsCase.RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID;
    cobIdOpsCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;
    cobIdOpsCase.PersonaId__c = FAKER.randomString(15);
    cobIdOpsCase.Status_Update_Error__c = 'Previous case status update error';
    insert cobIdOpsCase;

    Case cobFraudCheckCase = new Case();
    cobFraudCheckCase.RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID;
    cobFraudCheckCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;
    cobFraudCheckCase.PersonaId__c = FAKER.randomString(15);
    cobFraudCheckCase.Status_Update_Error__c = 'Previous case status update error';
    insert cobFraudCheckCase;
  }

  private static Case getCOBCase(String recordtype) {
    return [
      SELECT
        Id,
        Status,
        OnboardingVerificationFailedReason__c,
        Status_Update_Error__c,
        RecordTypeId,
        PersonaId__c
      FROM Case
      WHERE RecordTypeId = :recordtype
    ];
  }

  @isTest
  private static void testUpdateStatusWithoutEndpointSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS;

    Test.startTest();
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatus = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      true,
      cobCaseUpdateStatus.isCaseUpdated,
      'Case should have been updated.'
    );
    Assert.areEqual(
      GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
      updatedCobCase.Status,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
    Assert.isNull(
      cobCaseUpdateStatus.cobVerificationFailedReason,
      'Failed reason should be null.'
    );
  }

  @isTest
  private static void testFraudCheckUpdateStatusSuccessful() {
    Case cobFraudCheck = getCOBCase(GetHelpConstants.FRAUD_CHECK_RT_ID);
    cobFraudCheck.Status = GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS;

    Test.startTest();
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatus = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobFraudCheck
    );
    Test.stopTest();

    Case updatedCobFraudCheckCase = getCOBCase(
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );

    Assert.areEqual(
      true,
      cobCaseUpdateStatus.isCaseUpdated,
      'Case should have been updated.'
    );
    Assert.areEqual(
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
      updatedCobFraudCheckCase.Status,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      true,
      String.isBlank(updatedCobFraudCheckCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
    Assert.isNull(
      cobCaseUpdateStatus.cobVerificationFailedReason,
      'Failed reason should be null.'
    );
  }

  @isTest
  private static void testIDOpsUpdateStatusSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatus = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      true,
      cobCaseUpdateStatus.isCaseUpdated,
      'Case should have been updated.'
    );
    Assert.areEqual(
      GetHelpConstants.COB_FAILED_OK_STATUS,
      updatedCobCase.Status,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      FAILED_REASON,
      updatedCobCase.OnboardingVerificationFailedReason__c,
      'Case Onboarding Verification Failed Reason should have been updated with: ' +
      FAILED_REASON
    );
    Assert.areEqual(
      FAILED_REASON,
      cobCaseUpdateStatus.cobVerificationFailedReason,
      'Case Update Status\'s Verification Failed Reason should have been updated with: ' +
      FAILED_REASON
    );
    Assert.areEqual(
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
  }

  @isTest
  private static void testUpdateStatusNoPersonaIDException() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = FAILED_REASON;
    cobCase.PersonaId__c = '';

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception e) {
      Assert.areEqual(
        COBCaseStatusPathController.PERSONA_ID_ERROR,
        e.getMessage(),
        'Error message should be: ' +
        COBCaseStatusPathController.PERSONA_ID_ERROR
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testUpdateStatusValidationError() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_EQUIFAX_FAILED_STATUS;

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception e) {
      Assert.areEqual(
        'You are not allowed to change the status from \'Daon Fallout\' to \'Equifax Fallout\'.',
        e.getMessage(),
        'Error message should be: You are not allowed to change the status from \'Daon Fallout\' to \'Equifax Fallout\'.'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testMakeTemporalCalloutSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    Boolean isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      isCalloutSucccesful,
      'Callout should have been successful.'
    );
    Assert.areEqual(
      true,
      String.isBlank(cobCase.Status_Update_Error__c),
      'Status Update Error field should be blank.'
    );
  }

  @isTest
  private static void testHandleCaseUpdateSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    //Simulate succesfull callout
    cobCase.Status_Update_Error__c = '';

    Test.startTest();
    Boolean isCaseUpdated = COBCaseStatusPathController.handleCaseUpdate(
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      true,
      isCaseUpdated,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      GetHelpConstants.COB_FAILED_OK_STATUS,
      updatedCobCase.Status,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      FAILED_REASON,
      cobCase.OnboardingVerificationFailedReason__c,
      'Case Onboarding Verification Failed Reason should have been updated with: ' +
      FAILED_REASON
    );
    Assert.areEqual(
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
  }

  @isTest
  private static void testHandleCaseUpdateFailedCalloutError() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    //Simulate failed callout
    cobCase.Status_Update_Error__c = MOCK_ERROR;

    Test.startTest();
    Boolean isCaseUpdatedWithCalloutError = COBCaseStatusPathController.handleCaseUpdate(
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      MOCK_ERROR,
      updatedCobCase.Status_Update_Error__c,
      'Status Update Error field should have been updated with current callout status error.'
    );
  }

  @isTest
  private static void testHandleCaseUpdateFailedUpdate() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = FAKER.randomString(256);

    Test.startTest();
    try {
      COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains('Status: data value too large: '),
        'Error message should include \'Status: data value too large: \' .'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultDaonFalloutStageAssistedSelfie() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ASSISTED_SELFIE;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_DAON_FAILED_STATUS
    );
    Assert.isNull(
      cobCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultEquifaxFalloutStageAssistedKyc() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ASSISTED_KYC;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      cobCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS
    );
    Assert.isNull(
      cobCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultStageAckIdCheck() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_ACK_ID_CHECK;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
      cobCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS
    );
    Assert.isNull(
      cobCase.OnboardingVerificationFailedReason__c,
      'Failed reason should be null'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultStageTnc() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.STAGE_TNC;
    cobStage.retryReason = FAILED_REASON;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_FAILED_OK_STATUS,
      cobCase.Status,
      'The expected COB case status should be: ' +
      GetHelpConstants.COB_FAILED_OK_STATUS
    );
    Assert.areEqual(
      FAILED_REASON,
      cobCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' + FAILED_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalResultConfirmedFraud() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.status = GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS;

    Test.startTest();
    StravinskyAPIRepository.CxStageWrapper cobStage = new StravinskyAPIRepository.CxStageWrapper();
    cobStage.cxOnboardingStage = StravinskyAPIRepository.COB_UPDATED;
    COBCaseStatusPathController.setCaseStatusFromTemporalResult(
      cobCase,
      cobStage
    );
    Test.stopTest();

    Assert.areEqual(
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS,
      cobCase.Status,
      'The COB case status should remain: ' +
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    );
    Assert.areEqual(
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON,
      cobCase.OnboardingVerificationFailedReason__c,
      'Failed reason should have been: ' +
      COBCaseStatusPathController.CONFIRMED_FRAUD_REASON
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalErrorShortErrorMessage() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    COBCaseStatusPathController.setCaseStatusFromTemporalError(
      cobCase,
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      MOCK_ERROR
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      String.isBlank(cobCase.OnboardingVerificationFailedReason__c),
      'Case Onboarding Verification Failed Reason should have been cleared'
    );
    Assert.areEqual(
      MOCK_ERROR,
      cobCase.Status_Update_Error__c,
      'Status Update Error field should have been updated with : ' + MOCK_ERROR
    );
    Assert.isTrue(
      cobCase.Status_Update_Error__c.length() <= 255,
      'Status Update Error field vlue length should have been <=255 '
    );
    Assert.areEqual(
      false,
      String.isBlank(cobCase.Status_Update_Error__c),
      'Status Update Error field should not be blank.'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalErrorLongErrorMessage() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    COBCaseStatusPathController.setCaseStatusFromTemporalError(
      cobCase,
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      FAKER.randomString(256)
    );
    Test.stopTest();

    Assert.areEqual(
      255,
      cobCase.Status_Update_Error__c.length(),
      'Status Update Error field value should have been updated with the first 255 charctewrs of the long error'
    );
  }

  @isTest
  private static void testSetCaseStatusFromTemporalErrorNullErrorMessage() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Test.startTest();
    COBCaseStatusPathController.setCaseStatusFromTemporalError(
      cobCase,
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      null
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseStatusPathController.CALLOUT_ERROR,
      cobCase.Status_Update_Error__c,
      'Status Update Error field should have been updated with : ' +
      COBCaseStatusPathController.CALLOUT_ERROR
    );
  }
}
