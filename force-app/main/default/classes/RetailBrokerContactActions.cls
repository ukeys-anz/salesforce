/**
 * @author Zhiren Jason Guan
 * @since  13/02/2024
 * @description Retail Broker related trigger actions class
 * @runTests  RetailBrokerContactActionsTest
 */

public with sharing class RetailBrokerContactActions {
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';

  /**
   * @description Generate and dispatch Broker related GCP cloud events
   * This function is designed to be a void function as it's the end of the publish process.
   * It trusts the CloudEventController.publishCloudEvents to complete the publish job
   * @param records map of new contacts from trigger context
   * @param oldMap map of old contacts from trigger context
   */
  public static void publishBrokerGCPEvents(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    Map<Id, String> brokerIdToEventTypeMap = new Map<Id, String>();
    for (Contact record : records) {
      Contact oldRecord = oldMap.get(record.Id);
      if (isBrokerAdded(record, oldRecord)) {
        brokerIdToEventTypeMap.put(
          record.Id,
          RetailBrokerGCPActions.GCP_EVENT_ADD
        );
      } else if (isBrokerUpdated(record, oldRecord)) {
        brokerIdToEventTypeMap.put(
          record.Id,
          RetailBrokerGCPActions.GCP_EVENT_UPDATE
        );
      }
    }
    RetailBrokerGCPActions.publishGCPEventForBrokers(brokerIdToEventTypeMap);
  }

  /**
   * @description Process contact record updates for OCV sync
   * @param records List of new records in trigger context
   * @param oldMap Old record map in trigger context
   * @return List of records updated
   */
  public static List<Contact> processOCVSync(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    List<Contact> contactList = new List<Contact>();
    for (Contact record : records) {
      Contact oldRecord = oldMap.get(record.Id);
      if (isSyncStatusEligibleForUpdate(record, oldRecord)) {
        record.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
          record.Sync_Status__c,
          SYNC_STATUS_BROKER_ORG
        );
        contactList.add(record);
      }
    }
    return contactList;
  }

  /**
   * @description Indicate if record is eligible for GCP Add Event
   * @param record New Contact record from trigger context
   * @param oldRecord Old Contact record from trigger context
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isBrokerAdded(Contact record, Contact oldRecord) {
    Boolean isVersionValid =
      record.OCV_Event_Version__c > 0 &&
      (oldRecord.OCV_Event_Version__c == null ||
      oldRecord.OCV_Event_Version__c <= 0);
    if (isVersionValid == false) {
      return false;
    }
    Boolean isNewSyncStatusValid =
      record.Sync_Status__c != null &&
      record.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG);
    if (isNewSyncStatusValid == false) {
      return false;
    }
    Boolean isOldSyncStatusValid =
      oldRecord.Sync_Status__c == null ||
      oldRecord.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG) == false;
    if (isOldSyncStatusValid == false) {
      return false;
    }
    return true;
  }

  /**
   * @description Indicate if record is eligible for GCP Update Event
   * @param record New Contact record from trigger context
   * @param oldRecord Old Contact record from trigger context
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isBrokerUpdated(Contact record, Contact oldRecord) {
    Boolean isVersionValid =
      record.OCV_Event_Version__c > 0 &&
      record.OCV_Event_Version__c >= oldRecord.OCV_Event_Version__c;
    if (isVersionValid == false) {
      return false;
    }
    Boolean isSyncStatusValid =
      record.Sync_Status__c != null &&
      record.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG);
    if (isSyncStatusValid == false) {
      return false;
    }
    Boolean isOldSyncStatusValid =
      oldRecord.Sync_Status__c != null &&
      oldRecord.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG);
    if (isOldSyncStatusValid == false) {
      return false;
    }
    return true;
  }

  @TestVisible
  private static Boolean isSyncStatusEligibleForUpdate(
    Contact record,
    Contact oldRecord
  ) {
    Boolean isVersionValid =
      record.OCV_Event_Version__c > 0 &&
      (oldRecord.OCV_Event_Version__c == null ||
      oldRecord.OCV_Event_Version__c <= 0);
    if (isVersionValid == false) {
      return false;
    }
    Boolean isOldSyncStatusValid =
      oldRecord.Sync_Status__c == null ||
      oldRecord.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG) == false;
    if (isOldSyncStatusValid == false) {
      return false;
    }
    Boolean isNewSyncStatusValid =
      record.Sync_Status__c == null ||
      (record.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG) == false &&
      record.Sync_Status__c.contains(SYNC_STATUS_BLOCKED) == false);
    if (isNewSyncStatusValid == false) {
      return false;
    }
    return true;
  }
}
