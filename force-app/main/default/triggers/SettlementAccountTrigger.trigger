trigger SettlementAccountTrigger on Settlement_Account__c(
  before insert,
  before update,
  after insert,
  after update
) {
  SettlementAccountTriggerHandler handler = new SettlementAccountTriggerHandler();
}
