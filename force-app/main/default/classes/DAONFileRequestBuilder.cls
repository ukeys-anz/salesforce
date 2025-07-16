/**
 * @author Tan Phan
 * @since 01/2025
 * @description Helper class for constructing DAONFileRequestModel
 */
public with sharing class DAONFileRequestBuilder {
  /**
   * @description The ID of the related record
   */
  @AuraEnabled
  public String relatedRecordId { get; set; }
  /**
   * @description The ID of the customer
   */
  @AuraEnabled
  public String customerId { get; set; }
  /**
   * @description The type of the customer ID
   */
  @AuraEnabled
  public String customerIdType { get; set; }
  /**
   * @description idx_user_id
   */
  @AuraEnabled
  public String idxUserId { get; set; }
  /**
   * @description idx_id_check_id
   */
  @AuraEnabled
  public String idxIdCheckId { get; set; }
  /**
   * @description idx_document_id
   */
  @AuraEnabled
  public String idxDocumentId { get; set; }
  /**
   * @description idx_extracted_face_id
   */
  @AuraEnabled
  public String idxExtractedFaceId { get; set; }
  /**
   * @description workflowId
   */
  @AuraEnabled
  public String workflowId { get; set; }
  /**
   * @description challengeId for pin_recovery/selfie_recovery
   */
  @AuraEnabled
  public String challengeId { get; set; }
  /**
   * @description challengeType for selfie_recovery
   */
  @AuraEnabled
  public String challengeType { get; set; }

  /**
   * @description Builds a map of DAONFileType to UUID based on the provided file types.
   * @param fileTypes List of file types as strings.
   * @return Map of DAONFileType to UUID.
   */
  public Map<DAONFileType, String> buildUUIDByType(List<String> fileTypes) {
    Map<DAONFileType, String> idxFieldByType = new Map<DAONFileType, String>{
      DAONFileType.DAON_FILE_TYPE_FRONT_UNPROCESSED => this.idxDocumentId,
      DAONFileType.DAON_FILE_TYPE_FRONT_PROCESSED => this.idxDocumentId,
      DAONFileType.DAON_FILE_TYPE_BACK_UNPROCESSED => this.idxDocumentId,
      DAONFileType.DAON_FILE_TYPE_BACK_PROCESSED => this.idxDocumentId,
      DAONFileType.DAON_FILE_TYPE_SELFIE_ENROLLED => this.idxUserId,
      DAONFileType.DAON_FILE_TYPE_SELFIE_TO_BE_ENROLLED => this.idxIdCheckId,
      DAONFileType.DAON_FILE_TYPE_EXTRACTED_FACE => this.idxExtractedFaceId,
      DAONFileType.DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED => this.challengeId,
      DAONFileType.DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE => this.idxIdCheckId
    };
    Map<DAONFileType, String> uuidByType = new Map<DAONFileType, String>();
    for (String fileType : fileTypes) {
      DAONFileType fileTypeVal = DAONFileType.valueOf(fileType);
      String value = idxFieldByType.get(fileTypeVal);
      if (String.isBlank(value)) {
        continue;
      }
      List<String> keys = new List<String>{
        UserInfo.getUserId(),
        fileType,
        value,
        this.workflowId ?? ''
      };
      String uuid = String.join(keys, '-');
      uuidByType.put(fileTypeVal, uuid);
    }
    return uuidByType;
  }

  /**
   * @description Builds a DAONFileRequestModel based on the provided map of DAONFileType to ContentVersion.
   * @param cvByType Map of DAONFileType to ContentVersion.
   * @return DAONFileRequestModel containing the constructed files.
   */
  public DAONFileRequestModel buildRequest(
    Map<DAONFileType, ContentVersion> cvByType
  ) {
    DAONFileRequestModel request = new DAONFileRequestModel();
    for (DAONFileType fileType : cvByType.keySet()) {
      request.files.add(
        new DAONFileRequestModel.DAONFileRequest(
          this.buildDAONFile(fileType, cvByType.get(fileType)?.Id)
        )
      );
    }
    return request;
  }

  private DAONFileRequestModel.DAONFile buildDAONFile(
    DAONFileType fileType,
    String contentVersionId
  ) {
    DAONFileRequestModel.DAONFile file = new DAONFileRequestModel.DAONFile();
    file.content_version_id = contentVersionId ?? '';
    file.salesforce_id = this.relatedRecordId;
    file.file_type = fileType;
    file.idx_user_id = this.idxUserId;
    file.idx_id_check_id = this.idxIdCheckId;
    file.idx_document_id = this.idxDocumentId;
    file.idx_extracted_face_id = this.idxExtractedFaceId;
    file.workflowId = this.workflowId;
    if (fileType != DAONFileType.DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED) {
      return file;
    }
    if (this.challengeType == null) {
      file.pin_recovery = new DAONFileRequestModel.PinRecoveryChallenge(
        this.challengeId
      );
    } else {
      file.selfie_recovery = new DAONFileRequestModel.SelfieRecoveryChallenge(
        this.challengeId,
        DAONFileRequestModel.DAONChallengeType.valueOf(this.challengeType)
      );
    }
    return file;
  }
}
