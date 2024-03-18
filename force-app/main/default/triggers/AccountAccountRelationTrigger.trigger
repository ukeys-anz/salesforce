/**
 * @author Tan Phan
 * @since 11/2023
 * @description AccountAccountRelationTrigger to handle FinServ__AccountAccountRelation__c trigger actions.
 */
trigger AccountAccountRelationTrigger on FinServ__AccountAccountRelation__c(
  before insert,
  after update
) {
  AccountAccountRelationTriggerHandler handler = new AccountAccountRelationTriggerHandler();
}
