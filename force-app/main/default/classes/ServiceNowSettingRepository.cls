/**
 * @description       : Repository class for ServiceNow environment Settings
 * @author            : Prabhupad Sahu | Salesforce
 * @since  : 20-02-2025
 **/
public with sharing class ServiceNowSettingRepository {
  /**
   * @return  `ServiceNow_environment_settings__c` ServiceNow environment Settings defaults
   * @description
   */
  public List<ServiceNow_environment_settings__c> getSnowEnvSettings() {
    return ServiceNow_environment_settings__c.getAll().values();
  }
}
