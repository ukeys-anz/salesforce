/**
 * @description       : Repository for OnboardingFalloutWorkflowController
 * @author            : Shivraj - TFM Squad
 * @group             :
 * @last modified on  : 07-15-2024
 * @last modified by  : Anuj Jain - JOIN Squad
 **/
public with sharing class OnboardingQueryRepository {
  /**
   * @description form FileType Data
   * @param recordId cob pid recordId
   * @return COBPrimaryIDDocument__c cobPID record
   **/
  public COBPrimaryIDDocument__c getCOBPIDRecord(Id recordId) {
    COBPrimaryIDDocument__c cobPIDRecord = [
      SELECT
        Id,
        CustomerOnboardingApplication__r.OnboardingAttemptCount__c,
        CustomerOnboardingApplication__r.PersonaId__c,
        CustomerOnboardingApplication__r.PersonId__c,
        DaonLocationUri__c,
        idxExtractedFaceId__c,
        CustomerOnboardingApplication__r.CXOnboardingStage__c,
        Verification_Status__c
      FROM COBPrimaryIDDocument__c
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ];
    return cobPIDRecord;
  }
  /**
   * @description form FileType Data
   * @param personaAttemptCount composite field for query
   * @return Case case record
   **/
  public Case getCaseRecord(String personaAttemptCount) {
    Case caseRecord = [
      SELECT ID, Subject, Aegis_Workflow_Id__c
      FROM Case
      WHERE PersonaAttemptCount__c = :personaAttemptCount
      WITH USER_MODE
      LIMIT 1
    ];
    return caseRecord;
  }

  /**
   * @description forms API request body
   * @param workflowDetails wrapper details
   * @return List<ContentVersion> ContentVersion List
   **/
  public List<ContentVersion> fetchContentVersions(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    List<String> uuidIdentifiers = new List<String>{
      workflowDetails.frontUnprocessedId,
      workflowDetails.frontProcessedId,
      workflowDetails.extractedFaceId,
      workflowDetails.selfieImageId
    };

    List<ContentVersion> cvList = [
      SELECT Id, Title, UUID__c, ContentDocumentId, Document_Flag__c
      FROM ContentVersion
      WHERE
        IsLatest = TRUE
        AND RecordTypeId = :TFMConstants.DAON_FILE_RT_ID
        AND UUID__c IN :uuidIdentifiers
      WITH USER_MODE
    ];
    return cvList;
  }
  /**
   * @description checkCustomPermission
   * @return Boolean returns true if has permission else false
   **/
  public Boolean checkCustomPermission() {
    return FeatureManagement.checkPermission(
      TFMConstants.ACCESS_AEGIS_FEATURES
    );
  }
}