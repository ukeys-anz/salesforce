trigger InteractionTrigger on Interaction(after insert) {
  InteractionTriggerHandler handler = new InteractionTriggerHandler();
}
