/**
 * @description       : Handler class for BrokerRelationTrigger
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-14-2025
 * @last modified by  : Grace Anusha | Salesforce
 * @runTests BrokerSetTriggerHandlerTest
 **/
public with sharing class BrokerSetTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public BrokerSetTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Broker_Relation__c) record).RecordTypeId ==
      RTBrokerRelation.brokerSet;
  }

  /*
   * @description onBeforeInsert to handle after insert trigger actions.
   * @author  Grace Anusha | Salesforce | 07-02-2025
   **/
  public override void onBeforeInsert() {
    BrokerRelationActions.populateExternalId(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @author  Grace Anusha | Salesforce | 07-02-2025
   * @param oldMap
   **/
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    BrokerRelationActions.populateExternalIdOnFilteredBrokerSet(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );
    BrokerRelationActions.restrictAggregatorChange(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );
    BrokerRelationActions.restrictDeactivationOfBrokerSet(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );
    BrokerRelationActions.restrictDeactivationRelatedOfficeGroup(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );
  }

  /**
   * @description To perform business logic on after update trigger context
   * @author  Saurabh Chauhan | Salesforce | 04-03-2025
   * @param oldMap The old id-record map before the update execution
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    BrokerRelationActions.publishBrokerRelationEvents(
      (Map<Id, Broker_Relation__c>) oldMap,
      (Map<Id, Broker_Relation__c>) Trigger.newMap
    );
  }
}
