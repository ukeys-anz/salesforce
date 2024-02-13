/**
 * @author Zhiren Jason Guan
 * @since 15/12/2023
 * @description Data Processor for Account Object
 * @runTests AccountProcessorTest
 */

public with sharing class AccountOCVSyncProcessor {
  public static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  public static final String SYNC_STATUS_BLOCKED = 'Blocked';

  /**
   * @description Process account record updates when OCV Event Version changed
   * @param records List of new records in trigger context
   * @param oldMap Old record map in trigger context
   * @return List of records updated
   */
  public static List<Account> updateRecordsForOCVVersionChanged(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    List<Account> accountList = new List<Account>();
    for (Account record : records) {
      Account oldRecord = oldMap.get(record.Id);
      if (isEligibleToUpdateSyncStatus(record, oldRecord)) {
        // Multipicklist value aggregation
        List<String> values = String.isBlank(record.Sync_Status__c)
          ? new List<String>()
          : record.Sync_Status__c.split(';');
        values.add(SYNC_STATUS_BROKER_ORG);
        record.Sync_Status__c = String.join(values, ';');
        accountList.add(record);
      }
    }
    return accountList;
  }

  /**
   * @description Eligibility Definition: When OCV_Event_Version__c is changed and the Sync_Status__c multi-picklist value does not contain "Broker Org"
   * @param record New Account record from trigger context
   * @param oldRecord Old Account record from trigger context
   * @return Boolean to indicate the eligibility of the account record
   */
  private static Boolean isEligibleToUpdateSyncStatus(
    Account record,
    Account oldRecord
  ) {
    if (record.OCV_Event_Version__c == oldRecord.OCV_Event_Version__c) {
      return false;
    }
    if (String.isBlank(record.Sync_Status__c)) {
      return true;
    }
    if (
      !record.Sync_Status__c.contains(SYNC_STATUS_BLOCKED) &&
      !record.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG)
    ) {
      return true;
    }
    return false;
  }
}
