/**
 * @author Batya Aisman Sufrin
 * @since 06/2024
 * @description  AutoKYCQACaseRepository is the repository class for KYC QA Case Actions.
 */
public with sharing class AutoKYCQACaseRepository {
  /**
   * @description Get list of COBs By persona Ids
   * @param personaIds set of persona Ids
   * @return List<CustomerOnboardingApplication__c> list of COBs
   */
  public List<CustomerOnboardingApplication__c> queryCOBByPersonaId(
    Set<String> personaIds
  ) {
    if (
      personaIds.isEmpty() ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false
    ) {
      return new List<CustomerOnboardingApplication__c>();
    }
    return [
      SELECT PersonaId__c, VerificationType__c
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ];
  }

  /**
   * @description Get list of COBs with COBPID By persona Ids
   * @param personaIds set of persona Ids
   * @return List<CustomerOnboardingApplication__c> list of COBs with COBPID
   */
  public List<CustomerOnboardingApplication__c> queryCOBWithPIDByPersonaId(
    Set<String> personaIds
  ) {
    if (
      personaIds.isEmpty() ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false ||
      SObjectType.COBPrimaryIDDocument__c.isQueryable() == false
    ) {
      return new List<CustomerOnboardingApplication__c>();
    }
    return [
      SELECT
        PersonaId__c,
        (
          SELECT
            Id,
            IdDocumentType__c,
            CustomerOnboardingApplication__c,
            FirstName__c,
            FirstNameOCRServer__c,
            FirstNameOCRMatch__c,
            MiddleNames__c,
            MiddleNamesOCRServer__c,
            MiddleNamesOCRMatch__c,
            LastName__c,
            LastNameOCRServer__c,
            LastNameOCRMatch__c,
            LicenceNumberOCRMatch__c,
            LicenceCardNumberOCRMatch__c,
            PassportNumberOCRMatch__c,
            DateOfBirthOCRMatch__c,
            ExpiryDateOCRMatch__c
          FROM COBPrimaryIDDocuments__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ];
  }

  /**
   * @description Get list of COBs with COBAddress By persona Ids
   * @param personaIds set of persona Ids
   * @param addressType address type
   * @return List<CustomerOnboardingApplication__c> list of COBs with COBAddress
   */
  public List<CustomerOnboardingApplication__c> queryCOBWithCOBAddressByAddresTypeAndPersonaId(
    Set<String> personaIds,
    String addressType
  ) {
    if (
      personaIds.isEmpty() ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false ||
      SObjectType.COBAddress__c.isQueryable() == false
    ) {
      return new List<CustomerOnboardingApplication__c>();
    }
    return [
      SELECT
        PersonaId__c,
        (
          SELECT Id, CustomerOnboardingApplication__c, QASAddress__c
          FROM COBAddresses__r
          WHERE AddressType__c = :addressType
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE PersonaId__c IN :personaIds
    ];
  }

  /**
   * @description Get list of KYC QA cases By account Ids
   * @param accountIds set of account Ids
   * @return List<Case> list of KYC QA cases
   */
  public List<Case> queryKYCQACasesByAccountIds(Set<Id> accountIds) {
    if (accountIds.isEmpty() || !SObjectType.Case.isQueryable()) {
      return new List<Case>();
    }
    return [
      SELECT Id, CaseNumber, AccountId
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND AccountId IN :accountIds
    ];
  }

  /**
   * @description Get list of KYC QA cases By COB application Ids
   * @param cobAppIds set of COB application Ids
   * @return List<Case> list of KYC QA cases
   */
  public List<Case> queryKYCQACasesByCOBAppIds(Set<Id> cobAppIds) {
    if (cobAppIds.isEmpty() || SObjectType.Case.isQueryable() == false) {
      return new List<Case>();
    }
    return [
      SELECT Id, CaseNumber, CustomerOnboardingApplication__c
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
        AND Status != :GetHelpConstants.CLOSED_STATUS
        AND CustomerOnboardingApplication__c IN :cobAppIds
    ];
  }

  /**
   * @description Get list of Accounts By account Ids
   * @param accountIds set of account Ids
   * @return List<Account> list of Accounts
   */
  public List<Account> queryAccounts(Set<Id> accountIds) {
    if (accountIds.isEmpty() || SObjectType.Account.isQueryable() == false) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        FinServ__KYCStatus__c,
        KYC_Verification_Level__c,
        CustomerExitFlag__c
      FROM Account
      WHERE Id IN :accountIds
    ];
  }
}
