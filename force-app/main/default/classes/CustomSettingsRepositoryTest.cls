@IsTest
public with sharing class CustomSettingsRepositoryTest {
  @isTest
  static void testBrokerSettings() {
    CustomSettingsRepository brokersettings = new CustomSettingsRepository();
    BrokerSettings__c expectedSettings = BrokerSettings__c.getOrgDefaults();

    Test.startTest();
    BrokerSettings__c actualSettings = brokersettings.brokerSettings();
    Test.stopTest();

    Assert.areEqual(
      expectedSettings,
      actualSettings,
      'The broker settings should match the org defaults.'
    );
  }
}
