/**
 * @description       : OnboardingWorkflowWrapper for LWC
 * @author            : Anuj Jain/ Shivraj Kadam
 * @group             :
 * @last modified on  : 06-04-2024
 * @last modified by  : Anuj Jain
 **/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.PropertyNamingConventions')
public class OnboardingWorkflowWrapper extends CalloutModel {
  /**
   * @description showCheckboxes
   */
  @AuraEnabled
  public Boolean showCheckboxes { get; set; }
  /**
   * @description showRedBorder
   */
  @AuraEnabled
  public Boolean showRedBorder { get; set; }
  /**
   * @description caseId
   */
  @AuraEnabled
  public String caseId { get; set; }
  /**
   * @description IDValue
   */
  @AuraEnabled
  public String IDValue { get; set; }
  /**
   * @description cobPIDRecord
   */
  @AuraEnabled
  public COBPrimaryIDDocument__c cobPIDRecord { get; set; }
  /**
   * @description cobPIDRecordId
   */
  @AuraEnabled
  public Id cobPIDRecordId { get; set; }
  /**
   * @description userId
   */
  @AuraEnabled
  public String userId { get; set; }
  /**
   * @description idCheck
   */
  @AuraEnabled
  public String idCheck { get; set; }
  /**
   * @description documentId
   */
  @AuraEnabled
  public String documentId { get; set; }
  /**
   * @description idxExtractedFaceId
   */
  @AuraEnabled
  public String idxExtractedFaceId { get; set; }
  /**
   * @description getDraftCVIDs
   */
  @AuraEnabled
  public List<String> getDraftCVIDs {
    get {
      if (this.draftCVIDs != null) {
        return draftCVIDs;
      }
      List<String> newDraftCVIDs = new List<String>();
      if (this.fileTypesList == null) {
        return newDraftCVIDs;
      }
      for (FileTypes fileData : this.fileTypesList) {
        if (fileData.isImageDraft && fileData.isValid) {
          newDraftCVIDs.add(fileData.cvId);
        }
      }
      return newDraftCVIDs;
    }
  }

  /**
   * @description draftCVIDs
   */
  @AuraEnabled
  public List<String> draftCVIDs { get; set; }
  
  /**
   * @description fileTypesList
   */
  @AuraEnabled
  public List<FileTypes> fileTypesList { get; set; }
  /**
   * @description unProcessedImageData
   */

  @AuraEnabled
  public FileTypes unProcessedImageData { get; set; }
  /**
   * @description processedImageData
   */
  @AuraEnabled
  public FileTypes processedImageData { get; set; }
  /**
   * @description extractedFaceData
   */
  @AuraEnabled
  public FileTypes extractedFaceData { get; set; }
  /**
   * @description selfieData
   */
  @AuraEnabled
  public FileTypes selfieData { get; set; }
  /**
   * @description onboardingModelData
   */
  @AuraEnabled
  public OnboardingResponseModel onboardingModelData { get; set; }
  /**
   * @description responseMsg
   */
  @AuraEnabled
  public String responseMsg { get; set; }

  /**
   * @description filesCreatedCounter
   */
  @AuraEnabled
  public Integer filesCreatedCounter { get; set; }

  /**
   * @description idxChallengeType
   */
  @AuraEnabled
  public String idxChallengeType { get; set; }

  /**
   * @description idxRegistrationChallengeId
   */
  @AuraEnabled
  public String idxRegistrationChallengeId { get; set; }

  /**
   * @description idxAuthenticationRequestId
   */
  @AuraEnabled
  public String idxAuthenticationRequestId { get; set; }

  /**
   * @description idxRequestId
   */
  @AuraEnabled
  public String idxRequestId { get; set; }

  /**
   * @description processInstanceKey
   */
  @AuraEnabled
  public String processInstanceKey { get; set; }

  /**
   * @description isPinWorkflow
   */
  @AuraEnabled
  public Boolean isPinWorkflow { get; set; }

  /**
   * @description workflowId
   */
  @AuraEnabled
  public String workflowId { get; set; }

  /**
   * @description isPinHistoryCheckFailed
   */
  @AuraEnabled
  public Boolean isPinHistoryCheckFailed { get; set; }
  /**
   * @description isCaseClosed
   */
  @AuraEnabled
  public Boolean isCaseClosed { get; set; }

  /**
   * @description parentRecordReference
   */
  @AuraEnabled
  public String parentRecordReference{ get; set; }

  /**
   * @description This is wrapper class for FileTypes
   * @name FileTypes
   * @author Shivraj Kadam
   */
  public class FileTypes {
    /**
     * @description fileType
     */
    @AuraEnabled
    public String fileType { get; set; }
    /**
     * @description uuid
     */
    @AuraEnabled
    public String uuid { get; set; }
    /**
     * @description cvId
     */
    @AuraEnabled
    public String cvId { get; set; }
    /**
     * @description isImageDraft
     */
    @AuraEnabled
    public Boolean isImageDraft { get; set; }
    /**
     * @description isImageFinalVersion
     */
    @AuraEnabled
    public Boolean isImageFinalVersion { get; set; }
    /**
     * @description imageURL
     */
    @AuraEnabled
    public String imageURL { get; set; }
    /**
     * @description isImageNotFound
     */
    @AuraEnabled
    public Boolean isImageNotFound { get; set; }
    /**
     * @description stopSpinner
     */
    @AuraEnabled
    public Boolean stopSpinner { get; set; }
    /**
     * @description isValid
     */
    @AuraEnabled
    public Boolean isValid { get; set; }
  }

  /**
   * @description Represents details body for onboarding LWC
   * @param json details body for onboarding LWC
   * @return `OnboardingWorkflowWrapper` api response is serialised into OnboardingWorkflowWrapper
   */
  public static OnboardingWorkflowWrapper parse(String json) {
    return (OnboardingWorkflowWrapper) deserialize(
      json,
      OnboardingWorkflowWrapper.class
    );
  }
  /**
   * @description frontUnprocessedId formation
   * @return `String` frontUnprocessedId
   */
  public String frontUnprocessedId {
    get {
      return UserInfo.getUserId() +
        '-DAON_FILE_TYPE_FRONT_UNPROCESSED-' +
        this.documentId +
        '-' +
        (this.workflowId ?? '');
    }
  }
  /**
   * @description frontProcessedId formation
   * @return `String` frontProcessedId
   */
  public String frontProcessedId {
    get {
      return UserInfo.getUserId() +
        '-DAON_FILE_TYPE_FRONT_PROCESSED-' +
        this.documentId +
        '-' +
        (this.workflowId ?? '');
    }
  }
  /**
   * @description selfieImageId formation
   * @return `String` selfieImageId
   */
  public String selfieImageId {
    get {
      return UserInfo.getUserId() +
        '-DAON_FILE_TYPE_SELFIE-' +
        this.userId +
        '-' +
        (this.workflowId ?? '');
    }
  }
  /**
   * @description extractedFaceId formation
   * @return `String` extractedFaceId
   */
  public String extractedFaceId {
    get {
      return UserInfo.getUserId() +
        '-DAON_FILE_TYPE_EXTRACTED_FACE-' +
        this.idxExtractedFaceId +
        '-' +
        (this.workflowId ?? '');
    }
  }
  /**
   * @description selfieToBeVerifiedId formation
   * @return `String` selfieToBeVerifiedId
   */
  public String selfieToBeVerifiedId {
    get {
      return UserInfo.getUserId() +
        '-DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED-' +
        this.idxRequestId +
        '-' +
        (this.workflowId ?? '');
    }
  }
}