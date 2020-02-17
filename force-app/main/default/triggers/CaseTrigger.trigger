trigger CaseTrigger on Case(before insert, after insert, after update) {
  CaseTriggerHandler handler = new CaseTriggerHandler();
}
