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
   * @return Account
   */
  @AuraEnabled
  public static Account getTotalBalance(Id ownerId) {
    Account acc;
    if (Account.sObjectType.getDescribe().isQueryable()) {
      acc = [
        SELECT Id, FinServ__TotalFinAcctsPrimaryOwner__c
        FROM Account
        WHERE Id = :ownerId
      ];
    }

    return acc;
  }
}
