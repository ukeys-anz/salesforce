trigger InteractionSummaryTrigger on InteractionSummary(after insert) {
  InteractionSummaryTriggerHandler handler = new InteractionSummaryTriggerHandler();
}
