trigger CaseTrigger on Case(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  CaseTriggerHandler handler = new CaseTriggerHandler();
}
