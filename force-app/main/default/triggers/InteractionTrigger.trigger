trigger InteractionTrigger on Interaction(
  before insert,
  before update,
  after insert,
  after update
) {
  InteractionTriggerHandler handler = new InteractionTriggerHandler();
}
