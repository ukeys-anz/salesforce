/**
 * @author Prakash B
 * @since Oct 2022
 * @group Logging
 * @description Class which will be used by declarative tools to create a log entry for a single record.
 */
public without sharing class FlowLogEntry {
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
   * @description Optionally log a Flow fault error message
   */
  @InvocableVariable(required=false label='(Optional) Flow Fault Error Message')
  public String faultMessage;

  /**
   * @description Optionally relate the log entry to a particular record
   */
  @InvocableVariable(required=false label='(Optional) Record ')
  public SObject record;

  /**
   * @description Current system timestamp.
   */
  public DateTime timestamp = System.now();

  /**
   * @description Invocable method, that can be called via flow.
   * @param flowLogEntries The list of FlowLogEntry instances to save
   */

  @InvocableMethod(
    category='Logging'
    label='Add Log Entry'
    description='Creates a log entry for a flow or process builder'
  )
  public static void addFlowEntries(List<FlowLogEntry> flowLogEntries) {
    List<FlowLogger.LogEntry> logEntries = new List<FlowLogger.LogEntry>();

    for (FlowLogEntry flowLogEntry : flowLogEntries) {
      FlowLogger.LogEntry logEntry = (FlowLogger.LogEntry) JSON.deserialize(
        JSON.serialize(flowLogEntry),
        FlowLogger.LogEntry.class
      );
      logEntry.addToLoggerBuffer()?.setRecord(flowLogEntry.record);
      logEntries.add(logEntry);
    }

    FlowLogger.addLogEntries(logEntries);
  }
}
