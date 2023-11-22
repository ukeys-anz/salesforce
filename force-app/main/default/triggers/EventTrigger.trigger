trigger EventTrigger on Event(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  EventTriggerHandler handler = new EventTriggerHandler();
}
