/**
 * @author Satish
 * @since  Jan 2025
 * @description repository for RetailBroker SOQL queries
 * @runTests  RetailBrokerEventActionsTest
 */
public with sharing class RetailBrokerRepository extends RepositoryBase {
  /**
   * @param contactIds ids of contacts to be retrieved
   * @description Data access method to retrieve contacts by Ids
   * @return A list of Contacts
   */
  public List<Contact> getBrokerContactsByIds(Set<Id> contactIds) {
    return [
      SELECT
        Id,
        Name,
        External_Id__c,
        Broker_Customer_Profile__r.External_Id__c,
        OCV_Event_Version__c,
        Sync_Status__c,
        Survivor_Party_Id__c,
        Victim_Party_Id__c,
        OCV_Profile_ID__c,
        RetailTPMISAO__c
      FROM Contact
      WHERE Id IN :contactIds
      WITH USER_MODE
    ];
  }
}
