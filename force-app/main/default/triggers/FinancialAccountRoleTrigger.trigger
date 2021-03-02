trigger FinancialAccountRoleTrigger on FinServ__FinancialAccountRole__c(
  before insert
) {
  FinancialAccountRoleTriggerHandler handler = new FinancialAccountRoleTriggerHandler();
}
