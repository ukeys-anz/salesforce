/**
 * @description       : TrustMeCaseStatusPathHelper helper class for TrustMeCaseStatusController
 * @author            : Shivraj Kadam
 * @group             :
 * @last modified on  : March 2025
 **/
public with sharing class TrustMeCaseStatusPathHelper {
  private static Map<String, String> sfValueToTrustXValue = new Map<String, String>{
    'ID and Selfie Check Passed' => 'MANUAL_REVIEW_STATE_APPROVED',
    'Failed' => 'MANUAL_REVIEW_STATE_DENIED',
    'No Defect' => 'QUALITY_ASSURANCE_REVIEW_STATE_CLOSED_NO_DEFECT',
    'Defect Identified' => 'QUALITY_ASSURANCE_REVIEW_STATE_DEFECT_IDENTIFIED',
    'Fraud Suspected' => 'QUALITY_ASSURANCE_REVIEW_STATE_FRAUD_SUSPECTED',
    'Selfie fail - selfie image is clear, but not the same person' => 'MANUAL_REVIEW_DENIED_REASON_SELFIE_FACIAL_COMPARISON_FAILED',
    'Selfie fail - selfie image is not clear enough to match' => 'MANUAL_REVIEW_DENIED_REASON_SELFIE_UNUSABLE_FOR_MATCHING',
    'Selfie fail - document image is not clear enough to match' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_POOR_PHOTO_QUALITY',
    'Doc fail - suspected fraud, based on document' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_SUSPECTED_FRAUD',
    'Doc fail - document is expired' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_EXPIRED',
    'Doc fail - document is a picture of a picture' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_PICTURE_OF_PICTURE',
    'Doc fail - document is ineligible type' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_TYPE_NOT_ACCEPTABLE',
    'Doc fail - document details unreadable' => 'MANUAL_REVIEW_DENIED_REASON_ID_DOC_UNREADABLE'
  };

  private static final TrustMeAPIRepository TRUSTME_REPO = (TrustMeAPIRepository) Lib_InstanceProvider.forType(
    TrustMeAPIRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Trigger Temporal workflow based on case status
   * @param trustMeCase trustMeCase
   */
  public static void makeAPICallout(Case trustMeCase) {
    TrustMeCaseUpdateModel caseUpdateDetails = new TrustMeCaseUpdateModel();

    caseUpdateDetails.evaluation_id = trustMeCase.Evaluation_Id__c;
    caseUpdateDetails.state = sfValueToTrustXValue.get(trustMeCase.Status);

    Id caseRTId = trustMeCase.RecordTypeId;
    String recordTypeName = QueryRT.of(Case.SObjectType)
      .get(caseRTId)
      .getDeveloperName();

    caseUpdateDetails.case_type = recordTypeName;
    caseUpdateDetails.primary_denied_reason = sfValueToTrustXValue.get(
      trustMeCase.OnboardingVerificationFailedReason__c
    );
    caseUpdateDetails.secondary_denied_reason = sfValueToTrustXValue.get(
      trustMeCase.SecondaryVerificationFailedReason__c
    );
    caseUpdateDetails.checks = populateChecksForQACase(
      trustMeCase
    );

    TRUSTME_REPO.updateCaseStatus(caseUpdateDetails);
  }
  /**
   * @description Updates the case in scenarios where there is either: callout error (case will hold the error reason) or DML error or without error
   * @param trustMeCase Case with new fields data to be updated
   * @param comments comments
   */
  public static void handleCaseUpdate(Case trustMeCase, String comments) {
    //remove unneeded field
    Case updateCase = new Case(
      Id = trustMeCase.Id,
      Status = trustMeCase.Status,
      OnboardingVerificationFailedReason__c = String.isNotBlank(trustMeCase.OnboardingVerificationFailedReason__c) ? trustMeCase.OnboardingVerificationFailedReason__c : '',
      SecondaryVerificationFailedReason__c = String.isNotBlank(trustMeCase.SecondaryVerificationFailedReason__c) ? trustMeCase.SecondaryVerificationFailedReason__c : '',
      Comments = comments
    );

    DML_REPOSITORY.doUpdate(updateCase, new DmlConfig().allowPartial());
  }

  /**
   * @description returns true for Yes and false for No value
   * @param value value
   * @return Boolean true or false
   */
  @TestVisible
  private static Boolean getFlag(String value) {
    return value == 'Yes';
  }

  /**
   * @description populate Checks details
   * @param trustMeCase trustMeCase
   * @return `TrustMeCaseUpdateModel.Checks` wrapper details
   */
  @TestVisible
  private static TrustMeCaseUpdateModel.Checks populateChecksForQACase(
    Case trustMeCase
  ) {
    if (trustMeCase.RecordTypeId != RTCase.trustMeQA) {
      return null;
    }
    TrustMeCaseUpdateModel.Checks checksFields = new TrustMeCaseUpdateModel.Checks();
    checksFields.customer_photo_id_legibility = getFlag(
      trustMeCase.Fraud_ID_Legible__c
    );
    checksFields.residential_address_validity = getFlag(
      trustMeCase.Fraud_Address_Valid__c
    );
    checksFields.customer_photo_id_modification = getFlag(
      trustMeCase.Fraud_Customer_Photo_Modified__c
    );
    checksFields.selfie_comparison = getFlag(
      trustMeCase.Fraud_Selfie_Comparison_Match__c
    );
    checksFields.picture_of_picture = getFlag(
      trustMeCase.Fraud_ID_Not_Picture__c
    );
    checksFields.middle_name = getFlag(trustMeCase.Fraud_MiddleNameCheck__c);
    checksFields.id_document_security_features = getFlag(
      trustMeCase.Fraud_Security_Features__c
    );
    checksFields.kyc_info_and_id_doc_type = getFlag(
      trustMeCase.Fraud_Customer_Details__c
    );

    return checksFields;
  }
}