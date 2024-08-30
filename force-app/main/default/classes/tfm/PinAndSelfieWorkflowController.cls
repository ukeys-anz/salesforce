/**
 * @description       : LWC Controller for PinAndSelfieWorkflow
 * @author            : Hinduja - TFM Squad
 * @group             :
 * @last modified on  : 08-09-2024
 **/
public with sharing class PinAndSelfieWorkflowController {
  private static final IDOpsQueryRepository WORKFLOW_QUERY_REPOSITORY = (IDOpsQueryRepository) Lib_InstanceProvider.forType(
    IDOpsQueryRepository.class
  );
  /**
   * @description gets the data from PID record
   * @param recordId case recordId
   * @return OnboardingWorkflowWrapper
   **/
  @AuraEnabled
  public static OnboardingWorkflowWrapper performOnboardingOperations(
    Id recordId
  ) {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    Case caseRecord;
    try {
      caseRecord = WORKFLOW_QUERY_REPOSITORY.getCaseRecord(recordId);
    } catch (Exception ex) {
      workflowDetails.responseMsg = TFMConstants.ERROR_OCCURRED;
      return workflowDetails;
    }

    workflowDetails = populateWorkflowDetails(caseRecord);

    fetchOnboardingDocuments(workflowDetails);
    apiCallToFetchImages(workflowDetails);
    return workflowDetails;
  }

  /**
   * @description form FileType Data
   * @param caseRecord case record
   * @return OnboardingWorkflowWrapper wrapper details
   **/
  public static OnboardingWorkflowWrapper populateWorkflowDetails(
    Case caseRecord
  ) {
    Map<String, String> getChallengeIdVsType = new Map<String, String>{
      'REG_CHALLENGE' => TFMConstants.SELFIE_RECOVERY_CHALLENGE_TYPE,
      'AUTH_REQUEST' => TFMConstants.SELFIE_RECOVERY_AUTH_REQUEST
    };
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    workflowDetails.caseId = caseRecord.Id;
    workflowDetails.idxChallengeType = getChallengeIdVsType.get(
      caseRecord.Daon_Challenge_Type__c
    );
    if (!getChallengeIdVsType.containsKey(caseRecord.Daon_Challenge_Type__c)) {
      workflowDetails.idxChallengeType = TFMConstants.EMPTY;
    }
    workflowDetails.userId = caseRecord.Daon_User_Id__c;
    workflowDetails.idCheck = caseRecord.Daon_Check_Id__c;
    workflowDetails.documentId = caseRecord.Daon_Document_Id__c;
    workflowDetails.IDValue = caseRecord.Person_Digital_Identity__c;
    workflowDetails.idxAuthenticationRequestId = caseRecord
      .Daon_Auth_Request_Id__c;
    workflowDetails.idxRegistrationChallengeId = caseRecord
      .Daon_Reg_Challenge_Id__c;
    workflowDetails.idxRequestId = caseRecord.Daon_Auth_Request_Id__c != null
      ? caseRecord.Daon_Auth_Request_Id__c
      : caseRecord.Daon_Reg_Challenge_Id__c;
    workflowDetails.isPinWorkflow = caseRecord.RecordType.DeveloperName ==
      TFMConstants.PIN_RECOVERY_API_NAME
      ? true
      : false;
    workflowDetails.workflowId = caseRecord.Aegis_Workflow_Id__c;
    workflowDetails.isPinHistoryCheckFailed = caseRecord.Pin_History_Check_Failed__c;
    workflowDetails.isCaseClosed = caseRecord.IsClosed;
    return workflowDetails;
  }

  /**
   * @description fetches records from Content Version object and forms the wrapper
   * @param workflowDetailsJSON wrapper details
   * @return OnboardingWorkflowWrapper wrapper details
   **/
  @AuraEnabled
  public static OnboardingWorkflowWrapper fetchOnboardingDocumentsLWC(
    String workflowDetailsJSON
  ) {
    OnboardingWorkflowWrapper workflowDetails = OnboardingWorkflowWrapper.parse(
      workflowDetailsJSON
    );
    fetchOnboardingDocuments(workflowDetails);
    return workflowDetails;
  }

  /**
   * @description fetches records from Content Version object and forms the wrapper
   * @param  workflowDetails wrapper details
   **/
  @AuraEnabled
  public static void fetchOnboardingDocuments(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    workflowDetails.filesCreatedCounter = 0;

    List<ContentVersion> cvList = WORKFLOW_QUERY_REPOSITORY.getCVRecord(
      workflowDetails
    );
    workflowDetails.fileTypesList = OnboardingFalloutWorkflowHelper.formFilesList(
      workflowDetails,
      cvList
    );
  }

  /**
   * @description fetches records from Content Version object and forms the wrapper
   * @param workflowDetailsJSON wrapper details
   * @return OnboardingWorkflowWrapper wrapper details
   **/
  @AuraEnabled
  public static OnboardingWorkflowWrapper apiCallToFetchImagesLWC(
    String workflowDetailsJSON
  ) {
    OnboardingWorkflowWrapper workflowDetails = OnboardingWorkflowWrapper.parse(
      workflowDetailsJSON
    );
    apiCallToFetchImages(workflowDetails);
    return workflowDetails;
  }

  /**
   * @description forms API request body
   * @param workflowDetails wrapper
   **/
  @AuraEnabled
  public static void apiCallToFetchImages(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    List<String> filesNotFoundInCV = new List<String>();
    for (
      OnboardingWorkflowWrapper.FileTypes fileData : workflowDetails.fileTypesList
    ) {
      if (fileData.isImageNotFound) {
        filesNotFoundInCV.add(fileData.fileType);
      }
    }
    if (filesNotFoundInCV.isEmpty()) {
      return;
    }

    List<OnboardingRequestModel> daonList = OnboardingFalloutWorkflowHelper.requestBodyAPICallout(
      workflowDetails
    );
    Map<String, Object> responseMap = OnboardingUtility.fetchOnboardingDocumentsAPI(
      workflowDetails.IDValue,
      daonList
    );

    workflowDetails.responseMsg = String.valueOf(
      responseMap.get('responseMessage')
    );

    if (responseMap.get('responseMessage') == TFMConstants.SUCCESS_RESPONSE) {
      fetchOnboardingDocuments(workflowDetails);
    }
  }
}
