/**
 * @description       : Apex trigger for Broker_Relation__c
 * @author            : Grace Anusha | Salesforce
 * @group             :
 * @last modified on  : 02-13-2025
 * @last modified by  : Grace Anusha | Salesforce
 **/
trigger BrokerRelationTrigger on Broker_Relation__c(
  before insert,
  before update,
  after update
) {
  BrokerSetTriggerHandler handler = new BrokerSetTriggerHandler();
  OfficeGroupTriggerHandler officeGrouphandler = new OfficeGroupTriggerHandler();
}
