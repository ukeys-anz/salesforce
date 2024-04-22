trigger SettlementAccountTrigger on Settlement_Account__c(
  before insert,
  before update
) {
  SettlementAccountTriggerHandler handler = new SettlementAccountTriggerHandler();
}
