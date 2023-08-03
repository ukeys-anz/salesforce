/**
 *
 * @author Lance Shi
 * @since 2020
 * @description TotalBalanceController is the apex side controller for the totalBalance LWC
 */
public with sharing class TotalBalanceController {
  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static AggregateResult getTotalBalance(Id ownerId) {
    AggregateResult totalBalance;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()
    ) {
      totalBalance = [
        SELECT SUM(FinServ__Balance__c) totalBalance
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__Balance__c != NULL
          AND FinServ__PrimaryOwner__c = :ownerId
          AND (RecordTypeId = :GetHelpConstants.SAVINGS_ACCOUNT_RT_ID
          OR RecordTypeId = :GetHelpConstants.CHECKING_ACCOUNT_RT_ID)
          AND (FinServ__Status__c = 'Active'
          OR FinServ__Status__c = 'Open')
      ];
    }

    return totalBalance;
  }

  /**
   * @description The total balance component uses this to fetch the records to display.
   *
   * @param ownerId the id of the owner of the financial account
   * @return AggregateResult
   */
  @AuraEnabled
  public static AggregateResult getTotalSaved(Id ownerId) {
    AggregateResult totalSaved;
    if (
      FeatureManagement.checkPermission('ANZx_Accounts_and_Goals') &&
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable()
    ) {
      totalSaved = [
        SELECT SUM(FinServ__Balance__c) totalSaved
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__Balance__c != NULL
          AND FinServ__PrimaryOwner__c = :ownerId
          AND RecordTypeId = :GetHelpConstants.SAVINGS_ACCOUNT_RT_ID
          AND (FinServ__Status__c = 'Active'
          OR FinServ__Status__c = 'Open')
      ];
    }

    return totalSaved;
  }
}
