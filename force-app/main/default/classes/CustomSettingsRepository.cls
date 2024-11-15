/**
 * @description repository class for Custom settings related
 * @author @supriya
 * @since 18-Oct-2024
 */
public with sharing class CustomSettingsRepository {
  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */

  public BrokerSettings__c brokerSettings() {
    return BrokerSettings__c.getOrgDefaults();
  }
}
