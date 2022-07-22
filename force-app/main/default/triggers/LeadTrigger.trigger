trigger LeadTrigger on Lead(
  before delete,
  before insert,
  before update,
  after insert,
  after update
) {
  LeadTriggerHandler handler = new LeadTriggerHandler();
}
