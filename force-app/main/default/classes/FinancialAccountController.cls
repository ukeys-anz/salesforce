/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialAccountController retrieves account details for the EverydayAccount LWC and the FinancialGoals LWC
 */
public with sharing class FinancialAccountController {
  /**
   * @description The Everyday Account component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @param recordLimit the amount of records to retrieve
   * @param type the account type to retrieve
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFinancialAccounts(
    String ownerId,
    Integer recordLimit,
    String type
  ) {
    List<FinServ__FinancialAccount__c> financialAccount;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()
    ) {
      financialAccount = [
        SELECT
          Id,
          Name,
          FinServ__Balance__c,
          FinServ__Status__c,
          FinServ__FinancialAccountNumber__c,
          LastModifiedDate
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND FinServ__FinancialAccountType__c = :type
        ORDER BY FinServ__OpenDate__c DESC, FinServ__Status__c ASC
        LIMIT :recordLimit
      ];
    }

    if (financialAccount.isEmpty()) {
      return null;
    }

    return financialAccount;
  }
}
