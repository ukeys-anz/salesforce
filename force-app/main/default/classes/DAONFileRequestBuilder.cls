/**
 * @author Tan Phan
 * @since 01/2025
 * @description Helper class for constructing DAONFileRequestModel
 */
public with sharing class DAONFileRequestBuilder {
  @AuraEnabled
  public String relatedRecordId;
  @AuraEnabled
  public String customerId;
  @AuraEnabled
  public String customerIdType;
  @AuraEnabled
  public String idxUserId;
  @AuraEnabled
  public String idxIdCheckId;
  @AuraEnabled
  public String idxDocumentId;
  @AuraEnabled
  public String idxExtractedFaceId;
  @AuraEnabled
  public String workflowId;
  @AuraEnabled
  public String challengeId;
  @AuraEnabled
  public DAONFileRequestModel.DAONChallengeType challengeType;

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
      DAONFileType.DAON_FILE_TYPE_SELFIE => this.idxUserId,
      DAONFileType.DAON_FILE_TYPE_EXTRACTED_FACE => this.idxExtractedFaceId,
      DAONFileType.DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED => this.challengeId
    };
    Map<DAONFileType, String> uuidByType = new Map<DAONFileType, String>();
    for (String fileType : fileTypes) {
      DAONFileType fileTypeVal = DAONFileType.valueOf(fileType);
      String value = idxFieldByType.get(fileTypeVal);
      if (String.isBlank(value)) {
        continue;
      }
      Set<String> keys = new Set<String>{
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
        this.challengeType
      );
    }
    return file;
  }
}
