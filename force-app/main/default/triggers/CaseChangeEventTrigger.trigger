trigger CaseChangeEventTrigger on CaseChangeEvent(after insert) {
  CaseChangeEventTriggerHandler handler = new CaseChangeEventTriggerHandler();
}
