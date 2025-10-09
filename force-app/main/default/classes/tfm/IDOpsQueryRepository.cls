/**
 * @description       : Repository for PinAndSelfieWorkflow
 * @author            : Hinduja - TFM Squad
 * @group             :
 * @last modified on  : 08-07-2025
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
    ] ?? null;
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
        AND RecordTypeId = :RTContentVersion.daonFile
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
    ] ?? null;
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
    ] ?? null;
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
            (RecordTypeId = :RTContentVersion.daonFile
            OR RecordTypeId = :RTContentVersion.daonTrustXFile)
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

  /**
   * @description get cobPID Record
   * @param recordId case recordId
   * @return PersonDigitalIdentity__x
   **/
  public PersonDigitalIdentity__x getPersonDigitalIdentityRec(String recordId) {
    PersonDigitalIdentity__x personDigitalIdentityRec = [
      SELECT
        Id,
        pinRefId__c,
        UUID__c,
        Persona_ID__c,
        Status__c,
        PIN_Status__c,
        IAL_Identity_Assurance_Level__c,
        OCV_ID__c,
        Mobile_Number__c
      FROM PersonDigitalIdentity__x
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
    return personDigitalIdentityRec;
  }

  /**
   * @description documentId from COB-PID record
   * @param  personaId PersonaId
   * @return COBPrimaryIDDocument__c
   **/
  @AuraEnabled
  public static COBPrimaryIDDocument__c getDocumentIdFromCOB(String personaId) {
    CustomerOnboardingApplication__c cob = [
      SELECT
        Id,
        (
          SELECT Id, DaonLocationUri__c
          FROM COBPrimaryIDDocuments__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c = :personaId
      LIMIT 1
    ] ?? null;

    if (cob == null || cob.COBPrimaryIDDocuments__r.isEmpty()) {
      return null;
    }
    return cob.COBPrimaryIDDocuments__r[0];
  }

  /**
   * @description Retrieves QA Check Fields.
   * @param caseIds A list of TrustMe/ ReKYC QA Case IDs.
   * @return A list of TrustMe/ ReKYC QA case records with all the check fields.
   */
  public List<Case> queryQAChecksByIds(Set<Id> caseIds) {
    return [
      SELECT
        Id,
        Fraud_Customer_Details__c,
        Fraud_MiddleNameCheck__c,
        Fraud_Selfie_Comparison_Match__c,
        Fraud_Address_Valid__c,
        Fraud_ID_Legible__c,
        Fraud_ID_Not_Picture__c,
        Fraud_Customer_Photo_Modified__c,
        Fraud_Security_Features__c
      FROM Case
      WHERE Id IN :caseIds
      WITH USER_MODE
    ] ?? null;
  }
}
