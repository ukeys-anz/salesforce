trigger SettlementTrigger on Settlement__c(before insert) {
  SettlementTriggerHandler handler = new SettlementTriggerHandler();
}
