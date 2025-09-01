/**
 * @author Saurabh Chauhan
 * @since 03/2025
 * @description This class provide SOQL helper for class related to RetailBrokerRelationEventActions.
 */
public with sharing class RetailContactRepository {
  /**
   * @description To be used fetch Contact records
   * @param contactIds set of Contact Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getContacts(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        Name,
        Broker_Set__r.Primary_RBM__c,
        Broker_Set__r.Secondary_RBM__c,
        Broker_Set__r.Primary_RBM__r.Lan_Id__c,
        Broker_Set__r.Secondary_RBM__r.Lan_Id__c,
        External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c
      FROM Contact
      WHERE Id IN :contactIds
      WITH USER_MODE
    ];
  }

  /**
   * @description To be used fetch Contact records
   * @param brokerSetIds set of Broker_Relation__c Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getBrokerSetContacts(Set<Id> brokerSetIds) {
    if (brokerSetIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT
        Id,
        Name,
        Broker_Set__c,
        Broker_Set__r.Primary_RBM__c,
        Broker_Set__r.Secondary_RBM__c,
        Broker_Set__r.Primary_RBM__r.Lan_Id__c,
        Broker_Set__r.Secondary_RBM__r.Lan_Id__c,
        External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c
      FROM Contact
      WHERE Broker_Set__c IN :brokerSetIds
      WITH USER_MODE
    ];
  }
}
