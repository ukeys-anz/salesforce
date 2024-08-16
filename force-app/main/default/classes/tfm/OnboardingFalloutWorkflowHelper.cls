/**
 * @description       : LWC Helper for onbaordingFalloutWorkflow
 * @author            : Shivraj - TFM Squad
 * @group             :
 * @last modified on  : 06-28-2024
 * @last modified by  : Shivraj
 **/
public with sharing class OnboardingFalloutWorkflowHelper {
  private static final OnboardingQueryRepository ONBOARDING_REPOSITORY = (OnboardingQueryRepository) Lib_InstanceProvider.forType(
    OnboardingQueryRepository.class
  );

  /**
   * @description form FileType Data
   * @param cobPIDRecord cob pid record
   * @param caseRecord case record
   * @return OnboardingWorkflowWrapper wrapper details
   **/
  public static OnboardingWorkflowWrapper populateWorkflowDetails(
    COBPrimaryIDDocument__c cobPIDRecord,
    Case caseRecord
  ) {
    OnboardingWorkflowWrapper workflowDetails = new OnboardingWorkflowWrapper();
    workflowDetails.cobPIDRecordId = cobPIDRecord.Id;
    workflowDetails.IDValue = cobPIDRecord.CustomerOnboardingApplication__r.PersonId__c;
    workflowDetails.idxExtractedFaceId = cobPIDRecord.idxExtractedFaceId__c;
    if (caseRecord == null) {
      return workflowDetails;
    }
    List<String> statusValues = new List<String>{
      'ID Ops: Daon OK',
      'Failed',
      'Potential Fraud'
    };
    if (
      String.isNotBlank(cobPIDRecord.DaonLocationUri__c) &&
      String.isNotBlank(cobPIDRecord.idxExtractedFaceId__c) &&
      String.isNotBlank(caseRecord.Aegis_Workflow_Id__c) &&
      cobPIDRecord.CustomerOnboardingApplication__r.CXOnboardingStage__c.equalsIgnoreCase(
        TFMConstants.ASSISTED_SELFIE
      ) &&
      !statusValues.contains(cobPIDRecord.Verification_Status__c)
    ) {
      workflowDetails.showCheckboxes = true;
    }

    workflowDetails.showRedBorder = caseRecord.Subject.contains(
      TFMConstants.FAILED_DOC
    );
    
    workflowDetails.caseId = caseRecord.Id;
    workflowDetails.workflowId = caseRecord.Aegis_Workflow_Id__c;
    return workflowDetails;
  }

  /**
   * @description form FileType Data
   * @param workflowDetails wrapper details
   * @param daonLocationUri URI field with identifiers separated by slash
   **/
  public static void fetchIdentifierValues(
    OnboardingWorkflowWrapper workflowDetails,
    String daonLocationUri
  ) {
    List<String> idList = daonLocationUri.split('/');
    for (Integer i = 0; i < idList.size(); i++) {
      switch on idList[i] {
        when 'users' {
          workflowDetails.userId = idList[i + 1];
        }
        when 'idchecks' {
          workflowDetails.idCheck = idList[i + 1];
        }
        when 'documents' {
          workflowDetails.documentId = idList[i + 1];
        }
        when else {
          continue;
        }
      }
    }
  }

  /**
   * @description forms API request body
   * @param workflowDetails wrapper details
   * @param fileType file type of image
   * @param cvId content version id
   * @return OnboardingRequestModel.DAONFile inner wrapper with details filled
   **/
  public static OnboardingRequestModel.DAONFile formRequestBody(
    OnboardingWorkflowWrapper workflowDetails,
    String fileType,
    String cvId
  ) {
    OnboardingRequestModel.DAONFile daonFileData = new OnboardingRequestModel.DAONFile();
    daonFileData.salesforce_id = String.isNotBlank(
        workflowDetails.cobPIDRecordId
      )
      ? workflowDetails.cobPIDRecordId
      : workflowDetails.caseId;
    daonFileData.file_type = fileType;
    daonFileData.idx_user_id = workflowDetails.userId;
    daonFileData.idx_id_check_id = workflowDetails.idCheck;
    daonFileData.idx_document_id = workflowDetails.documentId;
    daonFileData.idx_extracted_face_id = workflowDetails.idxExtractedFaceId;
    daonFileData.workflowId = workflowDetails.workflowId;
    daonFileData.content_version_id = String.isNotBlank(cvId)
      ? cvId
      : TFMConstants.EMPTY;
    if (
      workflowDetails.isPinWorkflow != null && workflowDetails.isPinWorkflow
    ) {
      daonFileData.pin_recovery = getPinWorkflowData(workflowDetails);
    } else {
      daonFileData.selfie_recovery = getSelfieWorkflowData(workflowDetails);
    }
    return daonFileData;
  }

  /**
   * @description form FileType Data
   * @param cvRecord ContentVersion record
   * @return OnboardingWorkflowWrapper.FileTypes wrapper with details for each file type
   **/
  public static OnboardingWorkflowWrapper.FileTypes formFileTypeData(
    ContentVersion cvRecord
  ) {
    OnboardingWorkflowWrapper.FileTypes fileData = new OnboardingWorkflowWrapper.FileTypes();
    fileData.cvId = '';
    fileData.fileType = '';
    fileData.uuid = '';
    fileData.isImageNotFound = false;
    fileData.isImageDraft = (cvRecord != null &&
    cvRecord.Document_Flag__c == '1');
    fileData.isImageFinalVersion = (cvRecord != null &&
    cvRecord.Document_Flag__c == '4');
    fileData.stopSpinner = false;
    fileData.imageURL = (cvRecord != null &&
      cvRecord.Document_Flag__c == '4')
      ? URL.getOrgDomainURL().toExternalForm() +
        TFMConstants.IMAGE_URL +
        cvRecord.Id
      : '';
    fileData.isValid = false;
    if (cvRecord != null) {
      fileData.cvId = String.valueOf(cvRecord.Id);
      fileData.fileType = cvRecord.Title;
      fileData.uuid = cvRecord.UUID__c;
    }
    return fileData;
  }

  /**
   * @description forms API request body
   * @param workflowDetails wrapper details
   * @param cvList content versions
   * @return List<OnboardingWorkflowWrapper.FileTypes> wrapper with details filled
   **/
  public static List<OnboardingWorkflowWrapper.FileTypes> formFilesList(
    OnboardingWorkflowWrapper workflowDetails,
    List<ContentVersion> cvList
  ) {
    Map<String, String> fileTypeByUUID = new Map<String, String>{
      'DAON_FILE_TYPE_FRONT_UNPROCESSED' => workflowDetails.frontUnprocessedId,
      'DAON_FILE_TYPE_FRONT_PROCESSED' => workflowDetails.frontProcessedId,
      'DAON_FILE_TYPE_EXTRACTED_FACE' => workflowDetails.extractedFaceId,
      'DAON_FILE_TYPE_SELFIE' => workflowDetails.selfieImageId,
      'DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED' => workflowDetails.selfieToBeVerifiedId
    };

    List<OnboardingWorkflowWrapper.FileTypes> filesList = new List<OnboardingWorkflowWrapper.FileTypes>();
    List<String> temporaryFilesList = new List<String>();

    for (ContentVersion cv : cvList) {
      OnboardingWorkflowWrapper.FileTypes fileData = formFileTypeData(cv);
      for (String type : fileTypeByUUID.keySet()) {
        if (
          fileData.fileType != type &&
          fileData.uuid != fileTypeByUUID.get(type)
        ) {
          continue;
        }
        if (cv.Document_Flag__c == '4') {
          fileData.stopSpinner = true;
          workflowDetails.filesCreatedCounter += 1;
        }
        fileData.isValid = true;
        loadData(type, fileData, workflowDetails);
        filesList.add(fileData);
        temporaryFilesList.add(cv.Title);
      }
    }

    filesList.addAll(
      OnboardingUtility.formMissingTypesNodes(
        workflowDetails,
        temporaryFilesList
      )
    );

    return filesList;
  }

  /**
   * @description load data into nodes
   * @param type type of file
   * @param fileData fileData node
   * @param workflowDetails wrapper details
   **/
  public static void loadData(
    String type,
    OnboardingWorkflowWrapper.FileTypes fileData,
    OnboardingWorkflowWrapper workflowDetails
  ) {
    switch on type {
      when 'DAON_FILE_TYPE_FRONT_UNPROCESSED' {
        workflowDetails.unProcessedImageData = fileData;
      }
      when 'DAON_FILE_TYPE_FRONT_PROCESSED' {
        workflowDetails.processedImageData = fileData;
      }
      when 'DAON_FILE_TYPE_EXTRACTED_FACE' {
        workflowDetails.extractedFaceData = fileData;
      }
      when 'DAON_FILE_TYPE_SELFIE' {
        workflowDetails.selfieData = fileData;
      }
      when 'DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED' {
        if (String.isNotBlank(workflowDetails.idxRequestId)) {
          workflowDetails.extractedFaceData = fileData;
        }
      }
    }
  }
  /**
   * @description forms API request body
   * @param workflowDetails wrapper details
   * @return List<OnboardingRequestModel> request modal list
   **/
  public static List<OnboardingRequestModel> requestBodyAPICallout(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    List<OnboardingRequestModel> daonList = new List<OnboardingRequestModel>();
    for (
      OnboardingWorkflowWrapper.FileTypes fileTypeData : workflowDetails.fileTypesList
    ) {
      if (!fileTypeData.isImageDraft && !fileTypeData.isImageNotFound) {
        continue;
      }

      OnboardingRequestModel ob = new OnboardingRequestModel();
      ob.requester_sf_id = UserInfo.getUserId();
      OnboardingRequestModel.DAONFile daonFileNode = formRequestBody(
        workflowDetails,
        fileTypeData.fileType,
        fileTypeData.cvId
      );
      ob.daon_file = daonFileNode;
      daonList.add(ob);
    }
    return daonList;
  }

  /**
   * @description get pinWorkflowData
   * @param workflowDetails wrapper details
   * @return OnboardingRequestModel.PinRecoveryChallenge inner wrapper with details filled
   **/
  public static OnboardingRequestModel.PinRecoveryChallenge getPinWorkflowData(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    OnboardingRequestModel.PinRecoveryChallenge pinRecChallenge = new OnboardingRequestModel.PinRecoveryChallenge();
    pinRecChallenge.idx_challenge_id = workflowDetails.idxRegistrationChallengeId;
    return pinRecChallenge;
  }

  /**
   * @description get selfieWorkflowData
   * @param workflowDetails wrapper details
   * @return OnboardingRequestModel.SelfieRecoveryChallenge inner wrapper with details filled
   **/
  public static OnboardingRequestModel.SelfieRecoveryChallenge getSelfieWorkflowData(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    OnboardingRequestModel.SelfieRecoveryChallenge selfieRecChallenge = new OnboardingRequestModel.SelfieRecoveryChallenge();
    selfieRecChallenge.idx_challenge_type = workflowDetails.idxChallengeType;
    selfieRecChallenge.idx_challenge_id = workflowDetails.idxRequestId;
    return selfieRecChallenge;
  }
}