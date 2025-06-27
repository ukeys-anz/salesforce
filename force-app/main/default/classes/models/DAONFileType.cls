public enum DAONFileType {
  DAON_FILE_TYPE_SELFIE_ENROLLED,
  DAON_FILE_TYPE_SELFIE_TO_BE_ENROLLED,
  // Processed Front Image of the ID Document
  DAON_FILE_TYPE_FRONT_PROCESSED,
  // Unprocessed Front Image of the ID Document
  DAON_FILE_TYPE_FRONT_UNPROCESSED,
  // Processed Front Image of the ID Document
  DAON_FILE_TYPE_BACK_PROCESSED,
  // Unprocessed Front Image of the ID Document
  DAON_FILE_TYPE_BACK_UNPROCESSED,
  // Extracted face image from the ID Document
  DAON_FILE_TYPE_EXTRACTED_FACE,
  // The selfie image to be verified
  // Pin and Selfie recovery flow
  DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED,
  // ReKYC selfie
  DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE
}
