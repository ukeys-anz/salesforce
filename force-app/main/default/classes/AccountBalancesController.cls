/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description AccountBalancesController is the apex side controller for the financialAccount LWC
 */
public with sharing class AccountBalancesController {
  /**
   * @description The Account Balances component uses this to fetch the record data to display.
   *
   * @param recordId the id of the financial account
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getBalances(Id recordId) {
    List<FinServ__FinancialAccount__c> financialAccount;
    if (FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()) {
      financialAccount = [
        SELECT Id, FinServ__Balance__c, LastModifiedDate
        FROM FinServ__FinancialAccount__c
        WHERE Id = :recordId
      ];
    }

    if (financialAccount.isEmpty()) {
      return null;
    }

    return financialAccount;
  }
}
