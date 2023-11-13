trigger EmailMessageTrigger on EmailMessage(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  EmailTriggerHandler handler = new EmailTriggerHandler();
}
