/**
 * @author Zhiren Jason Guan
 * @since  14/02/2024
 * @description Contact trigger handler for Retail Broker Domain
 * @runTests  RetailBrokerContactTriggerHandlerTest
 */

public with sharing class RetailBrokerContactTriggerHandler extends Lib_TriggerHandler {
  private static final Id RECORD_TYPE_ID_BROKER = SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .recordTypeId;

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public RetailBrokerContactTriggerHandler() {
    super();
  }

  @TestVisible
  private static BrokerSettings__c mockBrokerSettings;

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Broker contact records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Contact contact = (Contact) record;
    return contact.RecordTypeId == RECORD_TYPE_ID_BROKER;
  }
  /**
   * @description To set the mock broker settings
   * @return The BrokerSettings__c custom setting
   */
  @TestVisible
  private static BrokerSettings__c brokerSettings() {
    if (mockBrokerSettings != null) {
      return mockBrokerSettings;
    }
    return BrokerSettings__c.getOrgDefaults();
  }
  /**
   * @description To perform business logic on before insert trigger context
   * @param oldMap The old id-record map before the update execution
   */
  @TestVisible
  protected override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    RetailBrokerContactActions.processOCVSync(
      records,
      (Map<Id, Contact>) oldMap
    );
  }

  /**
   * @description To perform business logic on after update trigger context
   * @param oldMap The old id-record map before the update execution
   */
  @TestVisible
  protected override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (brokerSettings().BypassBrokerSyncEvents__c == true) {
      return;
    }
    RetailBrokerContactActions.publishBrokerGCPEvents(
      records,
      (Map<Id, Contact>) oldMap
    );
  }
}
