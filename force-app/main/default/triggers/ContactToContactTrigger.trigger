/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2023
 * @description ContactToContactTrigger to handle FinServ__ContactContactRelation__c trigger actions.
 */
trigger ContactToContactTrigger on FinServ__ContactContactRelation__c(
  before insert
) {
  ContactToContactTriggerHandler handler = new ContactToContactTriggerHandler();
}
