trigger FinancialAccountTrigger on FinServ__FinancialAccount__c(
  before insert,
  before update,
  after update
) {
  FinancialAccountTriggerHandler handler = new FinancialAccountTriggerHandler();
}
