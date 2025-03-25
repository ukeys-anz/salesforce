/**
 * @author Aman Gupta
 * @since 02/2025
 * @description Repository class for managing Confirmation of Payee (CoP) case actions and related financial account data.
 */
public with sharing class ConfirmationOfPayeeRepository {
  /**
   * @description Retrieves a list of CoP-related cases linked to the given financial account numbers.
   * @param finAccNumbers A set of financial account numbers used to filter cases.
   * @param parentCaseId The ID of the parent case under which CoP cases are linked.
   * @return List<Case> A list of cases associated with the provided financial accounts.
   */
  public List<Case> getCasesByFinancialAccountIds(
    Set<String> finAccNumbers,
    Id parentCaseId
  ) {
    if (parentCaseId == null || finAccNumbers.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c IN :finAccNumbers
        AND RecordTypeId = :RTCase.confirmationOfPayee
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves a list of CoP-related cases associated with a specific parent case ID.
   * @param parentCaseId The ID of the parent case.
   * @return List<Case> A list of cases linked to the given parent case ID.
   */
  public List<Case> getCasesByParentId(Id parentCaseId) {
    if (parentCaseId == null) {
      return new List<Case>();
    }
    return [
      SELECT
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        FinServ__FinancialAccount__r.FinServ__ProductName__c,
        FinServ__FinancialAccount__r.Product_Name__c,
        Product.Name,
        FinServ__FinancialAccount__r.Ownership__c,
        FinServ__FinancialAccount__r.BSB__c,
        Customer_Account_Number__c,
        Parent.Type,
        Account.OCV_Id__c,
        Opt_Out_Reason__c,
        CaseNumber,
        SI_PSI_Source_Other__c,
        Sub_Status__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND Status = :CaseGroupCaseConstants.ESCALATED_STATUS
        AND RecordTypeId = :RTCase.confirmationOfPayee
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves financial accounts based on the provided OCV ID.
   * @param ocvId The OCV ID of the primary owner of the financial accounts.
   * @return List<FinServ__FinancialAccount__c> A list of financial accounts associated with the given OCV ID.
   */
  public List<FinServ__FinancialAccount__c> fetchFinancialAccountsByOCVId(
    String ocvId
  ) {
    if (String.isBlank(ocvId)) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        Id,
        FinServ__FinancialAccountNumber__c,
        BSB__c,
        FinServ__ProductName__c,
        Product_Name__c,
        Ownership__c,
        FinServ__ProductName__r.Name
      FROM FinServ__FinancialAccount__c
      WHERE
        RecordTypeId != :RTFinancialAccount.bankAccount
        AND Id IN (
          SELECT FinServ__FinancialAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__RelatedAccount__r.OCV_ID__c = :ocvId
            AND FinServ__Active__c = TRUE
        )
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves a single financial account record based on its ID.
   * @param recordId The ID of the financial account.
   * @return FinServ__FinancialAccount__c The financial account record matching the given ID.
   */
  public FinServ__FinancialAccount__c getFinancialAccountById(Id recordId) {
    if (recordId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        FinServ__FinancialAccountNumber__c,
        BSB__c,
        FinServ__PrimaryOwner__r.OCV_ID__c,
        FinServ__ProductName__c,
        Product_Name__c,
        Ownership__c
      FROM FinServ__FinancialAccount__c
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Retrieves a list of users based on their LAN IDs.
   * @param lanIds A set of LAN IDs used to query users.
   * @return List<User> A list of User records that match the given LAN IDs.
   */
  public List<User> getUsersByLANId(Set<String> lanIds) {
    if (lanIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Name, Lan_Id__c
      FROM User
      WHERE Lan_Id__c IN :lanIds
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Retrieves a list of accounts based on their OCV IDs.
   * @param ocvIds A list of OCV IDs used to query accounts.
   * @return List<Account> A list of Account records that match the provided OCV IDs.
   */
  public List<Account> getAccountsByOcvIds(List<String> ocvIds) {
    if (ocvIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, OCV_Id__c
      FROM Account
      WHERE OCV_Id__c IN :ocvIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves a list of financial accounts roles based on their account numbers.
   * @param accountNumbers A list of account numbers used to query accounts roles.
   * @return List<FinServ__FinancialAccountRole__c> A list of Account records that match the provided OCV IDs.
   */
  public List<FinServ__FinancialAccountRole__c> getFinAccountRolesByAccountNum(
    Set<String> accountNumbers
  ) {
    if (accountNumbers.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT
        Id,
        Name,
        FinServ__RelatedAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        Account_Number__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__Active__c = TRUE
        AND FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c IN :accountNumbers
      WITH USER_MODE
    ];
  }
}
