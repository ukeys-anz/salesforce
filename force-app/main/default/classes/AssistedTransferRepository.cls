/**
 * @author Sanskriti Routray
 * @since 10/2025
 * @description AssistedTransferRepository is a class used for the Assisted Transfer case SOQL.
 */
public with sharing class AssistedTransferRepository {
  /**
   * @description Method to retrieve financial Accounts by OCV Id
   * @param ocvId OCV Id of Customer
   * @return List<FinServ__FinancialAccount__c> A list of financial accounts
   */
  public List<FinServ__FinancialAccount__c> getFinancialAccountByOcvId(
    String ocvId
  ) {
    if (String.isBlank(ocvId)) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        Id,
        Name,
        FinServ__FinancialAccountNumber__c,
        BSB__c,
        FinServ__ProductName__c,
        Product_Name__c,
        Ownership__c,
        FinServ__ProductName__r.Name,
        FinServ__FinancialAccountType__c,
        FinServ__Balance__c
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
        AND FinServ__Status__c != :CaseGroupCaseConstants.CLOSED_STATUS
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
