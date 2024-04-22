trigger SettlementTrigger on Settlement__c(before insert, after insert) {
  SettlementTriggerHandler handler = new SettlementTriggerHandler();
}
