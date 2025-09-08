/**
 * @description repository class for broker settings
 * @author Saurabh Chauhan
 * @since 13-Mar-2025
 */
public with sharing class BrokerSettingsRepository {
  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */

  public BrokerSettings__c get() {
    return BrokerSettings__c.getInstance();
  }

  /**
   * @description
   * @return  `BrokerSettings__c` Broker Setting defaults
   */
  public BrokerSettings__c getBrokerSettings() {
    return BrokerSettings__c.getOrgDefaults();
  }
}
