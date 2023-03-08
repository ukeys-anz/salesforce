trigger FinancialAccountTrigger on FinServ__FinancialAccount__c(
  before insert,
  before update
) {
  FinancialAccountTriggerHandler handler = new FinancialAccountTriggerHandler();
}
