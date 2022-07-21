trigger ControllingPostTrigger on Controlling_Post__c(
  before insert,
  before update
) {
  ControllingPostTriggerHandler handler = new ControllingPostTriggerHandler();
}
