/**
 * @description       : LWC Controller for manageOpsWorkflowApproval & manageOpsWorkflowReject
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 07-31-2024
 **/
@SuppressWarnings('PMD.LocalVariableNamingConventions')
public with sharing class ManageOpsWorkflowActionController {
  private static final String POTENTIALFRAUD = 'Potential Fraud';
  private static final String PIN_RECOVERY_RECORDTYPE = 'PIN_Recovery';
  private static final String SELFIE_RECOVERY_RECORDTYPE = 'Selfie_Recovery';
  private static final String ERROR_STRING = 'Error occurred while';
  private static final String COMMENTS_ERROR = ' - creating comments';
  private static final String CASE_UPDATE_ERROR = ' - updating case status';
  private static final String PID_UPDATE_ERROR = ' - updating COB Primary ID Document record';
  private static final String FAILURE_MESSAGE = 'Error occurred while creating comments, updating COB Primary ID Document record & updating case status';
  private static final String ONBOARDING_FALLOUT_APPROVAL_REJECTION = 'OnboardingFalloutApprovalRejection';
  private static final String PIN_RECOVERY_APPROVAL_REJECTION = 'PinRecoveryApprovalRejection';
  private static final String SELFIE_RECOVERY_APPROVAL_REJECTION = 'SelfieRecoveryApprovalRejection';
  private static final String CASE_UPDATE_SUCCESS = 'Case status updated successfully';
  private static final String UPDATE_ERROR_PIN = 'Error occurred while updating case and creating comments';

  private static final IDOpsQueryRepository WORKFLOW_REPOSITORY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description update Case Status using Ribbon flow, perform API call, case comments creation & update PID
   * @param idValue idValue
   * @param manageOpsRequest ManageOpsWorkflowRequestModel manageOpsRequest coming from LWC as a string
   * @param cobId COBPrimaryIDDocument__c record Id
   * @param status status from LWC
   * @param failedReason failedReason value from LWC
   * @return Map<String, String> status & response message map
   **/
  @AuraEnabled
  public static Map<String, String> updateCaseStatusOnboarding(
    String idValue,
    ManageOpsWorkflowRequestModel manageOpsRequest,
    String cobId,
    String status,
    String failedReason
  ) {
    Map<String, String> response = new Map<String, String>();
    Boolean isRibbionFlowSuccess = false;
    String failedMessage;

    COBPrimaryIDDocument__c cobPidRecords = WORKFLOW_REPOSITORY.getCOBPIDRecord(
      cobId
    );
    Case caseRecords = WORKFLOW_REPOSITORY.getCaseRecord(
      manageOpsRequest.case_id
    );

    if (status != POTENTIALFRAUD) {
      response = makeAegisCalloutForOnboarding(manageOpsRequest, idValue);
    }

    if (
      response.get(TFMConstants.STATUS_WITH_SMALL_S) == TFMConstants.ERRORSTATUS
    ) {
      failedMessage = response.get(TFMConstants.RESPONSE_MESSAGE);
      status = cobPidRecords.Verification_Status__c;
    }

    setCOBPIDRecord(failedMessage, failedReason, status, cobPidRecords);
   
    SystemModeActions systemAction = new SystemModeActions(
      'ManageOpsWorkflowActionController',
      'updateCaseStatusOnboarding'
    );
    Boolean updateResultCOBPIDFailed = systemAction.updateRecords(new List<COBPrimaryIDDocument__c>{ cobPidRecords }, 'COBPrimaryIDDocument__c');

    Logger.info(
      'Verified By ' +
        UserInfo.getName() +
        ' Verification Date Time ' +
        System.now() +
        ' Verification Status ' +
        status +
        ', Verification Failed Reason ' +
        failedReason +
        ', Failed Message ' +
        failedMessage
    );
    Logger.saveLog();

    if (
      response.get(TFMConstants.STATUS_WITH_SMALL_S) == TFMConstants.ERRORSTATUS
    ) {
      return response;
    }

    CaseComment CaseCommentObj = setCaseComment(
      manageOpsRequest.case_id,
      manageOpsRequest.case_comments
    );

    List<Database.SaveResult> createdCaseComments = DML_REPOSITORY.insertRecords(
      new List<CaseComment>{ CaseCommentObj },
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );

    if (createdCaseComments[0].isSuccess() && !updateResultCOBPIDFailed) {
      isRibbionFlowSuccess = callRibbionFlowForOnboarding(
        failedReason,
        status,
        caseRecords
      );
    }

    return setResponseForOnboarding(
      isRibbionFlowSuccess,
      createdCaseComments[0].isSuccess(),
      !updateResultCOBPIDFailed
    );
  }
  /**
   * @description making callout to update aegis
   * @param manageOpsRequest ManageOpsWorkflowRequestModel instance
   * @param idValue idValue
   * @return Map<String,String> map
   **/
  @TestVisible
  private static Map<String, String> makeAegisCalloutForOnboarding(
    ManageOpsWorkflowRequestModel manageOpsRequest,
    String idValue
  ) {
    return OnboardingUtility.updateCaseStatusAPI(
      idValue,
      manageOpsRequest,
      ONBOARDING_FALLOUT_APPROVAL_REJECTION
    );
  }

  /**
   * @description call Ribbion flow to update Case
   * @param failedReason failedReason
   * @param status status
   * @param caseRecords Case
   * @return Boolean cobCaseUpdateStatusObj.isCaseUpdated
   **/
  @TestVisible
  private static Boolean callRibbionFlowForOnboarding(
    String failedReason,
    String status,
    Case caseRecords
  ) {
    COBCaseStatusPathController.COBCaseUpdateStatus cobCaseUpdateStatusObj = new COBCaseStatusPathController.COBCaseUpdateStatus();
    cobCaseUpdateStatusObj.isCaseUpdated = false;
    caseRecords.OnboardingVerificationFailedReason__c = failedReason != null
      ? failedReason
      : caseRecords.OnboardingVerificationFailedReason__c;
    caseRecords.Status = status != null ? status : caseRecords.Status;
    try {
      cobCaseUpdateStatusObj = COBCaseStatusPathController.updateStatus(
        caseRecords.Status,
        caseRecords
      );
    } catch (Exception e) {
      return cobCaseUpdateStatusObj.isCaseUpdated;
    }
    return cobCaseUpdateStatusObj.isCaseUpdated;
  }

  /**
   * @description making callout to update aegis
   * @param isRibbionFlowSuccess isRibbionFlowSuccess
   * @param isCaseCommentCreated boolean value
   * @param isCOBPIDRecordUpdated boolean value
   * @return Map<String,String> map
   **/

  @TestVisible
  private static Map<String, String> setResponseForOnboarding(
    Boolean isRibbionFlowSuccess,
    Boolean isCaseCommentCreated,
    Boolean isCOBPIDRecordUpdated
  ) {
    Map<String, String> response = new Map<String, String>();
    String partialMsg = ERROR_STRING;
    if (isRibbionFlowSuccess && isCaseCommentCreated && isCOBPIDRecordUpdated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.SUCCESS);
      response.put(TFMConstants.RESPONSE_MESSAGE, CASE_UPDATE_SUCCESS);
    } else if (
      !isCaseCommentCreated &&
      !isCOBPIDRecordUpdated &&
      !isRibbionFlowSuccess
    ) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.ERRORSTATUS);
      partialMsg = FAILURE_MESSAGE;
    } else if (!isCaseCommentCreated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.WARNING);
      partialMsg += COMMENTS_ERROR;
    } else if (!isCOBPIDRecordUpdated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.WARNING);
      partialMsg += PID_UPDATE_ERROR;
    } else if (!isRibbionFlowSuccess) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.WARNING);
      partialMsg += CASE_UPDATE_ERROR;
    }
    response.put(
      TFMConstants.RESPONSE_MESSAGE,
      response.get(TFMConstants.STATUS_WITH_SMALL_S) == TFMConstants.SUCCESS
        ? response.get(TFMConstants.RESPONSE_MESSAGE)
        : partialMsg
    );
    return response;
  }
  /**
   * @description update Case Status for Pin & Selfie recovery flow
   * @param idValue idValue
   * @param manageOpsRequest ManageOpsWorkflowRequestModel manageOpsRequest coming from LWC as a string
   * @param status status from LWC
   * @return Map<String, String> status & response message map
   **/
  @AuraEnabled
  public static Map<String, String> updateCaseStatusPinAndSelfie(
    String idValue,
    ManageOpsWorkflowRequestModel manageOpsRequest,
    String status
  ) {
    Map<String, String> response = new Map<String, String>();
    Boolean isCaseUpdated = false;
    Boolean isCaseCommentCreated = false;
    String statusUpdateError;
    Case caseRecords = WORKFLOW_REPOSITORY.getCaseRecord(
      manageOpsRequest.case_id
    );
    response = makeAegisCalloutForPinAndSelfie(
      idValue,
      manageOpsRequest,
      caseRecords
    );

    if (
      response.get(TFMConstants.STATUS_WITH_SMALL_S) == TFMConstants.ERRORSTATUS
    ) {
      statusUpdateError = response.get(TFMConstants.RESPONSE_MESSAGE);
      status = caseRecords.status;
    }
    setCaseRecord(caseRecords, status, statusUpdateError);
    List<Database.SaveResult> updatedCaseRecord = DML_REPOSITORY.updateRecords(
      new List<Case>{ caseRecords },
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
    if (
      response.get(TFMConstants.STATUS_WITH_SMALL_S) == TFMConstants.ERRORSTATUS
    ) {
      return response;
    }
    CaseComment CaseCommentObj = setCaseComment(
      caseRecords.Id,
      manageOpsRequest.case_comments
    );
    List<Database.SaveResult> updatedCaseCommentsRecords = DML_REPOSITORY.insertRecords(
      new List<CaseComment>{ CaseCommentObj },
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
    return setResponseForPinAndSelfie(
      updatedCaseRecord[0].isSuccess(),
      updatedCaseCommentsRecords[0].isSuccess()
    );
  }

  /**
   * @description making callout for aegis portal
   * @param idValue idValue
   * @param manageOpsRequest manageOpsRequest
   * @param caseRecords caseRecords
   * @return Map<String,String> map
   **/
  @TestVisible
  private static Map<String, String> makeAegisCalloutForPinAndSelfie(
    String idValue,
    ManageOpsWorkflowRequestModel manageOpsRequest,
    Case caseRecords
  ) {
    Map<String, String> responseMap = new Map<String, String>();
    if (caseRecords.RecordType.DeveloperName == PIN_RECOVERY_RECORDTYPE) {
      responseMap = OnboardingUtility.updateCaseStatusAPI(
        idValue,
        manageOpsRequest,
        PIN_RECOVERY_APPROVAL_REJECTION
      );
    } else if (
      caseRecords.RecordType.DeveloperName == SELFIE_RECOVERY_RECORDTYPE
    ) {
      responseMap = OnboardingUtility.updateCaseStatusAPI(
        idValue,
        manageOpsRequest,
        SELFIE_RECOVERY_APPROVAL_REJECTION
      );
    }
    return responseMap;
  }

  /**
   * @description making callout for aegis portal
   * @param isCaseUpdated isCaseUpdated
   * @param isCaseCommentCreated isCaseCommentCreated
   * @return Map<String,String> map
   **/
  @TestVisible
  private static Map<String, String> setResponseForPinAndSelfie(
    Boolean isCaseUpdated,
    Boolean isCaseCommentCreated
  ) {
    Map<String, String> response = new Map<String, String>();
    String partialMsg = ERROR_STRING;
    if (isCaseUpdated && isCaseCommentCreated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.SUCCESS);
      partialMsg = CASE_UPDATE_SUCCESS;
    } else if (!isCaseUpdated && !isCaseCommentCreated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.ERRORSTATUS);
      partialMsg = UPDATE_ERROR_PIN;
    } else if (!isCaseUpdated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.WARNING);
      partialMsg += CASE_UPDATE_ERROR;
    } else if (!isCaseCommentCreated) {
      response.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.WARNING);
      partialMsg += COMMENTS_ERROR;
    }
    response.put(TFMConstants.RESPONSE_MESSAGE, partialMsg);
    return response;
  }

  /**
   * @description case comments creation
   * @param caseId caseId
   * @param caseComments caseComments
   * @return caseComment case comments instance
   **/
  @TestVisible
  private static CaseComment setCaseComment(
    String caseId,
    String caseComments
  ) {
    CaseComment ccObj = new CaseComment();
    ccObj.ParentId = caseId;
    ccObj.CommentBody = caseComments;
    return ccObj;
  }

  /**
   * @description update PID record
   * @param failedMessage failedMessage
   * @param failedReason failedReason
   * @param status status from LWC
   * @param cobPIDRecord COBPrimaryIDDocument__c
   **/
  @TestVisible
  private static void setCOBPIDRecord(
    String failedMessage,
    String failedReason,
    String status,
    COBPrimaryIDDocument__c cobPIDRecord
  ) {
    cobPIDRecord.Verified_By__c = UserInfo.getName();
    cobPIDRecord.Verification_Date_Time__c = system.now();
    cobPIDRecord.Verification_Status__c = status;
    cobPIDRecord.Verification_Failed_Reason__c = failedReason != null
      ? failedReason
      : cobPIDRecord.Verification_Failed_Reason__c;
    cobPIDRecord.Failed_Message__c = failedMessage;
  }

  /**
   * @description create case obj
   * @param caseRecords case record
   * @param status status from LWC
   * @param statusUpdateError statusUpdateError
   **/
  @TestVisible
  private static void setCaseRecord(
    Case caseRecords,
    String status,
    String statusUpdateError
  ) {
    caseRecords.Verified_By__c = UserInfo.getUserId();
    caseRecords.Verified_Date__c = System.now();
    caseRecords.Status = status;
    caseRecords.Status_Update_Error__c = statusUpdateError;
  }
}