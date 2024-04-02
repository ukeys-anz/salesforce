/**
 * @author Zhiren Jason Guan
 * @since  14/02/2024
 * @description Contact trigger handler for Retail Broker Domain
 * @runTests  RetailBrokerContactTriggerHandlerTest
 */

public with sharing class RetailBrokerContactTriggerHandler extends Lib_TriggerHandler {
  private static final Id RECORD_TYPE_ID_BROKER = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .recordTypeId;

  @TestVisible
  private static BrokerSettings__c mockBrokerSettings;

  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */
  @TestVisible
  private static BrokerSettings__c brokerSettings() {
    if (mockBrokerSettings != null) {
      return mockBrokerSettings;
    }
    return BrokerSettings__c.getOrgDefaults();
  }

  /**
   * @description To filter the broker contacts from the list of contacts
   * @param contacts The list of contacts
   * @return The list of broker contacts
   */
  @TestVisible
  private static List<Contact> filterBrokerContacts(List<Contact> contacts) {
    List<Contact> brokerContacts = new List<Contact>();
    for (Contact contact : contacts) {
      if (contact.RecordTypeId == RECORD_TYPE_ID_BROKER) {
        brokerContacts.add(contact);
      }
    }
    return brokerContacts;
  }

  /**
   * @description To perform business logic on before insert trigger context
   * @param oldMap The old id-record map before the update execution
   */
  @TestVisible
  protected override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Contact> filteredBrokers = filterBrokerContacts(records);
    List<Contact> filteredOldBrokers = filterBrokerContacts(oldMap.values());
    Map<Id, Contact> filteredOldMap = new Map<Id, Contact>(filteredOldBrokers);
    RetailBrokerContactActions.processOCVSync(filteredBrokers, filteredOldMap);
  }

  /**
   * @description To perform business logic on after update trigger context
   * @param oldMap The old id-record map before the update execution
   */
  @TestVisible
  protected override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (brokerSettings().BypassBrokerSyncEvents__c == true) {
      return;
    }
    List<Contact> filteredBrokers = filterBrokerContacts(records);
    List<Contact> filteredOldBrokers = filterBrokerContacts(oldMap.values());
    Map<Id, Contact> filteredOldMap = new Map<Id, Contact>(filteredOldBrokers);
    RetailBrokerContactActions.publishBrokerGCPEvents(
      filteredBrokers,
      filteredOldMap
    );
  }
}
