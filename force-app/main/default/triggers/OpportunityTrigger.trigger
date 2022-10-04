trigger OpportunityTrigger on Opportunity(
  before insert,
  before update,
  after insert
) {
  OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
}
