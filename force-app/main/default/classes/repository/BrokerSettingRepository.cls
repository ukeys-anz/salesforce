/**
 * @description       : Repository class for BrokerSetting
 * @author            : Madhuri Edke | Salesforce
 * @last modified on  : 15-10-2024
 * @last modified by  : Madhuri Edke | Salesforce
 **/
public with sharing class BrokerSettingRepository {
  public BrokerSettings__c getBrokerSettings() {
    return BrokerSettings__c.getOrgDefaults();
  }
}
