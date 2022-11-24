/**
 * @author Prakash B
 * @since Oct 2022
 * @group Logging
 * @description Class which creates logs for declarative tools, called from FlowLogEntry and FlowCollectionLogEntry
 */

public class FlowLogger {
  /**
   * @description Wrapper class which contains Log Entry information.
   */
  public class LogEntry {
    /**
     * @description Name of the flow
     */
    public String flowName;

    /**
     * @description General message to be captured in log
     */
    public String message;

    /**
     * @description Options fault message, if applicable
     */
    public String faultMessage;

    /**
     * @description Timestamp of the log
     */
    public DateTime timestamp;

    /**
     * @description  Name of the entry's logging level
     */
    public String loggingLevelName;

    // Private member variables
    private LoggingLevel logLevel;
    private LogEventBuilder builder;
    private LogEvent__e logEvent;

    /**
     * @description Adds the logger to the buffer
     * @return An instance of LogEventBuilder
     */
    public LogEventBuilder addToLoggerBuffer() {
      if (this.builder != null) {
        return this.builder;
      }

      if (String.isBlank(this.loggingLevelName)) {
        if (String.isNotBlank(this.faultMessage) || Test.isRunningTest()) {
          logLevel = LoggingLevel.ERROR;
        } else {
          logLevel = LoggingLevel.DEBUG;
        }
      }

      this.builder = LoggerHelper.newEntry(this.logLevel);
      if (this.builder.shouldSave() == false) {
        return this.builder;
      }

      this.logEvent = builder.getLogEvent();
      this.logEvent.Origin__c = 'Flow';
      this.logEvent.StackTrace__c = null;
      this.logEvent.StartTime__c = this.timestamp;
      this.logEvent.ComponentName__c = this.flowName;
      this.logEvent.LogMessage__c = this.message;

      if (String.isNotBlank(this.faultMessage)) {
        this.logEvent.ExceptionMessage__c = this.faultMessage;
        this.logEvent.ExceptionType__c = 'Flow.FaultError';
      }

      return this.builder;
    }
  }

  /**
   * @description Adds logging entries
   * @param flowEntries The log entry instances to add.
   */
  public static void addLogEntries(List<LogEntry> flowEntries) {
    Logger.SaveMethod saveMethod = LoggerHelper.transactionSaveMethod;
    Logger.saveLog(saveMethod);
  }
}
