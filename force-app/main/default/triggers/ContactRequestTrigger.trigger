trigger ContactRequestTrigger on ContactRequest(after insert, after update) {
  ContactRequestTriggerHandler handler = new ContactRequestTriggerHandler();
}
