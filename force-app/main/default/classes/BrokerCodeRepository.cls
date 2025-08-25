/**
 * @description Method to perform Database query operations related to Broker Code
 * @author Supriya
 * @since 02/2025
 */
public with sharing class BrokerCodeRepository {
  /**
   * @description get the list of the Broker code records
   * @param brokerIdentifiers List of broker identifiers
   * @return List<Broker_Code__c> list of filtered broker codes
   */
  public List<Broker_Code__c> getBrokerIdentifiers(
    Set<String> brokerIdentifiers
  ) {
    if (brokerIdentifiers.isEmpty()) {
      return new List<Broker_Code__c>();
    }
    return [
      SELECT Id, External_Id__c, Broker_Name__c, Broker_Name__r.Sync_Status__c
      FROM Broker_Code__c
      WHERE
        External_Id__c IN :brokerIdentifiers
        AND Broker_Name__r.Sync_Status__c EXCLUDES (
          'Duplicate - Email',
          'Duplicate - OCV Id'
        )
      WITH USER_MODE
    ];
  }

  /**
   * @description get the list of the Broker code records
   * @param brokerIds Set of broker Ids
   * @return List<Broker_Code__c> list of filtered broker codes
   */
  public List<Broker_Code__c> getRelatedBrokerCodes(Set<Id> brokerIds) {
    if (brokerIds.isEmpty()) {
      return new List<Broker_Code__c>();
    }
    return [
      SELECT Id, External_Id__c, Broker_Name__c
      FROM Broker_Code__c
      WHERE Broker_Name__c IN :brokerIds
      WITH USER_MODE
    ];
  }
}
