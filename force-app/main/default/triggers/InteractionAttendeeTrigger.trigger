trigger InteractionAttendeeTrigger on InteractionAttendee(
  before insert,
  after insert,
  before update,
  after update,
  after delete
) {
  InteractionAttendeeTriggerHandler handler = new InteractionAttendeeTriggerHandler();
}
