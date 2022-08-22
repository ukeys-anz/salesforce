/**
 * @author Nakul Kumar
 * @since July 2022
 * @description Handler Apex to create `Log__c`, `LogEntry__c` and `SecureLogEntry__c` records when `LogEvent__e` is published
 */

public with sharing class LogEventTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public LogEventTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to create the records
   */
  public override void onAfterInsert() {
    LogEventActions.processLogEvents((List<LogEvent__e>) records);
  }
}
