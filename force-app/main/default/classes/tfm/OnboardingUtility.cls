/**
 * @description       : API call for Onboarding documents
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 07-10-2024
 * @last modified by  : Shivraj
 **/
public with sharing class OnboardingUtility {
  /**
   * @param idValue arg for API
   * @param onboardingModelList arg for API
   * @return `Map<String,Object>`
   * @description fetch all onboardingDocuments
   */
  public static Map<String, Object> fetchOnboardingDocumentsAPI(
    String idValue,
    List<OnboardingRequestModel> onboardingModelList
  ) {
    Map<String, Object> returnMap = new Map<String, Object>();
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      idValue
    );
    OnboardingAPIRepository api = new OnboardingAPIRepository();
    try {
      OnboardingResponseModel onboardingModel = api.fetchOnboardingDocumentsAPI(
        staffModel,
        onboardingModelList
      );
      returnMap.put('responseData', onboardingModel);
      returnMap.put(TFMConstants.RESPONSE_MESSAGE, TFMConstants.SUCCESS);
    } catch (OnboardingAPIRepository.InsufficientAccessException e) {
      returnMap.put(
        TFMConstants.RESPONSE_MESSAGE,
        System.Label.Onboarding_InsufficientAccess_Message
      );
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (OnboardingAPIRepository.ServerErrorException e) {
      returnMap.put(
        TFMConstants.RESPONSE_MESSAGE,
        System.Label.Onboarding_ServerError_Message
      );
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      returnMap.put(
        TFMConstants.RESPONSE_MESSAGE,
        System.Label.Onboarding_ServerError_Message
      );
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    return returnMap;
  }

  /**
   * @param idValue arg for API
   * @param manageOpsRequest ManageOpsWorkflowRequestModel instance
   * @param apiScopesRequested apiScopesRequested
   * @return  Map<String, String> status & message
   * @description fetch all onboardingDocuments
   */
  public static Map<String, String> updateCaseStatusAPI(
    String idValue,
    ManageOpsWorkflowRequestModel manageOpsRequest,
    String apiScopesRequested
  ) {
    Map<String, String> returnMap = new Map<String, String>();
    StaffTokenRequestModel staffModel = TFMCommonFunctionUtility.setStaffModel(
      idValue
    );
    staffModel.apiScopesRequested = apiScopesRequested;
    String responseMessage;
    OnboardingAPIRepository api = new OnboardingAPIRepository();
    try {
      HttpCalloutResponse response = api.updateCaseStatusAPI(
        staffModel,
        manageOpsRequest
      );
      responseMessage = TFMConstants.SUCCESS;

      returnMap.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.SUCCESS);
    } catch (OnboardingAPIRepository.InsufficientAccessException e) {
      returnMap.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.ERRORSTATUS);
      responseMessage = System.Label.Onboarding_InsufficientAccess_Message;
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (OnboardingAPIRepository.ServerErrorException e) {
      returnMap.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.ERRORSTATUS);
      responseMessage = System.Label.Onboarding_ServerError_Message;
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    } catch (Exception e) {
      returnMap.put(TFMConstants.STATUS_WITH_SMALL_S, TFMConstants.ERRORSTATUS);
      responseMessage = System.Label.Onboarding_ServerError_Message;
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
    }
    returnMap.put(TFMConstants.RESPONSE_MESSAGE, responseMessage);
    return returnMap;
  }

  /**
   * @param workflowDetails wrapper details
   * @param temporaryFilesList file type found in CV
   * @return  List<OnboardingWorkflowWrapper.FileTypes> filesList
   * @description formMissingTypesNodes
   */
  public static List<OnboardingWorkflowWrapper.FileTypes> formMissingTypesNodes(
    OnboardingWorkflowWrapper workflowDetails,
    List<String> temporaryFilesList
  ) {
    List<OnboardingWorkflowWrapper.FileTypes> filesList = new List<OnboardingWorkflowWrapper.FileTypes>();
    List<String> allFileTypesList = new List<String>{
      'DAON_FILE_TYPE_FRONT_UNPROCESSED',
      'DAON_FILE_TYPE_FRONT_PROCESSED',
      'DAON_FILE_TYPE_SELFIE'
    };
    if (workflowDetails.isPinWorkflow != null) {
      allFileTypesList.add('DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED');
    } else {
      allFileTypesList.add('DAON_FILE_TYPE_EXTRACTED_FACE');
    }

    for (String fileType : allFileTypesList) {
      if (temporaryFilesList.contains(fileType)) {
        continue;
      }
      OnboardingWorkflowWrapper.FileTypes fileData = OnboardingFalloutWorkflowHelper.formFileTypeData(
        null
      );
      if (
        workflowDetails.unProcessedImageData == null &&
        fileType == 'DAON_FILE_TYPE_FRONT_UNPROCESSED'
      ) {
        fileData.fileType = fileType;
        fileData.isImageNotFound = true;
        workflowDetails.unProcessedImageData = fileData;
        filesList.add(fileData);
      }
      if (
        workflowDetails.processedImageData == null &&
        fileType == 'DAON_FILE_TYPE_FRONT_PROCESSED'
      ) {
        fileData.fileType = fileType;
        fileData.isImageNotFound = true;
        workflowDetails.processedImageData = fileData;
        filesList.add(fileData);
      }
      if (
        workflowDetails.isPinWorkflow != null &&
        workflowDetails.extractedFaceData == null &&
        fileType == 'DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED'
      ) {
        fileData.fileType = fileType;
        fileData.isImageNotFound = true;
        workflowDetails.extractedFaceData = fileData;
        filesList.add(fileData);
      } else if (
        workflowDetails.extractedFaceData == null &&
        fileType == 'DAON_FILE_TYPE_EXTRACTED_FACE'
      ) {
        fileData.fileType = fileType;
        fileData.isImageNotFound = true;
        workflowDetails.extractedFaceData = fileData;
        filesList.add(fileData);
      }
      if (
        workflowDetails.selfieData == null &&
        fileType == 'DAON_FILE_TYPE_SELFIE'
      ) {
        fileData.fileType = fileType;
        fileData.isImageNotFound = true;
        workflowDetails.selfieData = fileData;
        filesList.add(fileData);
      }
    }
    return filesList;
  }
}