trigger DisputeTrigger on Dispute(after update, before delete, after delete) {
  DisputedTransactionTriggerHandler handler = new DisputedTransactionTriggerHandler();
}
