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
   * @description Generate and publish Broker contact GCP cloud events
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   */
  public static void publishBrokerEvents(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    Map<Id, String> brokerIdToEventTypeMap = getBrokerIdToEventTypeMap(
      records,
      contactsOldMap
    );
    RetailBrokerEventActions.publishEventForBrokers(brokerIdToEventTypeMap);
  }

  /**
   * @description Generate and publish Broker contact GCP cloud events
   * @param contactsNew list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return Map<Id, String> filtered map of ids and contacts elgible for publishing
   */
  private static Map<Id, String> getBrokerIdToEventTypeMap(
    List<Contact> contactsNew,
    Map<Id, Contact> contactsOldMap
  ) {
    Map<Id, String> brokerIdToEventTypeMap = new Map<Id, String>();
    for (Contact contactNew : contactsNew) {
      Contact contactOld = contactsOldMap.get(contactNew.Id);
      String action = getAction(contactNew, contactOld);
      if (String.isBlank(action)) {
        continue;
      }
      Boolean isSyncStatusValidForPublishing = isSyncStatusValidForPublishing(
        contactNew,
        contactOld,
        action
      );
      if (isSyncStatusValidForPublishing == false) {
        continue;
      }
      Boolean isRecordAnEligibleBrokerContact = isRecordAnEligibleBrokerContact(
        contactNew
      );
      if (isRecordAnEligibleBrokerContact == false) {
        continue;
      }
      brokerIdToEventTypeMap.put(contactNew.Id, action);
    }
    return brokerIdToEventTypeMap;
  }

  /**
   * @description Process contact record updates for OCV sync
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return List of records updated
   */
  public static List<Contact> processOCVSync(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<Contact> contactList = new List<Contact>();
    for (Contact contactNew : records) {
      Contact contactOld = contactsOldMap.get(contactNew.Id);
      if (isSyncStatusEligibleForUpdate(contactNew, contactOld) == false) {
        continue;
      }
      contactNew.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
        contactNew.Sync_Status__c,
        SYNC_STATUS_BROKER_ORG
      );
      contactList.add(contactNew);
    }
    return contactList;
  }

  /**
   * @description get the action type based on contact's OCV Event Version
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return String action type, if it's an add or an update
   */
  @TestVisible
  private static String getAction(Contact contactNew, Contact contactOld) {
    if (isContactsOCVEventVersionAdded(contactNew, contactOld)) {
      return RetailBrokerEventActions.BROKER_EVENT_ADD;
    } else if (
      contactNew.OCV_Event_Version__c > 0 &&
      contactNew.OCV_Event_Version__c >= contactOld.OCV_Event_Version__c
    ) {
      return RetailBrokerEventActions.BROKER_EVENT_UPDATE;
    }
    return '';
  }

  /**
   * @description validate the record for publishing based on contact's Sync Status
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @param action add/update
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isSyncStatusValidForPublishing(
    Contact contactNew,
    Contact contactOld,
    String action
  ) {
    if (doesSyncStatusContain(contactNew, SYNC_STATUS_BROKER_ORG) == false) {
      return false;
    }
    if (action == RetailBrokerEventActions.BROKER_EVENT_ADD) {
      return !doesSyncStatusContain(contactOld, SYNC_STATUS_BROKER_ORG);
    } else if (action == RetailBrokerEventActions.BROKER_EVENT_UPDATE) {
      return doesSyncStatusContain(contactOld, SYNC_STATUS_BROKER_ORG);
    }
    return false;
  }

  /**
   * @description Indicate if record is a valid Broker contact to be published
   * @param record new version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isRecordAnEligibleBrokerContact(Contact record) {
    return String.isNotBlank(record.CommercialTPMISAO__c) ||
      String.isNotBlank(record.AssetFinanceTPMISAO__c) ||
      (String.isNotBlank(record.RetailTPMISAO__c) && record.Is_Beta_Broker__c);
  }

  /**
   * @description validate the record for changing the Sync Staus to Broker Org based on contact's OCV Version and Sync Status
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isSyncStatusEligibleForUpdate(
    Contact contactNew,
    Contact contactOld
  ) {
    if (
      isContactsOCVEventVersionAdded(contactNew, contactOld) &&
      doesSyncStatusContain(contactOld, SYNC_STATUS_BROKER_ORG) == false &&
      doesSyncStatusContain(contactNew, SYNC_STATUS_BROKER_ORG) == false &&
      doesSyncStatusContain(contactNew, SYNC_STATUS_BLOCKED) == false
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Indicate if contact's OCV Event Version is added for the first time
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  private static Boolean isContactsOCVEventVersionAdded(
    Contact contactNew,
    Contact contactOld
  ) {
    return contactNew.OCV_Event_Version__c > 0 &&
      (contactOld.OCV_Event_Version__c == null ||
      contactOld.OCV_Event_Version__c <= 0);
  }

  /**
   * @description Check if contact's Sync Status contains a value
   * @param contact the record
   * @param value the value to be checked if it is present in contact's Sync Status
   * @return Boolean to indicate the eligibility of the contact record
   */
  private static Boolean doesSyncStatusContain(Contact contact, String value) {
    return contact.Sync_Status__c != null &&
      contact.Sync_Status__c.contains(value);
  }
}
