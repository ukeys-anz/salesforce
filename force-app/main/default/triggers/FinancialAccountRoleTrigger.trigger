/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Handler trigger events for FinServ__FinancialAccountRole__c object
 */
trigger FinancialAccountRoleTrigger on FinServ__FinancialAccountRole__c(
  before insert,
  after insert,
  before update
) {
  FinancialAccountRoleTriggerHandler handler = new FinancialAccountRoleTriggerHandler();
}
