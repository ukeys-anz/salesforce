trigger ContactRequestTrigger on ContactRequest(
  before insert,
  after insert,
  before update,
  after update
) {
  ContactRequestTriggerHandler handler = new ContactRequestTriggerHandler();
}
