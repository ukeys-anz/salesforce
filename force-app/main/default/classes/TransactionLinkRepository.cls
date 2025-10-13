/**
 * @author Batya Aisman Sufrin
 * @since Aug 2025
 * @description Repository class for managing transaction links
 */
public with sharing class TransactionLinkRepository {
  /**
   * @description Query ANZx Account Roles
   * @param accId The ID of the account to query roles for
   * @return A list of financial account roles
   */
  public List<FinServ__FinancialAccountRole__c> queryANZxAccountRoles(
    Id accId
  ) {
    if (accId == null) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    return [
      SELECT
        Id,
        FinServ__Role__c,
        Ownership__c,
        Product_Name_Display__c,
        Account_Number__c,
        FinServ__FinancialAccount__r.OCV_ID__c,
        FinServ__FinancialAccount__r.FinServ__Status__c
      FROM FinServ__FinancialAccountRole__c
      WHERE Is_ANZx_Account__c = TRUE AND FinServ__RelatedAccount__c = :accId
      WITH USER_MODE
    ];
  }
}
