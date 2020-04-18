trigger CaseTrigger on Case(
  before insert,
  after insert,
  after update,
  before delete
) {
  CaseTriggerHandler handler = new CaseTriggerHandler();
}
