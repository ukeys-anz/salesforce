trigger UUIDLogEventTrigger on UUID_Log_Event__e(after insert) {
  UUIDLogEventTriggerHandler handler = new UUIDLogEventTriggerHandler();
}
