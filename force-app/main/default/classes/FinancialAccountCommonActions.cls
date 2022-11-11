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

    checkPrimaryOwnerStartDate(financialAccountOldMap, records);
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
        Lib_SystemLog.createSingleLogAsync(
          FinancialAccountCommonActions.class.getName(),
          'checkPrimaryOwnerStartDate',
          '',
          errorMessage
        );
      }
    }
  }
}
