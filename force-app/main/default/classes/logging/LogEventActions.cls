/**
 * @author Jasmine Nguyen
 * @since July 2022
 * @description LogEventActions handles actions related to `Log__c`, `LogEntry__c` and `SecureLogEntry__c` records
 */
public with sharing class LogEventActions {
  /**
   * @description Processes log events and create log, log entry and secure log entry records
   * @param records List of log events
   */
  public static void processLogEvents(List<LogEvent__e> records) {
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap = new Map<String, List<LogEvent__e>>();
    for (LogEvent__e eventRecord : records) {
      String traceId = eventRecord.TraceId__c;
      if (traceIdAndlogDetailsListMap.containsKey(traceId) == false) {
        traceIdAndlogDetailsListMap.put(traceId, new List<LogEvent__e>());
      }
      traceIdAndlogDetailsListMap.get(traceId).add(eventRecord);
    }

    try {
      createLogAndRelatedRecords(traceIdAndlogDetailsListMap);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  /**
   * @description create Log__c, LogEntry__c and SecureLogEntry__c records
   * @param traceIdAndlogDetailsListMap Map of TraceId and list of Event records with the same TraceId
   */
  private static void createLogAndRelatedRecords(
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap
  ) {
    Set<String> traceIds = traceIdAndlogDetailsListMap.keySet();
    Map<String, Log__c> traceIdAndLogMap;
    try {
      if (!traceIds.isEmpty()) {
        traceIdAndLogMap = getExistingLogRecords(traceIds);
        Set<String> traceIdsWithoutLog = getTraceIdsWithoutExistingLogs(
          traceIds,
          traceIdAndLogMap
        );
        Map<String, Id> traceIdAndLogIdMap = createLogs(
          traceIdsWithoutLog,
          traceIdAndlogDetailsListMap
        );
        createLogEntryAndSecureLogEntryRecords(
          traceIdAndlogDetailsListMap,
          traceIdAndLogIdMap
        );
      }
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  /**
   * @description create a `Log__c` record
   * @param eventRecord event record
   * @return `Log__c` record
   */
  @TestVisible
  private static Log__c createLogRecord(LogEvent__e eventRecord) {
    Log__c log = new Log__c(
      APIVersion__c = eventRecord.APIVersion__c,
      EnvironmentType__c = eventRecord.EnvironmentType__c,
      InstanceName__c = eventRecord.InstanceName__c,
      StartTime__c = eventRecord.StartTime__c,
      TraceId__c = eventRecord.TraceId__c,
      TransactionContext__c = eventRecord.TransactionContext__c,
      UserProfile__c = eventRecord.UserProfile__c,
      UserRole__c = eventRecord.UserRole__c,
      UserId__c = eventRecord.UserId__c
    );
    return log;
  }

  /**
   * @description create SecureLogEntry records
   * @param eventRecord event record
   * @param logId parent `Log__c` record's Id
   * @return `SecureLogEntry__c` record
   */
  @TestVisible
  private static SecureLogEntry__c createSecureLogEntryRecord(
    LogEvent__e eventRecord,
    Id logId
  ) {
    SecureLogEntry__c secureLogEntry = new SecureLogEntry__c(
      ApexClassName__c = eventRecord.ApexClassName__c,
      ApexMethodName__c = eventRecord.ApexMethodName__c,
      Payload__c = eventRecord.Payload__c,
      SpanId__c = eventRecord.SpanId__c,
      Log__c = logId,
      RecordsJson__c = eventRecord.RecordsJson__c
    );
    return secureLogEntry;
  }

  /**
   * @description create LogEntry records
   * @param eventRecord event record
   * @param logId parent `Log__c` record's Id
   * @return `LogEntry__c` record
   */
  @TestVisible
  private static LogEntry__c createLogEntryRecord(
    LogEvent__e eventRecord,
    Id logId
  ) {
    LogEntry__c logEntry = new LogEntry__c(
      ApexClassName__c = eventRecord.ApexClassName__c,
      ApexMethodName__c = eventRecord.ApexMethodName__c,
      BrowserName__c = eventRecord.BrowserName__c,
      ComponentName__c = eventRecord.ComponentName__c,
      DatabaseResult__c = eventRecord.DatabaseResult__c,
      ExceptionMessage__c = eventRecord.ExceptionMessage__c,
      ExceptionType__c = eventRecord.ExceptionType__c,
      LogMessage__c = eventRecord.LogMessage__c,
      LoggingLevel__c = eventRecord.LoggingLevel__c,
      Origin__c = eventRecord.Origin__c,
      RecordId__c = eventRecord.RecordId__c,
      RecordObjectName__c = eventRecord.RecordObjectName__c,
      SpanId__c = eventRecord.SpanId__c,
      StackTrace__c = eventRecord.StackTrace__c,
      UsedCallouts__c = eventRecord.UsedCallouts__c,
      UsedCPUTime__c = eventRecord.UsedCPUTime__c,
      UsedDMLStatements__c = eventRecord.UsedDMLStatements__c,
      UsedFutureCalls__c = eventRecord.UsedFutureCalls__c,
      UsedHeapSize__c = eventRecord.UsedHeapSize__c,
      UsedQueueableJobs__c = eventRecord.UsedQueueableJobs__c,
      UsedSOQLQueries__c = eventRecord.UsedSOQLQueries__c,
      Log__c = logId
    );
    return logEntry;
  }

  /**
   * @description check and return exisitng `Log__c` records which are already present
   * @param traceIds Set of traceIds to get existing `Log__c` records
   * @return `Map<String, Log__c>` Map of TraceId and `Log__c` records
   */
  @TestVisible
  private static Map<String, Log__c> getExistingLogRecords(
    Set<String> traceIds
  ) {
    Map<String, Log__c> traceIdAndLogMap = new Map<String, Log__c>();
    try {
      List<Log__c> logs = [
        SELECT Id, TraceId__c
        FROM Log__c
        WHERE TraceId__c IN :traceIds
      ];
      for (Log__c log : logs) {
        traceIdAndLogMap.put(log.TraceId__c, log);
      }
      return traceIdAndLogMap;
    } catch (Exception e) {
      System.debug(e.getMessage());
      return null;
    }
  }

  /**
   * @description create LogEntry__c and SecureLogEntry__c records
   * @param traceIdAndlogDetailsListMap Map of TraceId and list of Event records with the same TraceId
   * @param traceIdAndLogIdMap Map of TraceId and list of Log__c records' Ids
   */
  @TestVisible
  private static void createLogEntryAndSecureLogEntryRecords(
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap,
    Map<String, Id> traceIdAndLogIdMap
  ) {
    List<LogEntry__c> logEntries = new List<LogEntry__c>();
    List<SecureLogEntry__c> secureLogEntries = new List<SecureLogEntry__c>();
    try {
      for (String traceId : traceIdAndlogDetailsListMap.keySet()) {
        List<LogEvent__e> logDetailsList = traceIdAndlogDetailsListMap.get(
          traceId
        );
        for (LogEvent__e logDetails : logDetailsList) {
          if (String.isNotBlank(logDetails.Payload__c)) {
            secureLogEntries.add(
              createSecureLogEntryRecord(
                logDetails,
                traceIdAndLogIdMap.get(traceId)
              )
            );
          }
          logEntries.add(
            createLogEntryRecord(logDetails, traceIdAndLogIdMap.get(traceId))
          );
        }
      }
      if (Schema.sObjectType.SecureLogEntry__c.isCreateable()) {
        insert secureLogEntries;
      }
      if (Schema.sObjectType.LogEntry__c.isCreateable()) {
        insert logEntries;
      }
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  /**
   * @description Returns a set of trace Ids that do not have associated existing logs
   * @param traceIds A set of trace Ids from published log events
   * @param traceIdAndLogMap Map of trace Id and corresponding log
   * @return A set of trace Ids that do not have associated existing logs
   */
  @TestVisible
  private static Set<String> getTraceIdsWithoutExistingLogs(
    Set<String> traceIds,
    Map<String, Log__c> traceIdAndLogMap
  ) {
    Set<String> traceIdsWithoutExistingLog = new Set<String>();
    for (String traceId : traceIds) {
      if (!traceIdAndLogMap.keySet().contains(traceId)) {
        traceIdsWithoutExistingLog.add(traceId);
      }
    }
    return traceIdsWithoutExistingLog;
  }

  /**
   * @description Create logs for trace Ids that do not have existing log records
   * @param traceIdsWithoutLog A set of trace Ids without existing log records
   * @param traceIdAndlogDetailsListMap A map of trace Id and their list of log events
   * @return traceIdAndLogIdMap Map of TraceId and list of Log__c records' Ids
   */
  @TestVisible
  private static Map<String, Id> createLogs(
    Set<String> traceIdsWithoutLog,
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap
  ) {
    if (!Schema.sObjectType.Log__c.isCreateable()) {
      return new Map<String, Id>();
    }

    List<Log__c> logs = new List<Log__c>();
    Map<String, Id> traceIdAndLogIdMap = new Map<String, Id>();
    for (String traceId : traceIdsWithoutLog) {
      LogEvent__e logDetailsWithoutLog = traceIdAndlogDetailsListMap.get(
          traceId
        )
        .get(0);
      logs.add(createLogRecord(logDetailsWithoutLog));
    }
    /**
     * Using Database class instead of DML statement in order to capture the record Ids and allow partial success of a bulk DML operation
     */
    List<Database.SaveResult> saveResults = Database.insert(logs, false);
    List<Log__c> failedLogs = new List<Log__c>();
    for (Integer i = 0; i < saveResults.size(); i++) {
      if (saveResults[i].isSuccess()) {
        traceIdAndLogIdMap.put(logs[i].TraceId__c, saveResults[i].getId());
      } else {
        failedLogs.add(logs[i]);
      }
    }
    if (failedLogs.size() > 0) {
      throw new DatabaseException(
        'Failed to insert the following log records: ' +
        JSON.serialize(failedLogs)
      );
    }
    return traceIdAndLogIdMap;
  }

  /**
   * @description Custom exception for Database insert action
   */
  public class DatabaseException extends Exception {
  }
}
