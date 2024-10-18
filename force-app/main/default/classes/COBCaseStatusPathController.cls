/**
 * @description controller class for cobCaseStatusPath lwc
 * @author Victor Wang
 * @since 12/2022
 */
public with sharing class COBCaseStatusPathController {
  private static final StravinskyAPIRepository STRAVINSKY_REPO = (StravinskyAPIRepository) Lib_InstanceProvider.forType(
    StravinskyAPIRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final IDOpsQueryRepository WORKFLOW_REPOSITORY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );

  @TestVisible
  private static final String CALLOUT_ERROR = 'Error occured during Temporal callout. Please contact your administrator';
  @TestVisible
  private static final String PERSONA_ID_ERROR = 'Persona ID is missing on a case. Please check again.';

  // Statuses with Callout API
  private static final List<String> COB_CASE_STATUSES_WITH_ENDPOINT = new List<String>{
    COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS,
    COBCaseConstants.COB_ID_CHECK_OK_STATUS,
    COBCaseConstants.COB_FAILED_OK_STATUS,
    COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @return COBCaseUpdateStatus: isUpdated -  True - If case is successfully updated, False - if successfuly updated with a callout or DML error; cobVerificationFailedReason to compare on client side
   */
  @AuraEnabled
  public static COBCaseUpdateStatus updateStatus(
    String currentStatus,
    Case cobCase
  ) {
    return updateStatus(currentStatus, cobCase, true);
  }

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @param isAgentUpdateStatus flag to identify if method called from UI or not
   * @return COBCaseUpdateStatus: isUpdated -  True - If case is successfully updated, False - if successfuly updated with a callout or DML error; cobVerificationFailedReason to compare on client side
   */
  public static COBCaseUpdateStatus updateStatus(
    String currentStatus,
    Case cobCase,
    Boolean isAgentUpdateStatus
  ) {
    if (String.isEmpty(cobCase.PersonaId__c)) {
      throw CommonUtil.logAuraException(PERSONA_ID_ERROR);
    }

    String validationError = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      cobCase
    );
    if (String.isNotEmpty(validationError)) {
      throw CommonUtil.logAuraException(validationError);
    }
    if (
      isAgentUpdateStatus &&
      RTCase.idOpsAssistance == cobCase.RecordTypeid &&
      currentStatus == 'Daon Fallout'
    ) {
      String customerOnboardingApplicationId = cobCase.CustomerOnboardingApplication__c;
      COBPrimaryIDDocument__c cobPIDRecord = WORKFLOW_REPOSITORY.getCOBPIDRecordUsingCOA(
        customerOnboardingApplicationId
      );
      if (String.isEmpty(cobPIDRecord.Verification_Status__c)) {
        validationError = 'Please review the document details in the PID screen and update the case status from there';
      } else if (cobPIDRecord.Verification_Status__c != cobCase.Status) {
        validationError =
          'You have previous actioned ' +
          cobPIDRecord.Verification_Status__c +
          ' in the PID, please update the case status accordingly';
      }
      COBCaseUpdateStatus cobCaseUpdateStatusObj = new COBCaseUpdateStatus();
      cobCaseUpdateStatusObj.cobVerificationFailedReason = validationError;
      cobCaseUpdateStatusObj.isCaseUpdated = false;
      cobCaseUpdateStatusObj.isManualCaseUpdate = true;
      return cobCaseUpdateStatusObj;
    }

    Boolean isCalloutSucccesful = makeTemporalCallout(
      currentStatus,
      cobCase,
      true
    );
    handleCaseUpdate(cobCase);
    return new COBCaseUpdateStatus(
      isCalloutSucccesful,
      cobCase.OnboardingVerificationFailedReason__c
    );
  }

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @param retryOnFail True to retry on failure, False - no retry on failure
   * @return Boolean Indicates whether the callout was successful or not
   */
  @TestVisible
  private static Boolean makeTemporalCallout(
    String currentStatus,
    Case cobCase,
    Boolean retryOnFail
  ) {
    cobCase.Status_Update_Error__c = ''; // Clear previous error to avoid confusion if this update is successful
    if (COB_CASE_STATUSES_WITH_ENDPOINT.contains(cobCase.Status) == false) {
      return true;
    }

    try {
      StravinskyAPIRepository.CxStageWrapper cobStage = STRAVINSKY_REPO.triggerTemporalCaseWorkflow(
        cobCase
      );
      setCaseStatusFromTemporalResult(cobCase, cobStage);
    } catch (Exception e) {
      if (retryOnFail) {
        Logger.info(
          'Temporal Callout failed to update status: ' +
            cobCase.Status +
            '. Attempting auto-retry callout for Case ' +
            cobCase.Id,
          e
        );
        return makeTemporalCallout(currentStatus, cobCase, false);
      }
      Logger.error(
        'Temporal Callout failed to update status: ' +
          cobCase.Status +
          ' for Case ' +
          cobCase.Id,
        e
      );
      Logger.saveLog();

      setCaseStatusFromTemporalError(cobCase, currentStatus, e.getMessage());
    }

    return String.isBlank(cobCase.Status_Update_Error__c);
  }

  /**
   * @description Sets the Case status according to expected onboarding stage or status
   * @param cobCase Case to update the status field
   * @param cobStage COB expected Onbording stage and Onboarding Verification Failed Reason in case it's STAGE_TNC
   */
  @TestVisible
  private static void setCaseStatusFromTemporalResult(
    Case cobCase,
    StravinskyAPIRepository.CxStageWrapper cobStage
  ) {
    if (cobStage.cxOnboardingStage != StravinskyAPIRepository.COB_UPDATED) {
      setCaseStatusFromCxStage(cobCase, cobStage);
      return;
    }

    if (cobCase.Status != COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS) {
      return;
    }

    cobCase.OnboardingVerificationFailedReason__c = cobCase.Subject
        ?.contains(COBCaseConstants.DAON_FALLOUT_WATCHLIST_HIT_SUBJECT)
      ? COBCaseConstants.CONFIRMED_FRAUD_SELFIE_WATCHLIST_REASON
      : COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
  }

  @TestVisible
  private static void setCaseStatusFromCxStage(
    Case cobCase,
    StravinskyAPIRepository.CxStageWrapper cobStage
  ) {
    Map<String, String> statusByRetryStageStatusMap = new Map<String, String>{
      StravinskyAPIRepository.STAGE_ASSISTED_SELFIE => COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      StravinskyAPIRepository.STAGE_ASSISTED_KYC => COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      StravinskyAPIRepository.STAGE_ACK_ID_CHECK => COBCaseConstants.COB_ID_CHECK_OK_STATUS,
      StravinskyAPIRepository.STAGE_TNC => COBCaseConstants.COB_FAILED_OK_STATUS,
      StravinskyAPIRepository.STAGE_TERMINATED => COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    };

    cobCase.Status = statusByRetryStageStatusMap.get(
      cobStage.cxOnboardingStage
    );
    cobCase.OnboardingVerificationFailedReason__c = cobStage.reason;
  }

  /**
   * @description Sets the Case status and Status update error if exist up to 255 characters
   * @param cobCase Case to update the status field and status update error
   * @param currentStatus Current status to revert to if update fails
   * @param errorMessage Error message from response
   */
  @TestVisible
  private static void setCaseStatusFromTemporalError(
    Case cobCase,
    String currentStatus,
    String errorMessage
  ) {
    cobCase.Status = currentStatus;
    cobCase.OnboardingVerificationFailedReason__c = '';
    cobCase.Status_Update_Error__c = String.isNotBlank(errorMessage)
      ? errorMessage
      : CALLOUT_ERROR;
  }

  /**
   * @description Updates the case in scenarios where there is either: callout error (case will hold the error reason) or DML error or without error
   * @param cobCase Case with new fields data to be updated
   */
  @TestVisible
  private static void handleCaseUpdate(Case cobCase) {
    //remove unneeded field
    cobCase = new Case(
      Id = cobCase.Id,
      Status = cobCase.Status,
      OnboardingVerificationFailedReason__c = cobCase.OnboardingVerificationFailedReason__c,
      Status_Update_Error__c = cobCase.Status_Update_Error__c
    );
    //We need to update the Case record since cobCase may have Callout Error in the Status_Update_Error__c field in case of the callout has failed
    List<Database.SaveResult> updateResults = DML_REPOSITORY.updateRecords(
      new List<Case>{ cobCase },
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );

    Database.SaveResult updateResult = updateResults[0]; //Since it's partial update, there will always be a result
    if (updateResult.isSuccess() == false) {
      throw new AuraHandledException(updateResult.getErrors()[0].getMessage());
    }
  }

  /**
   * @description Wrapper class for COB Case Update Status w/o Verification Failed Reason
   */
  public class COBCaseUpdateStatus {
    /**
     * @description isCaseUpdated
     */
    @AuraEnabled
    public Boolean isCaseUpdated { get; set; }
    /**
     * @description cobVerificationFailedReason
     */
    @AuraEnabled
    public String cobVerificationFailedReason { get; set; }

    /**
     * @description isManualCaseUpdate
     */
    @AuraEnabled
    public Boolean isManualCaseUpdate { get; set; }

    /**
     * @description Constructor with args, for server-side Apex -> client-side JavaScript
     * @param isCaseUpdated
     * @param cobVerificationFailedReason
     */
    public COBCaseUpdateStatus(
      Boolean isCaseUpdated,
      String cobVerificationFailedReason
    ) {
      this.isCaseUpdated = isCaseUpdated;
      this.cobVerificationFailedReason = cobVerificationFailedReason;
    }

    /**
     * @description No-arg constructor, for client-side -> server-side
     */
    public COBCaseUpdateStatus() {
    }
  }
}
