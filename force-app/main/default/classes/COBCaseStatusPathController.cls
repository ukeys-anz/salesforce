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
  private static final String PREVENT_DIRECT_UPDATE = 'Please review the document details in the PID screen and update the case status from there';
  private static final String PREVENT_PID_OVERRIDE = 'You have previous actioned {pidStatus} in the PID, please update the case status accordingly';
  private static final String PID_STATUS_KEY = '{pidStatus}';

  // Statuses with Callout API
  private static final List<String> COB_CASE_STATUSES_WITH_ENDPOINT = new List<String>{
    COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS,
    COBCaseConstants.COB_ID_CHECK_OK_STATUS,
    COBCaseConstants.COB_FAILED_OK_STATUS,
    COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  @TestVisible
  private static final Integer MAX_RETRY_COUNT = 3;
  private static final String RETRY_MESSAGE = 'Temporal Callout failed to update status: {0}. Attempting {1} auto-retry callout for a Case.';

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
   * @param updatingAssistanceCase flag to identify if method called from ID Ops Assistance Case directly
   * @return COBCaseUpdateStatus: isUpdated -  True - If case is successfully updated, False - if successfuly updated with a callout or DML error; cobVerificationFailedReason to compare on client side
   */
  public static COBCaseUpdateStatus updateStatus(
    String currentStatus,
    Case cobCase,
    Boolean updatingAssistanceCase
  ) {
    if (String.isEmpty(cobCase.PersonaId__c)) {
      throw CommonUtil.logAuraExceptionInfo(PERSONA_ID_ERROR, cobCase.Id);
    }

    String validationError = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      cobCase
    );
    if (String.isNotEmpty(validationError)) {
      throw CommonUtil.logAuraExceptionInfo(validationError, cobCase.Id);
    }

    validationError = validationAgentActionWithPID(
      currentStatus,
      cobCase,
      updatingAssistanceCase
    );
    if (String.isNotEmpty(validationError)) {
      throw CommonUtil.logAuraExceptionInfo(validationError, cobCase.Id);
    }

    Boolean isCalloutSucccesful = makeTemporalCallout(
      currentStatus,
      cobCase,
      1
    );
    handleCaseUpdate(cobCase);
    return new COBCaseUpdateStatus(
      isCalloutSucccesful,
      cobCase.OnboardingVerificationFailedReason__c
    );
  }

  private static String validationAgentActionWithPID(
    String currentStatus,
    Case cobCase,
    Boolean updatingAssistanceCase
  ) {
    Boolean allowCaseUpdate =
      updatingAssistanceCase &&
      cobCase.RecordTypeId == RTCase.idOpsAssistance &&
      currentStatus == COBCaseConstants.COB_DAON_FALLOUT_STATUS &&
      Label.BlockManualStatusUpdateIdOpsCase.equalsIgnoreCase('true');
    if (allowCaseUpdate == false) {
      return null;
    }
    COBPrimaryIDDocument__c pid = WORKFLOW_REPOSITORY.getCOBPIDRecordUsingCOA(
      cobCase.CustomerOnboardingApplication__c
    );
    String pidStatus = pid.Verification_Status__c;
    if (String.isEmpty(pidStatus)) {
      return PREVENT_DIRECT_UPDATE;
    }
    if (pidStatus == cobCase.Status) {
      return null;
    }
    return PREVENT_PID_OVERRIDE.replace(PID_STATUS_KEY, pidStatus);
  }

  /**
   * @description Trigger Temporal workflow based on case status
   * @param currentStatus Current status to revert to if update fails
   * @param cobCase Case with new fields data to be updated
   * @param attempCount Number of attempts to retry the callout
   * @return Boolean Indicates whether the callout was successful or not
   */
  @TestVisible
  private static Boolean makeTemporalCallout(
    String currentStatus,
    Case cobCase,
    Integer attempCount
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
      if (attempCount <= MAX_RETRY_COUNT) {
        Map<Integer, String> attempCountSuffix = new Map<Integer, String>{
          1 => '1st',
          2 => '2nd',
          3 => '3rd'
        };
        Logger.info(
          String.format(
            RETRY_MESSAGE,
            new List<String>{
              cobCase.Status,
              attempCountSuffix.get(attempCount)
            }
          ),
          cobCase.Id,
          e
        );
        attempCount++;
        return makeTemporalCallout(currentStatus, cobCase, attempCount);
      }
      Logger.info(
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
    try {
      //We need to update the Case record since cobCase may have Callout Error in the Status_Update_Error__c field
      // in case of the callout has failed. The case should have only the set of relevant fields
      DML_REPOSITORY.doUpdate(
        new Case(
          Id = cobCase.Id,
          Status = cobCase.Status,
          OnboardingVerificationFailedReason__c = cobCase.OnboardingVerificationFailedReason__c,
          Status_Update_Error__c = cobCase.Status_Update_Error__c
        )
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
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
