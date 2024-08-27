/**
 * @description       : LWC Controller for onbaordingFalloutWorkflow
 * @author            : Anuj/ Shivraj - TFM Squad
 * @group             :
 * @last modified on  : 07-31-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class OnboardingFalloutWorkflowController {
  private static final OnboardingQueryRepository ONBOARDING_REPOSITORY = (OnboardingQueryRepository) Lib_InstanceProvider.forType(
    OnboardingQueryRepository.class
  );
  /**
   * @description gets the data from PID record
   * @param recordId PID recordId
   * @return OnboardingWorkflowWrapper
   **/
  @AuraEnabled
  public static OnboardingWorkflowWrapper performOnboardingOperations(
    Id recordId
  ) {
    Logger.debug( 'Apex execution for performOnboardingOperations started at - ' + System.now());

    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    COBPrimaryIDDocument__c cobPIDRecord;
    Case caseRecord;
    Boolean hasAccessToAegisFeatures = ONBOARDING_REPOSITORY.checkCustomPermission();

    if (!hasAccessToAegisFeatures) {
      workflowDetails.responseMsg = TFMConstants.NO_ACCESS_AEGIS_FEATURES;
      return workflowDetails;
    }

    try {
      cobPIDRecord = ONBOARDING_REPOSITORY.getCOBPIDRecord(recordId);
      if (
        cobPIDRecord.CustomerOnboardingApplication__r.CXOnboardingStage__c ==
        TFMConstants.ASSISTED_SELFIE
      ) {
        caseRecord = ONBOARDING_REPOSITORY.getCaseRecord(
          cobPIDRecord.CustomerOnboardingApplication__r.PersonaId__c +
          cobPIDRecord.CustomerOnboardingApplication__r.OnboardingAttemptCount__c
        );
      }
    } catch (Exception ex) {
      workflowDetails.responseMsg = TFMConstants.ERROR_OCCURRED;
      return workflowDetails;
    }

    workflowDetails = OnboardingFalloutWorkflowHelper.populateWorkflowDetails(
      cobPIDRecord,
      caseRecord
    );

    if (String.isNotBlank(cobPIDRecord.DaonLocationUri__c)) {
      OnboardingFalloutWorkflowHelper.fetchIdentifierValues(
        workflowDetails,
        cobPIDRecord.DaonLocationUri__c
      );
    }

    fetchOnboardingDocuments(workflowDetails);
    apiCallToFetchImages(workflowDetails);

    Logger.debug( 'Apex execution for performOnboardingOperations ended at - ' + System.now());
    Logger.saveLog();

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
   * @param workflowDetails wrapper details
   **/
  public static void fetchOnboardingDocuments(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    workflowDetails.filesCreatedCounter = 0;
    List<ContentVersion> cvList = ONBOARDING_REPOSITORY.fetchContentVersions(
      workflowDetails
    );

    workflowDetails.fileTypesList = OnboardingFalloutWorkflowHelper.formFilesList(
      workflowDetails,
      cvList
    );
    workflowDetails.draftCVIDs = workflowDetails.getDraftCVIDs;
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
   * @param workflowDetails wrapper details
   **/
  @AuraEnabled
  public static void apiCallToFetchImages(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    Logger.debug('Apex execution for apiCallToFetchImages started at - ' + System.now());

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

    Logger.debug('Apex execution for apiCallToFetchImages ended at - ' + System.now());
    Logger.saveLog();

    if (responseMap.get('responseMessage') == TFMConstants.SUCCESS_RESPONSE) {
      fetchOnboardingDocuments(workflowDetails);
    }
  }
}
