/**
 * @description       : Handler class for BrokerRelationTrigger
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-20-2025
 * @last modified by  : Grace Anusha | Salesforce
 * @runTests OfficeGroupTriggerHandlerTest
 **/
public with sharing class OfficeGroupTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public OfficeGroupTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Broker_Relation__c) record).RecordTypeId ==
      RTBrokerRelation.officeGroup;
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @author  Grace Anusha | Salesforce | 14-02-2025
   * @param oldMap
   **/
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //Please remove all brokers from the Office Group before changing the Broker Set
    BrokerRelationActions.restrictBrokerSetChangeOnOfficeGroup(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );

    BrokerRelationActions.blockDeactivationOfficeGroup(
      (Map<Id, Broker_Relation__c>) oldMap,
      (List<Broker_Relation__c>) records
    );
  }
}
