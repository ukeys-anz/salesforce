trigger LogEventTrigger on LogEvent__e(after insert) {
  LogEventTriggerHandler handler = new LogEventTriggerHandler();
}
