trigger FinancialAccountTrigger on FinServ__FinancialAccount__c(
  before insert,
  before update,
  after insert,
  after update
) {
  FinancialAccountTriggerHandler financialAccountTriggerHandler = new FinancialAccountTriggerHandler();
  RetailBrokerFinAccountTriggerHandler retailBrokerFinAccountTriggerHandler = new RetailBrokerFinAccountTriggerHandler();
}
