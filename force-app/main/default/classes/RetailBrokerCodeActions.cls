/**
 * @author Supriya
 * @since 02/2025
 * @description the action class for creating map for brokercode
 * @runTests RetailBrokerCodeActionsTest
 */
public with sharing class RetailBrokerCodeActions {
  private static final BrokerCodeRepository BROKER_CODE_REPOSITORY = (BrokerCodeRepository) Lib_InstanceProvider.forType(
    BrokerCodeRepository.class
  );

  /**
   * @description Retrieves broker code to contact map.
   * @param brokerIdentifiers List of broker identifiers.
   * @return Map of broker codes to contact IDs.
   */
  public static Map<String, Id> getBrokerCodeExIDToContactMap(
    Set<String> brokerIdentifiers
  ) {
    List<Broker_Code__c> brokerCodes = BROKER_CODE_REPOSITORY.getBrokerIdentifiers(
      brokerIdentifiers
    );
    Map<String, Id> brokerCodeToContactMap = new Map<String, Id>();
    for (Broker_Code__c brokerCode : brokerCodes) {
      brokerCodeToContactMap.put(
        brokerCode.External_Id__c,
        brokerCode.Broker_Name__c
      );
    }
    return brokerCodeToContactMap;
  }
}
