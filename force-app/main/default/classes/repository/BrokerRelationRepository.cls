/**
 * @description       :
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-14-2025
 * @last modified by  : Grace Anusha | Salesforce
 **/
public with sharing class BrokerRelationRepository {
  /**
   * @description Gets list of broker relations with a broker
   * @param brokerSetIds broker set Ids
   * @return Map<Id, Broker_Relation__c> Map of contacts(brokers) assigned to broker set
   */
  public Map<Id, Broker_Relation__c> getBrokerMap(Set<Id> brokerSetIds) {
    if (brokerSetIds.isEmpty()) {
      return new Map<Id, Broker_Relation__c>();
    }
    return new Map<Id, Broker_Relation__c>(
      [
        SELECT
          Id,
          (
            SELECT id
            FROM Broker_Set_Brokers__r
            WHERE RecordTypeId = :RTContact.broker
            LIMIT 1
          )
        FROM Broker_Relation__c
        WHERE Id IN :brokerSetIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description Gets list of office groups with a broker
   * @param brokerSetIds broker set Ids
   * @return Map<Id, Broker_Relation__c> Map of contacts(brokers) assigned to office group
   */
  public Map<Id, Broker_Relation__c> getBrokerMapOfficeGroup(
    Set<Id> brokerSetIds
  ) {
    if (brokerSetIds.isEmpty()) {
      return new Map<Id, Broker_Relation__c>();
    }
    return new Map<Id, Broker_Relation__c>(
      [
        SELECT
          Id,
          (
            SELECT id
            FROM Office_Group_Brokers__r
            WHERE RecordTypeId = :RTContact.broker
            LIMIT 1
          )
        FROM Broker_Relation__c
        WHERE Id IN :brokerSetIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description Get BrokerSet Primary RBM and Secondary RBM
   * @author : Saurabh Chauhan | Salesforce
   * @param  brokerSetIds a set Id to get selected Broker Set
   * @return Map<Id, Broker_Relation__c> Map of Broker Relation along with Primary and Secondary RBM details
   */
  public Map<Id, Broker_Relation__c> queryBrokerRelationWithRbmDetails(
    Set<Id> brokerSetIds
  ) {
    if (brokerSetIds.isEmpty()) {
      return new Map<Id, Broker_Relation__c>();
    }
    return new Map<Id, Broker_Relation__c>(
      [
        SELECT Id, Primary_RBM__r.Lan_Id__c, Secondary_RBM__r.Lan_Id__c
        FROM Broker_Relation__c
        WHERE Id IN :brokerSetIds
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description Get Lan Ids of Primary RBM and Secondary RBM of Broker Sets
   * @author : Saurabh Chauhan | Salesforce
   * @param  prbmUserIds set of primary rbm user ids
   * @param  srbmUserIds set of secondary rbm user ids
   * @return Map<Id, User>
   */
  public Map<Id, User> queryRbmUsers(Set<Id> prbmUserIds, Set<Id> srbmUserIds) {
    if (prbmUserIds.isEmpty() && srbmUserIds.isEmpty()) {
      return new Map<Id, User>();
    }
    return new Map<Id, User>(
      [
        SELECT Id, Lan_Id__c
        FROM User
        WHERE (Id IN :prbmUserIds OR Id IN :srbmUserIds) AND Lan_Id__c != NULL
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description Gets list of active office groups
   * @param brokerSetIds broker set Ids
   * @return Map<Id, Broker_Relation__c> Map of contacts(brokers) assigned to office group
   */
  public Map<Id, Broker_Relation__c> getOfficeGroupRelatedToBrokerSet(
    Set<Id> brokerSetIds
  ) {
    if (brokerSetIds.isEmpty()) {
      return new Map<Id, Broker_Relation__c>();
    }
    return new Map<Id, Broker_Relation__c>(
      [
        SELECT
          Id,
          (
            SELECT Id
            FROM Office_Groups__r
            LIMIT 1
          )
        FROM Broker_Relation__c
        WHERE Id IN :brokerSetIds
        WITH USER_MODE
      ]
    );
  }
}
