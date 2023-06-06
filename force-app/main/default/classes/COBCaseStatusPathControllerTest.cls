/**
 * @description Test class for COBCaseStatusPathController
 * @author Jasmine Nguyen
 * @since 01/2023
 */
@isTest
public with sharing class COBCaseStatusPathControllerTest {
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    Case cobIdOpsCase = new Case();
    cobIdOpsCase.RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID;
    cobIdOpsCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;
    cobIdOpsCase.PersonaId__c = faker.randomString(15);
    cobIdOpsCase.Status_Update_Error__c = 'Previous case status update error';
    insert cobIdOpsCase;

    Case cobFraudCheckCase = new Case();
    cobFraudCheckCase.RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID;
    cobFraudCheckCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;
    cobFraudCheckCase.PersonaId__c = faker.randomString(15);
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
        RecordTypeId
      FROM Case
      WHERE RecordTypeId = :recordtype
    ];
  }

  @isTest
  private static void testUpdateStatusWithoutEndpointSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS;

    Test.startTest();
    Boolean isCaseUpdated = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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
      GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
      updatedCobCase.Status,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
  }

  @isTest
  private static void testFraudCheckUpdateStatusSuccessful() {
    Case cobFraudCheck = getCOBCase(GetHelpConstants.FRAUD_CHECK_RT_ID);
    cobFraudCheck.Status = GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS;

    Test.startTest();
    Boolean isCaseUpdated = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobFraudCheck
    );
    Test.stopTest();

    Case updatedCobFraudCheckCase = getCOBCase(
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );

    Assert.areEqual(
      true,
      isCaseUpdated,
      'Case status should have been updated.'
    );
    Assert.areEqual(
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
      updatedCobFraudCheckCase.Status,
      'Case status should have been updated.'
    );
  }

  @isTest
  private static void testUpdateStatusSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = 'Selfie fail - selfie image is not clear enough to match';

    Test.startTest();
    Boolean isCaseUpdated = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
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
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
  }

  @isTest
  private static void testUpdateStatusCalloutException() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;

    StravinskyAPIRepository.throwException = true; // Simulate a callout exception

    Test.startTest();
    Boolean isCaseUpdated = COBCaseStatusPathController.updateStatus(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase
    );
    Test.stopTest();

    Assert.areEqual(
      false,
      isCaseUpdated,
      'Callout should not have been successful.'
    );

    Assert.areEqual(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      cobCase.Status,
      'Case status should not have been updated.'
    );

    Assert.areEqual(
      false,
      String.isBlank(cobCase.Status_Update_Error__c),
      'Status Update Error field should not be blank.'
    );

    Assert.areNotEqual(
      'Previous case status update error',
      cobCase.Status_Update_Error__c,
      'Status Update Error field should be updated.'
    );
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
    cobCase.OnboardingVerificationFailedReason__c = 'Selfie fail - selfie image is not clear enough to match';

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
  private static void testMakeTemporalCalloutException() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    StravinskyAPIRepository.throwException = true; // Simulate a callout exception

    Boolean isCalloutSucccesful = false;
    Test.startTest();
    try {
      isCalloutSucccesful = COBCaseStatusPathController.makeTemporalCallout(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception ce) {
      Assert.areEqual(
        false,
        isCalloutSucccesful,
        'Callout should not have been successful.'
      );
      Assert.areEqual(
        false,
        String.isBlank(cobCase.Status_Update_Error__c),
        'Status Update Error field should not be blank.'
      );
      Assert.areNotEqual(
        'Previous case status update error',
        cobCase.Status_Update_Error__c,
        'Status Update Error field should be updated.'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testHandleCaseUpdateSuccessful() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = 'Selfie fail - selfie image is not clear enough to match';

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
      true,
      String.isBlank(updatedCobCase.Status_Update_Error__c),
      'Case status update error should have been cleared.'
    );
  }

  @isTest
  private static void testHandleCaseUpdateFailedCalloutError() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;
    cobCase.OnboardingVerificationFailedReason__c = 'Selfie fail - selfie image is not clear enough to match';

    //Simulate failed callout
    cobCase.Status_Update_Error__c = 'Current case status update error';

    Test.startTest();
    Boolean isCaseUpdatedWithCalloutError = COBCaseStatusPathController.handleCaseUpdate(
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      'Current case status update error',
      updatedCobCase.Status_Update_Error__c,
      'Status Update Error field should updated with current callout status error.'
    );
  }

  @isTest
  private static void testHandleCaseUpdateFailedUpdate() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    Faker faker = new Faker('AU');
    cobCase.Status = faker.randomString(256);

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
}
