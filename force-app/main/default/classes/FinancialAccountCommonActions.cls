/**
 *
 * @author Jasmine Nguyen
 * @since 03/2021
 * @description Common Financial Account Action methods
 */

public with sharing class FinancialAccountCommonActions {
  /** 
    @description beforeUpdate(oldMap, records) method handles the following
   * 1. checkPrimaryOwnerStartDate - check if the Primary_Owner_Start_Date__c is updated simultaneously with FinServ__PrimaryOwner__c
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in onBeforeUpdate.
   * @param records The Financial Account records passed from beforeUpdate()
   */
  public static void beforeUpdate(
    Map<Id, SObject> oldMap,
    List<FinServ__FinancialAccount__c> records
  ) {
    Map<Id, FinServ__FinancialAccount__c> financialAccountOldMap = new Map<Id, FinServ__FinancialAccount__c>();
    for (SObject record : oldMap.values()) {
      FinServ__FinancialAccount__c oldRecord = (FinServ__FinancialAccount__c) oldMap.get(
        record.id
      );
      financialAccountOldMap.put(oldRecord.Id, oldRecord);
    }

    resetPrimaryOwner(records, (Map<Id, FinServ__FinancialAccount__c>) oldMap);
    checkPrimaryOwnerStartDate(financialAccountOldMap, records);
  }

  /**
   * @description This method reset the Primary Owner to previous owner if there is new primary owner with IsPrimaryOwner__c = False
   * @param financialAccounts The Financial Account records passed from beforeUpdate()
   * @param oldFinancialAccounts Map of old Financial Account records
   */
  private static void resetPrimaryOwner(
    List<FinServ__FinancialAccount__c> financialAccounts,
    Map<Id, FinServ__FinancialAccount__c> oldFinancialAccounts
  ) {
    Set<Id> financialAccountIds = new Set<Id>();
    for (FinServ__FinancialAccount__c financialAccount : financialAccounts) {
      if (
        !financialAccount.IsPrimaryOwner__c &&
        oldFinancialAccounts.containsKey(financialAccount.id)
      ) {
        //Get Ids to delete FAR inactive records associated to Financial Account
        financialAccountIds.add(financialAccount.Id);
        FinServ__FinancialAccount__c financialAccountOldRecord = (FinServ__FinancialAccount__c) oldFinancialAccounts.get(
          financialAccount.id
        );
        financialAccount.FinServ__PrimaryOwner__c = financialAccountOldRecord.FinServ__PrimaryOwner__c;
      }
    }
    //FSC package create new FAR record and old FAR record get inactive.
    //Delete inactive FAR record
    if (!financialAccountIds.isEmpty()) {
      ManageInactiveFinancialAccountRole.deleteInActiveFinancialAccountRole(
        financialAccountIds
      );
    }
  }

  /**
   * @description checkPrimaryOwnerStartDate is called to check if the Primary_Owner_Start_Date__c is updated simultaneously with FinServ__PrimaryOwner__c
   * @param oldMap Map of old Financial Account records
   * @param records The Financial Account records passed from beforeUpdate()
   */
  public static void checkPrimaryOwnerStartDate(
    Map<Id, FinServ__FinancialAccount__c> oldMap,
    List<FinServ__FinancialAccount__c> records
  ) {
    for (FinServ__FinancialAccount__c record : records) {
      FinServ__FinancialAccount__c oldRecord = oldMap.get(record.Id);
      if (
        // Primary owner is updated and the date isn't set
        oldRecord.FinServ__PrimaryOwner__c != record.FinServ__PrimaryOwner__c &&
        record.Primary_Owner_Start_Date__c ==
        null /*||
        // Primary owner start date is updated without updating primary owner
        (oldRecord.Primary_Owner_Start_Date__c !=
        record.Primary_Owner_Start_Date__c &&
        oldRecord.FinServ__PrimaryOwner__c == record.FinServ__PrimaryOwner__c)*/
      ) {
        String errorMessage =
          'Primary owner start date cannot be empty. Financial Account Id: ' +
          record.Id;
        record.addError(errorMessage);
        Logger.error(errorMessage);
      }
    }
    Logger.saveLog();
  }
}
