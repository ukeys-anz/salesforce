/**
 * @description This class provide SOQL helper for class related to RetailBrokerRelationEventActions.
 *
 * @created       2025-03 Saurabh Chauhan
 * @lastModified  2025-08 Manish bisht
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

  /**
   * @description Retrieves a single Contact record based on the provided
   * broker contact ID.
   *
   * @param brokerContactId The ID of the broker contact to retrieve.
   * @return the Contact record associated with the provided ID
   */
  public Contact getBrokerDetail(String brokerContactId) {
    if (String.isBlank(brokerContactId)) {
      return null;
    }
    return [
      SELECT Id, Email
      FROM Contact
      WHERE Id = :brokerContactId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }
}
