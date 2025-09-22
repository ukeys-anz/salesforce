/**
 * @description       : Apex class for RBMInteractionActions Repository
 * @author            : Smruti Khobragade | Salesforce
 * @group             :
 * @last modified on  : 01-30-2025
 * @last modified by  :  Smruti Khobragade | Salesforce
 **/
public with sharing class RBMInteractionRepository {
  /**
   * @description to fetch Broker ontacts
   * @param brokerIds to fetch the Name from broker contact
   * @return  List<Contacts> Broker ontacts
   */
  public List<Contact> queryBrokerContacts(Set<Id> brokerIds) {
    if (brokerIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT Id, Name
      FROM Contact
      WHERE Id IN :brokerIds
      WITH USER_MODE
    ];
  }

  /**
   * @description to fetch office Groups
   * @param officeGroupIds to fetch the Name from Broker_Relation__c
   * @return  List<Broker_Relation__c> list of Office Groups
   */
  public List<Broker_Relation__c> queryOfficeGroups(Set<Id> officeGroupIds) {
    if (officeGroupIds.isEmpty()) {
      return new List<Broker_Relation__c>();
    }
    return [
      SELECT Id, Name
      FROM Broker_Relation__c
      WHERE Id IN :officeGroupIds
      WITH USER_MODE
    ];
  }
  /**
   * @description query Brokers From Office Groups
   * @param officeGroupIds set of Broker_Relation__c ids
   * @return  `List<Contacts>` list of Brokers in the office Group
   */
  public List<Contact> queryBrokersFromOfficeGroups(Set<Id> officeGroupIds) {
    if (officeGroupIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT Id, Office_Group__c, Phone
      FROM Contact
      WHERE Office_Group__c IN :officeGroupIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get Event data based on BrokerIds
   * @param whatIds set to query events
   * @return List<Event> envents list
   **/
  public static List<Event> getEvents(Set<Id> whatIds) {
    if (whatIds.isEmpty()) {
      return new List<Event>();
    }
    return [
      SELECT Id, StartDateTime, WhatId
      FROM Event
      WHERE WhatId IN :whatIds
      WITH USER_MODE
    ];
  }
}
