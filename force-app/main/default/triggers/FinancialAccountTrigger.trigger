trigger FinancialAccountTrigger on FinServ__FinancialAccount__c(before update) {
  FinancialAccountTriggerHandler handler = new FinancialAccountTriggerHandler();
}
