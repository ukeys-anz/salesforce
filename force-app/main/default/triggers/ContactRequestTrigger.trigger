trigger ContactRequestTrigger on ContactRequest(after insert) {
  ContactRequestTriggerHandler handler = new ContactRequestTriggerHandler();
}
