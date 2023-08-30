trigger ActionPlanTrigger on ActionPlan(
  before insert,
  before update,
  after insert,
  after update
) {
  CCRMActionPlanTriggerHandler handler = new CCRMActionPlanTriggerHandler();
}
