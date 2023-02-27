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
    Case cobCase = new Case();
    cobCase.RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID;
    cobCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;
    cobCase.PersonaId__c = faker.randomString(15);
    cobCase.Status_Update_Error__c = 'Previous case status update error';
    insert cobCase;
  }

  private static Case getCOBCase(String recordtype) {
    return [
      SELECT
        Id,
        Status,
        OnboardingVerificationFailedReason__c,
        Status_Update_Error__c
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

    Boolean isCaseUpdated = false;
    Test.startTest();
    try {
      isCaseUpdated = COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception ce) {
      Assert.areEqual(
        false,
        isCaseUpdated,
        'Case status should not have been updated.'
      );
      Assert.areEqual(
        true,
        ce.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
        'DML exception should have been thrown.'
      );
    }
    Test.stopTest();
  }

  @isTest
  private static void testUpdateStatusDMLException() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;

    Boolean isCaseUpdated = false;
    Test.startTest();
    try {
      isCaseUpdated = COBCaseStatusPathController.updateStatus(
        GetHelpConstants.COB_DAON_FAILED_STATUS,
        cobCase
      );
    } catch (Exception e) {
      Assert.areEqual(
        false,
        isCaseUpdated,
        'Case status should not have been updated.'
      );
      Assert.areEqual(
        '\'Onboarding Verification Failed Reason\' field cannot be empty for status \'Failed (OK)\'',
        e.getMessage(),
        'DML exception should have been thrown.'
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
  private static void testHandleCaseUpdatedDMLError() {
    Case cobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);
    cobCase.Status = GetHelpConstants.COB_FAILED_OK_STATUS;

    //Simulate succesfull callout
    cobCase.Status_Update_Error__c = '';

    Test.startTest();
    Boolean isCaseUpdatedWithDMLError = COBCaseStatusPathController.handleCaseUpdate(
      cobCase
    );
    Test.stopTest();

    Case updatedCobCase = getCOBCase(GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID);

    Assert.areEqual(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      updatedCobCase.Status,
      'Case status should have been remained.'
    );
    Assert.areEqual(
      '\'Onboarding Verification Failed Reason\' field cannot be empty for status \'Failed (OK)\'',
      updatedCobCase.Status_Update_Error__c,
      'Status Update Error field should updated with current DML status error.'
    );
  }
}
