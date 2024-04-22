trigger CustomerActionTrigger on Customer_Action__c(
  before insert,
  before update
) {
  CustomerActionTriggerHandler handler = new CustomerActionTriggerHandler();
}
