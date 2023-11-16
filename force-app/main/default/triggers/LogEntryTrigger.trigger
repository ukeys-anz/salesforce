trigger LogEntryTrigger on LogEntry__c(before delete) {
  LogEntryTriggerHandler handler = new LogEntryTriggerHandler();
}
