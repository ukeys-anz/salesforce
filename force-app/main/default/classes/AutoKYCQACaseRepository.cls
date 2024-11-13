/**
 * @author Batya Aisman Sufrin
 * @since 06/2024
 * @description  AutoKYCQACaseRepository is the repository class for KYC QA Case Actions.
 */
public with sharing class AutoKYCQACaseRepository {
  static final Set<String> FA_CODES = new Set<String>{
    'TRANSACT01',
    'SAVING01'
  };
  /**
   * @description Get list of COBs By persona Ids
   * @param personaIds set of persona Ids
   * @return List<CustomerOnboardingApplication__c> list of COBs
   */
  public List<CustomerOnboardingApplication__c> queryCobsByPersonaIds(
    Set<String> personaIds
  ) {
    if (
      personaIds.isEmpty() ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false
    ) {
      return new List<CustomerOnboardingApplication__c>();
    }
    return [
      SELECT
        PersonaId__c,
        VerificationType__c,
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
        ),
        (
          SELECT Id, CustomerOnboardingApplication__c, QASAddress__c
          FROM COBAddresses__r
          WHERE AddressType__c = 'Current'
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
        RecordTypeId = :RTCase.kycQa
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
        RecordTypeId = :RTCase.kycQa
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
        (
          SELECT Id, FinServ__FinancialAccountNumber__c, Product_Type__c
          FROM FinServ__ClientFinancialAccounts__r
          WHERE Marketing_Code__c IN :FA_CODES AND FinServ__Status__c = 'Active'
        )
      FROM Account
      WHERE Id IN :accountIds
    ];
  }

  /**
   * @description Get list of not-exited Accounts By account Ids
   * @param accountIds set of account Ids
   * @return List<Account> list of Accounts
   */
  public List<Account> queryAccountsNotExited(Set<Id> accountIds) {
    if (accountIds.isEmpty() || SObjectType.Account.isQueryable() == false) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        OCV_ID__c,
        FinServ__KYCStatus__c,
        KYC_Verification_Level__c,
        (
          SELECT
            Customer_Name__c,
            LastModifiedDate,
            Name,
            NewValue__c,
            Occurrence_Number__c,
            ToBeValue__c,
            TriggeredFrom__c
          FROM Customer_Profile_Updates__r
          WHERE
            TriggeredFrom__c = 'Case.KYC_QA.AddRestraints'
            AND Status__c = 'Completed'
          ORDER BY CreatedDate DESC
        )
      FROM Account
      WHERE Id IN :accountIds AND CustomerExitFlag__c = FALSE
    ];
  }

  /**
   * @description Queries the Account IDs of exited accounts based on the provided OCV IDs.
   * @param ocvIds A set of OCV IDs to query the exited accounts.
   * @return A set of Account IDs of exited accounts.
   */
  public List<Account> queryExitedAccountsByOcvIds(Set<String> ocvIds) {
    return new SystemAction().queryExitedAccountsByOcvIds(ocvIds);
  }

  /**
   * @description Queries Customer Onboarding Applications with the latest ID Ops Assistance Case.
   * @param cobIds A set of Customer Onboarding Application record IDs.
   * @return A list of Customer Onboarding Application records with the latest ID Ops Assistance Case.
   */
  public List<CustomerOnboardingApplication__c> queryCobsWithLatestIdOpsCase(
    Set<Id> cobIds
  ) {
    if (
      cobIds.isEmpty() ||
      SObjectType.CustomerOnboardingApplication__c.isQueryable() == false
    ) {
      return new List<CustomerOnboardingApplication__c>();
    }
    return [
      SELECT
        (
          SELECT OwnerId
          FROM Cases__r
          WHERE RecordTypeId = :RTCase.idOpsAssistance
          ORDER BY LastModifiedDate DESC
          LIMIT 1
        )
      FROM CustomerOnboardingApplication__c
      WHERE Id IN :cobIds
    ];
  }

  /**
   * @description Retrieves KYC QA Check Fields.
   * @param caseIds A list of KYC QA Case IDs.
   * @return A list of KYC QA case records with all the check fields.
   */
  public List<Case> queryKYCQAChecksByIds(Set<Id> caseIds) {
    if (caseIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        Id,
        Fraud_Customer_Details__c,
        Fraud_MiddleNameCheck__c,
        Fraud_Selfie_Comparison_Match__c,
        Fraud_PO_Box__c,
        Fraud_Address_Valid__c,
        Fraud_ID_Legible__c,
        Fraud_ID_Not_Picture__c,
        Fraud_Customer_Photo_Modified__c,
        Fraud_Security_Features__c
      FROM Case
      WHERE Id IN :caseIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Queries the Account records with the Customer Profile Updates and KYC QA Cases.
   * @param accountIds A set of Account IDs to query the records for.
   * @return A list of Account records with the Customer Profile Updates and KYC QA Cases.
   */
  public List<Account> queryAccountsWithCpuAndKYCQaCases(Set<Id> accountIds) {
    return new SystemAction().queryAccountsWithCpuAndKYCQaCases(accountIds);
  }

  /**
   * @description Checks if the restraint feature is enabled.
   * @return Boolean value indicating if the restraint is enabled.
   */
  public Boolean isRestraintEnabled() {
    return Label.CustomerRestraintEnabled.equalsIgnoreCase('true');
  }

  /**
   * @description This class take care of Database operation that requires without sharing operation
   */
  private without sharing class SystemAction {
    /**
     * @description Queries exited accounts by the specified OCV IDs. Users need to find AR&C accounts that has same OCV ID as ANZX customers.
     * @param ocvIds A set of OCV IDs to query accounts for.
     * @return A list of Account records that match the specified OCV IDs and have the CustomerExitFlag__c field set to TRUE.
     */
    public List<Account> queryExitedAccountsByOcvIds(Set<String> ocvIds) {
      if (ocvIds.isEmpty()) {
        return new List<Account>();
      }
      return [
        SELECT Id, OCV_ID__c
        FROM Account
        WHERE OCV_ID__c IN :ocvIds AND CustomerExitFlag__c = TRUE
        WITH SYSTEM_MODE
      ];
    }

    /**
     * @description Queries the Account records with the Customer Profile Updates and KYC QA Cases.
     * @param accountIds A set of Account IDs to query the records for.
     * @return A list of Account records with the Customer Profile Updates and KYC QA Cases.
     */
    public List<Account> queryAccountsWithCpuAndKYCQaCases(Set<Id> accountIds) {
      if (accountIds.isEmpty()) {
        return new List<Account>();
      }
      return [
        SELECT
          Id,
          (
            SELECT Id, Status__c, TriggeredFrom__c
            FROM Customer_Profile_Updates__r
          ),
          (
            SELECT Id, Fraud_Restraint_Status__c, LastModifiedDate
            FROM Cases
            WHERE RecordTypeId = :RTCase.kycQa
            ORDER BY LastModifiedDate DESC
            LIMIT 1
          )
        FROM Account
        WHERE Id IN :accountIds
        WITH SYSTEM_MODE
      ];
    }
  }
}
