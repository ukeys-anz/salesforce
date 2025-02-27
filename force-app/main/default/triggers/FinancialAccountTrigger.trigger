trigger FinancialAccountTrigger on FinServ__FinancialAccount__c(
  before insert,
  before update,
  after insert,
  after update
) {
  new FinancialAccountTriggerHandler();
  new RetailBrokerFinAccountTriggerHandler();
}
