/**
 * @author Prakash B
 * @since Oct 2022
 * @group Logging
 * @description Class which will be used by declarative tools to create a log entry for multiple records.
 */
public without sharing class FlowCollectionLogEntry {
  /**
   * @description The API name of the Flow creating the log entry.
   */
  @InvocableVariable(required=true label='Flow API Name')
  public String flowName;

  /**
   * @description The message to log
   */
  @InvocableVariable(required=true label='Log Entry Message')
  public String message;

  /**
   * @description The records to relate to this log entry - the records' JSON is automatically added to the log entry
   */
  @InvocableVariable(required=false label='Records')
  public List<SObject> records;

  /**
   * @description Optionally log a Flow fault error message
   */
  @InvocableVariable(required=false label='(Optional) Flow Fault Error Message')
  public String faultMessage;

  /**
   * @description Represents the current system time
   */
  public DateTime timestamp = System.now();

  /**
   * @description Invocable method for adding LogEntry records via flow or process builder
   * @param  flowCollectionLogEntries The list of FlowRecordLogEntry instances to save
   */
  @InvocableMethod(
    category='Logging'
    label='Add Log Entry for an SObject Record Collection'
    description='Creates a log entry for a flow or process builder and stores the record list as JSON'
  )
  public static void addFlowCollectionEntries(
    List<FlowCollectionLogEntry> flowCollectionLogEntries
  ) {
    List<FlowLogger.LogEntry> logEntries = new List<FlowLogger.LogEntry>();
    for (
      FlowCollectionLogEntry flowCollectionLogEntry : flowCollectionLogEntries
    ) {
      FlowLogger.LogEntry logEntry = (FlowLogger.LogEntry) JSON.deserialize(
        JSON.serialize(flowCollectionLogEntry),
        FlowLogger.LogEntry.class
      );
      LogEventBuilder eventbuilder = logEntry.addToLoggerBuffer()
        ?.setRecord(flowCollectionLogEntry.records);
      logEntries.add(logEntry);
    }
    FlowLogger.addLogEntries(logEntries);
  }
}
