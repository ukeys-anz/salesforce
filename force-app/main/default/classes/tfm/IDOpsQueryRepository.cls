/**
 * @description       : Repository for PinAndSelfieWorkflow
 * @author            : Hinduja - TFM Squad
 * @group             :
 * @last modified on  : 10-17-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class IDOpsQueryRepository {
  /**
   * @description get Case Record
   * @param recordId case recordId
   * @return Case
   **/
  public Case getCaseRecord(String recordId) {
    Case caseRecord = [
      SELECT
        ID,
        Subject,
        Aegis_Workflow_Id__c,
        Daon_Challenge_Type__c,
        Daon_Reg_Challenge_Id__c,
        Daon_User_Id__c,
        Daon_Check_Id__c,
        Daon_Document_Id__c,
        Daon_Auth_Request_Id__c,
        Person_Digital_Identity__c,
        RecordType.DeveloperName,
        RecordTypeId,
        Pin_History_Check_Failed__c,
        OnboardingVerificationFailedReason__c,
        Status,
        PersonaId__c,
        Status_Update_Error__c,
        IsClosed,
        CaseNumber,
        CustomerOnboardingApplication__c
      FROM Case
      WHERE ID = :recordId
      WITH USER_MODE
      LIMIT 1
    ];
    return caseRecord;
  }

  /**
   * @description get ContentVersion Record
   * @param workflowDetails OnboardingWorkflowWrapper
   * @return List<ContentVersion>
   **/
  public List<ContentVersion> getCVRecord(
    OnboardingWorkflowWrapper workflowDetails
  ) {
    List<String> uuidIdentifiers = new List<String>{
      workflowDetails.frontUnprocessedId,
      workflowDetails.frontProcessedId,
      workflowDetails.selfieToBeVerifiedId,
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
   * @description get cobPID Record
   * @param recordId case recordId
   * @return COBPrimaryIDDocument__c
   **/
  public COBPrimaryIDDocument__c getCOBPIDRecord(String recordId) {
    COBPrimaryIDDocument__c cobPIDRecord = [
      SELECT
        Id,
        Verified_By__c,
        Verification_Date_Time__c,
        Verification_Status__c,
        Verification_Failed_Reason__c,
        Failed_Message__c
      FROM COBPrimaryIDDocument__c
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ];
    return cobPIDRecord;
  }

  /**
   * @description get cobPID Record
   * @param  customerOnboardingApplicationId CustomerOnboardingApplicationId
   * @return COBPrimaryIDDocument__c
   **/
  public COBPrimaryIDDocument__c getCOBPIDRecordUsingCOA(
    String customerOnboardingApplicationId
  ) {
    COBPrimaryIDDocument__c cobPIDRecord = [
      SELECT Id, Verification_Status__c
      FROM COBPrimaryIDDocument__c
      WHERE CustomerOnboardingApplication__c = :customerOnboardingApplicationId
      WITH USER_MODE
      LIMIT 1
    ];
    return cobPIDRecord;
  }

  /**
   * @description getContent Documents Record
   * @param elapsedDateTime dateTime
   * @return List<ContentDocument>
   **/
  public List<ContentDocument> getContentDocumentsRecord(
    Datetime elapsedDateTime
  ) {
    List<ContentDocument> listContentDocuments = [
      SELECT
        Id,
        Title,
        Owner.Name,
        CreatedDate,
        CreatedBy.Name,
        LatestPublishedVersion.FirstPublishLocationId
      FROM ContentDocument
      WHERE
        Id IN (
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE
            RecordTypeId = :TFMConstants.DAON_FILE_RT_ID
            AND CreatedDate < :elapsedDatetime
        )
      WITH USER_MODE
    ];
    return listContentDocuments;
  }
  /**
   * @description checkCustomPermission
   * @param permissionName name of custom permission
   * @return Boolean returns true if has permission else false
   **/
  public Boolean checkCustomPermission(String permissionName) {
    return FeatureManagement.checkPermission(permissionName);
  }
}
