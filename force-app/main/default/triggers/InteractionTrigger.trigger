trigger InteractionTrigger on Interaction(after insert, after update) {
  InteractionTriggerHandler handler = new InteractionTriggerHandler();
}
