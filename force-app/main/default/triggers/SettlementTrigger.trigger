trigger SettlementTrigger on Settlement__c(
  before insert,
  after insert,
  after update
) {
  SettlementTriggerHandler handler = new SettlementTriggerHandler();
}
