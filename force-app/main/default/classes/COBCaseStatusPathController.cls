/**
 * @description controller class for cobCaseStatusPath lwc
 * @author Victor Wang
 * @since 12/2022
 */
public with sharing class COBCaseStatusPathController {
  private static final String CALLOUT_ERROR = 'Error occured during Temporal callout. Please contact your administrator';

  // Statuses with Callout API
  private static final List<String> COB_CASE_STATUSES_WITH_ENDPOINT = new List<String>{
    GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
    GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @return Boolean True - If case is successfully updated, False - if successfuly updated with a callout or DML error
   */
  @AuraEnabled
  public static Boolean updateStatus(String currentStatus, Case cobCase) {
    String validationError = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      cobCase
    );
    if (String.isEmpty(validationError) == false) {
      throwException(validationError);
    }

    Boolean isCalloutSucccesful = makeTemporalCallout(currentStatus, cobCase);
    Boolean isCaseUpdated = handleCaseUpdate(cobCase);
    return isCalloutSucccesful && isCaseUpdated;
  }

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @return Boolean Indicates whether the callout was successful or not
   */
  @TestVisible
  private static Boolean makeTemporalCallout(
    String currentStatus,
    Case cobCase
  ) {
    StravinskyAPIRepository temporalCaseWorkflowAPI = new StravinskyAPIRepository();

    cobCase.Status_Update_Error__c = ''; // Clear previous error to avoid confusion if this update is successful
    if (COB_CASE_STATUSES_WITH_ENDPOINT.contains(cobCase.Status) == false) {
      return true;
    }

    try {
      temporalCaseWorkflowAPI.triggerTemporalCaseWorkflow(cobCase);
    } catch (Exception e) {
      Logger.error(
        'Failed Temporal Callout to update status: ' + cobCase.Status,
        e
      );
      Logger.saveLog();

      cobCase.Status = currentStatus;
      cobCase.OnboardingVerificationFailedReason__c = '';
      cobCase.Status_Update_Error__c = String.isBlank(e.getMessage())
        ? CALLOUT_ERROR
        : e.getMessage();
    }

    return String.isBlank(cobCase.Status_Update_Error__c);
  }

  /**
   * @description Updates the case in scenarios where there is either: callout error or DML error or without error
   * @param cobCase Case with new fields data to be updated
   * @return Boolean True - If case is successfully updated and Temporal workflow was successfully triggered, False - if Temporal workflow callout failed or there was a DML error
   */
  @TestVisible
  private static Boolean handleCaseUpdate(Case cobCase) {
    Database.SaveResult updateResult = Database.update(cobCase, false); //cobCase may have call out error in Status_Update_Error__c field if the callout has failed

    if (updateResult.isSuccess() == false) {
      throwException(updateResult.getErrors()[0].getMessage());
    }

    return true;
  }

  /**
   * @description throws AuraHandledException with error message
   * @param errorMsg error message to use in the exception
   */
  private static void throwException(String errorMsg) {
    // AuraHandleException is quirky, setMessage() and constructor must be invoked otherwise "Script-thrown exception" is thrown instead of actual exception message
    AuraHandledException e = new AuraHandledException(errorMsg);
    e.setMessage(errorMsg);

    Logger.error('Failed to update COB case', e);
    Logger.saveLog();
    throw e;
  }
}
