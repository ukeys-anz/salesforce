trigger DisputeItemTrigger on DisputeItem(after delete) {
  DisputedTransactionItemTriggerHandler handler = new DisputedTransactionItemTriggerHandler();
}
