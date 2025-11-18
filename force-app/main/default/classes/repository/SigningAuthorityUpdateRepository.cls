/**
 * @author Hrushikesh Pathak
 * @since 09/2025
 * @description SigningAuthorityUpdateRepository is a class used for the Signing Authority SOQL.
 */
public with sharing class SigningAuthorityUpdateRepository {
  /**
   * @description Method to retrieve financial Accounts by OCV Id
   * @param ocvId OCV Id of Customer
   * @param numberOfSignatures Number Of Signatures
   * @return List<FinServ__FinancialAccount__c> A list of financial accounts
   */
  public List<FinServ__FinancialAccount__c> getFinancialAccountByOcvId(
    String ocvId,
    String numberOfSignatures
  ) {
    if (String.isBlank(ocvId) || String.isBlank(numberOfSignatures)) {
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
        FinServ__ProductName__r.Name,
        Number_Of_Signatures__c
      FROM FinServ__FinancialAccount__c
      WHERE
        FinServ__ProductName__r.ANZ_Product_Code__c IN :QueryFinancialAccountUIConfig.configByProductCode.keySet()
        AND FinServ__ProductName__r.SourceSystem__c = 'Zafin'
        AND Id IN (
          SELECT FinServ__FinancialAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__RelatedAccount__r.OCV_ID__c = :ocvId
            AND FinServ__Active__c = TRUE
        )
        AND Number_of_Signatures__c = :numberOfSignatures
        AND Ownership__c = 'Multi-party'
        AND FinServ__Status__c != :CaseGroupCaseConstants.CLOSED_STATUS
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves list of financial accounts
   * @param accountIds the Financial Account Ids
   * @return List<FinServ__FinancialAccount__c> list of FinServ__FinancialAccount__c
   */
  public List<FinServ__FinancialAccount__c> getFinancialAccountsWithCaseId(
    Set<Id> accountIds
  ) {
    if (accountIds.isEmpty()) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT Id, FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE Id IN :accountIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get Manager Info
   * @param ownerIdSet set of Lead owner ids
   * @return List<User> User list
   **/
  public List<User> getManagerInfo(Set<Id> ownerIdSet) {
    if (ownerIdSet.isEmpty()) {
      return new List<User>();
    }

    return [
      SELECT Id, ManagerId, IsActive
      FROM User
      WHERE IsActive = TRUE AND Id IN :ownerIdSet AND ManagerId != NULL
      WITH USER_MODE
    ];
  }

  /**
   * @description Get a list of account Ids from general enquiry cases
   * @param accountIds a list of account Ids
   * @param name name of the entitilement
   * @return List of Entitlements for the accounts
   */
  public List<Entitlement> getEntitlements(Set<Id> accountIds, String name) {
    if (accountIds.isEmpty()) {
      return new List<Entitlement>();
    }
    return [
      SELECT Id, AccountId
      FROM Entitlement
      WHERE AccountId IN :accountIds AND EndDate = NULL AND Name = :name
      WITH SYSTEM_MODE
    ];
  }
}
