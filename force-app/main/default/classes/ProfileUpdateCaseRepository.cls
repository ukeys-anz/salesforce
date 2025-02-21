/**
 * @author Mani
 * @since 12/2024
 * @description This acts as a repository layer for ProfileUpdateCaseActions to retrieve data using SOQL
 */
public with sharing class ProfileUpdateCaseRepository {
  /**
   * @description Get list of Legal name cases By Ids
   * @param caseIds set of Case Ids
   * @return List<Case> list of Legal name cases
   */
  public List<Case> getLegalNameCaseForNotification(Set<Id> caseIds) {
<<<<<<< HEAD
    if (caseIds.isEmpty() || !SObjectType.Case.isQueryable()) {
=======
    if (caseIds.isEmpty()) {
>>>>>>> develop
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        CaseNumber,
        CreatedDate,
        Status,
        Sub_Status__c,
        Type,
        Subject,
        Origin,
        Priority,
        Description,
        ClosedDate,
        NewFirstName__c,
        NewMiddleName__c,
        NewLastName__c,
        DocumentType__c,
        Daon_Document_Id__c,
        Daon_Check_Id__c,
        Daon_User_Id__c,
        Aegis_Workflow_Id__c,
        AcceptableDocumentType__c,
        AcceptableDocumentQuality__c,
        DocumentFailureReason__c,
        LinkBetweenOldIdentityAndNewName__c,
        NameOnIDMatchesTheNameRequested__c,
        PhotoOnIDMatchesSelfieOnFile__c,
        DateOfBirthOnIDMatchesProfile__c,
        CertificateShowsCurrentContactName__c,
        Fraud_Review_Outcome__c,
        NamesCertificateSupportNameRequested__c,
        CertificateIdentifierType__c,
        PassportNumber__c,
        LicenceNumber__c,
        LicenceCardNumber__c,
        NameCorrection__c,
        CertificateIdentifier__c,
        RegistrationDate__c,
        ExpiryDate__c,
        StateCode__c,
        CountryCode__c,
        VerificationRequest__c,
        VerificationOutcome__c,
        LastModifiedDate,
        LastModifiedBy.Name,
        LastModifiedBy.Email,
        LastModifiedBy.Username,
        Account.OCV_ID__c,
        Account.Source_System_Name__c,
        Account.Source_System_ID__c,
        TYPEOF Owner
          WHEN User THEN Id, Name, Email, Username
          WHEN Group THEN Id, Name, Email
        END
      FROM Case
      WHERE Id IN :caseIds
<<<<<<< HEAD
=======
      WITH USER_MODE
    ];
  }

  /**
   * @description Get list of Accounts by account Ids
   * @param accountIds set of Case Ids
   * @return List<Account> list of Account records
   */
  public List<Account> getAccounts(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        FirstName,
        MiddleName,
        LastName,
        OCV_ID__c,
        Source_System_ID__c,
        Source_System_Name__c
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
>>>>>>> develop
    ];
  }
}
