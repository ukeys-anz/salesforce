trigger ContactRequestTrigger on ContactRequest(
  before insert,
  after insert,
  after update
) {
  ContactRequestTriggerHandler handler = new ContactRequestTriggerHandler();
}
