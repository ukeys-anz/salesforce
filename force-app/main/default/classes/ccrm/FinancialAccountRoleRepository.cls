/**
 * @author Mildeep Singh
 * @since  01/2025
 * @description This class contains public repository for all queries used in CCRMFinancialAccountRoleActions
 */
public with sharing class FinancialAccountRoleRepository {
  /**
   * @description get active FAR records from combination of related account and financial accounts
   * @param relatedAccounts set of related account ids from FAR
   * @param relatedFinancialAccounts set of financial account ids
   * @return List<FinServ__FinancialAccountRole__c> FinServ__FinancialAccountRole__c list
   */
  public List<FinServ__FinancialAccountRole__c> getActiveFinancialAccountRoleRecords(
    Set<Id> relatedAccounts,
    Set<Id> relatedFinancialAccounts
  ) {
    if (relatedAccounts.isEmpty() || relatedFinancialAccounts.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }
    return [
      SELECT Id, FinServ__RelatedAccount__c,
      FinServ__FinancialAccount__c,
      FinServ__FinancialAccount__r.Account_Key__c,
      FinServ__RelatedAccount__r.External_Id__c 
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c IN :relatedAccounts
        AND FinServ__FinancialAccount__c IN :relatedFinancialAccounts
        AND FinServ__Active__c = TRUE
      WITH USER_MODE
    ];
  }
}