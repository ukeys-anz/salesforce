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
      SELECT Id, External_Id__c, Broker_Name__c
      FROM Broker_Code__c
      WHERE External_Id__c IN :brokerIdentifiers
      WITH USER_MODE
    ];
  }
}
