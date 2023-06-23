/**
 * @author Jasmine Nguyen
 * @since July 2022
 * @description Test class for {@link LogEventAction}
 */
@SuppressWarnings(
  'PMD.AvoidHardcodingId, PMD.CyclomaticComplexity'
) // PMD.AvoidHardcodingId - The hardcoded Id is used for field value comparison, not insertion so will not caused issue when deployed to another environment. Cannot use random string as Apex requires a correctly formatted Id.
@isTest
public with sharing class LogEventActionTest {
  @isTest
  static void testProcessLogEvents() {
    LogEvent__e logEvent = new LogEvent__e(
      APIVersion__c = '53.0',
      EnvironmentType__c = 'Sandbox',
      InstanceName__c = 'TestD',
      TraceId__c = 'abcdef123',
      Payload__c = 'Sensitive payload'
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>{ logEvent };
    Test.startTest();
    LogEventActions.processLogEvents(logEvents);
    Test.stopTest();
    List<Log__c> logs = [SELECT Id FROM Log__c];
    List<LogEntry__c> logEntries = [SELECT Id FROM LogEntry__c];
    List<SecureLogEntry__c> secureLogEntries = [
      SELECT Id
      FROM SecureLogEntry__c
    ];
    System.assertEquals(1, logs.size(), 'Log record should have been created');
    System.assertEquals(
      1,
      logEntries.size(),
      'Log entry record should have been created'
    );
    System.assertEquals(
      1,
      secureLogEntries.size(),
      'Secure log entry record should have been created'
    );
  }

  @isTest
  static void testCreateLogRecordSuccessful() {
    DateTime startTime = DateTime.now();
    String traceId = 'TI_' + String.valueOf(startTime);
    LogEvent__e logEvent = new LogEvent__e(
      APIVersion__c = '53.0',
      EnvironmentType__c = 'Sandbox',
      InstanceName__c = 'TestD',
      StartTime__c = startTime,
      TraceId__c = traceId,
      TransactionContext__c = 'TC_' + String.valueOf(startTime),
      UserProfile__c = 'SystemAdministrator',
      UserRole__c = 'Engineer',
      UserId__c = '0052O000003Ublw'
    );
    Test.startTest();
    Log__c log = LogEventActions.createLogRecord(logEvent);
    Test.stopTest();
    System.assertEquals(
      logEvent.APIVersion__c,
      log.APIVersion__c,
      'API version should match'
    );
    System.assertEquals(
      logEvent.EnvironmentType__c,
      log.EnvironmentType__c,
      'Environment type should match'
    );
    System.assertEquals(
      logEvent.InstanceName__c,
      log.InstanceName__c,
      'Instance name should match'
    );
    System.assertEquals(
      logEvent.StartTime__c,
      log.StartTime__c,
      'Start time should match'
    );
    System.assertEquals(
      logEvent.TraceId__c,
      log.TraceId__c,
      'Trace Id should match'
    );
    System.assertEquals(
      logEvent.TransactionContext__c,
      log.TransactionContext__c,
      'Transaction context should match'
    );
    System.assertEquals(
      logEvent.UserProfile__c,
      log.UserProfile__c,
      'User profile should match'
    );
    System.assertEquals(
      logEvent.UserRole__c,
      log.UserRole__c,
      'User role should match'
    );
    System.assertEquals(
      logEvent.UserId__c,
      log.UserId__c,
      'User Id should match'
    );
  }

  @isTest
  static void testCreateSecureLogEntryRecord() {
    Log__c log = new Log__c();
    insert log;

    LogEvent__e logEvent = new LogEvent__e(
      ApexClassName__c = 'LogEvenHandler',
      ApexMethodName__c = 'testPublishLogEvent',
      Payload__c = 'Test Payload with PII data',
      SpanId__c = 'abc123def',
      RecordsJson__c = '"id":"0012N00000ABCDEQA5", "CaseNumber" : "12345"'
    );
    Test.startTest();
    SecureLogEntry__c secureLogEntry = LogEventActions.createSecureLogEntryRecord(
      logEvent,
      log.Id
    );
    Test.stopTest();
    System.assertEquals(
      secureLogEntry.ApexClassName__c,
      logEvent.ApexClassName__c,
      'Apex class name should match'
    );
    System.assertEquals(
      secureLogEntry.ApexMethodName__c,
      logEvent.ApexMethodName__c,
      'Apex method name should match'
    );
    System.assertEquals(
      secureLogEntry.Payload__c,
      logEvent.Payload__c,
      'Payload should match'
    );
    System.assertEquals(
      secureLogEntry.SpanId__c,
      logEvent.SpanId__c,
      'Span Id should match'
    );
    System.assertEquals(
      secureLogEntry.RecordsJson__c,
      logEvent.RecordsJson__c,
      'Records Json should match'
    );
    System.assertEquals(secureLogEntry.Log__c, log.Id, 'Log Id should match');
  }

  @isTest
  static void testCreateLogEntryRecord() {
    Log__c log = new Log__c();
    insert log;

    LogEvent__e logEvent = new LogEvent__e(
      ApexClassName__c = 'LogEvenHandler',
      ApexMethodName__c = 'testPublishLogEvent',
      BrowserName__c = 'Chrome',
      ComponentName__c = 'TransactionHistory',
      DatabaseResult__c = '{"id":"0012N00000ABCDEQA5","success":false,"errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}]}',
      ExceptionMessage__c = 'Insertion failed',
      ExceptionType__c = 'DML',
      LogMessage__c = 'Test log message',
      LoggingLevel__c = 'INFO',
      Origin__c = 'Apex',
      RecordId__c = '0012N00000ABCDEQA',
      RecordObjectName__c = 'Case',
      SpanId__c = 'abc123def',
      StackTrace__c = 'Test stack trace',
      UsedCallouts__c = 100,
      UsedCPUTime__c = 200,
      UsedDMLStatements__c = 100,
      UsedFutureCalls__c = 5,
      UsedHeapSize__c = 1024,
      UsedQueueableJobs__c = 4,
      UsedSOQLQueries__c = 150
    );
    Test.startTest();
    LogEntry__c logEntry = LogEventActions.createLogEntryRecord(
      logEvent,
      log.Id
    );
    Test.stopTest();
    System.assertEquals(
      logEntry.ApexClassName__c,
      logEvent.ApexClassName__c,
      'Apex name should match'
    );
    System.assertEquals(
      logEntry.ApexMethodName__c,
      logEvent.ApexMethodName__c,
      'Apex method name should match'
    );
    System.assertEquals(
      logEntry.BrowserName__c,
      logEvent.BrowserName__c,
      'Browser name should match'
    );
    System.assertEquals(
      logEntry.ComponentName__c,
      logEvent.ComponentName__c,
      'Component name should match'
    );
    System.assertEquals(
      logEntry.DatabaseResult__c,
      logEvent.DatabaseResult__c,
      'Database result should match'
    );
    System.assertEquals(
      logEntry.ExceptionMessage__c,
      logEvent.ExceptionMessage__c,
      'Exception message should match'
    );
    System.assertEquals(
      logEntry.ExceptionType__c,
      logEvent.ExceptionType__c,
      'Exception type should match'
    );
    System.assertEquals(
      logEntry.LogMessage__c,
      logEvent.LogMessage__c,
      'Log message should match'
    );
    System.assertEquals(
      logEntry.Origin__c,
      logEvent.Origin__c,
      'Origin should match'
    );
    System.assertEquals(
      logEntry.RecordId__c,
      logEvent.RecordId__c,
      'Record Id should match'
    );
    System.assertEquals(
      logEntry.RecordObjectName__c,
      logEvent.RecordObjectName__c,
      'Record object name should match'
    );
    System.assertEquals(
      logEntry.RecordObjectName__c,
      logEvent.RecordObjectName__c,
      'Record object name should match'
    );
    System.assertEquals(
      logEntry.SpanId__c,
      logEvent.SpanId__c,
      'Span Id should match'
    );
    System.assertEquals(
      logEntry.StackTrace__c,
      logEvent.StackTrace__c,
      'Stack trace name should match'
    );
    System.assertEquals(
      logEntry.UsedCallouts__c,
      logEvent.UsedCallouts__c,
      'Used callouts should match'
    );
    System.assertEquals(
      logEntry.UsedCPUTime__c,
      logEvent.UsedCPUTime__c,
      'Used CPU time should match'
    );
    System.assertEquals(
      logEntry.UsedDMLStatements__c,
      logEvent.UsedDMLStatements__c,
      'DML statements should match'
    );
    System.assertEquals(
      logEntry.UsedFutureCalls__c,
      logEvent.UsedFutureCalls__c,
      'Used future calls should match'
    );
    System.assertEquals(
      logEntry.UsedHeapSize__c,
      logEvent.UsedHeapSize__c,
      'Used heap size should match'
    );
    System.assertEquals(
      logEntry.UsedQueueableJobs__c,
      logEvent.UsedQueueableJobs__c,
      'Used queuable jobs should match'
    );
    System.assertEquals(
      logEntry.UsedSOQLQueries__c,
      logEvent.UsedSOQLQueries__c,
      'Used SOQL queries should match'
    );
    System.assertEquals(logEntry.Log__c, log.Id, 'Log Id should match');
  }

  @isTest
  static void testGetExistingLogRecords() {
    Log__c log = new Log__c(TraceId__c = 'abcdef123');
    insert log;
    Set<String> traceIds = new Set<String>{ log.TraceId__c };
    Test.startTest();
    Map<String, Log__c> existingLogRecords = LogEventActions.getExistingLogRecords(
      traceIds
    );
    Test.stopTest();
    Log__c returnedLog = existingLogRecords.values()[0];
    System.assertEquals(
      1,
      existingLogRecords.size(),
      '1 log record should be returned'
    );
    System.assertEquals(
      log.TraceId__c,
      returnedLog.TraceId__c,
      'Trace Id should match'
    );
  }

  @isTest
  static void testCreateLogEntryandSecureLogEntryRecords() {
    Log__c log = new Log__c(TraceId__c = 'abcdef123');
    insert log;

    Map<String, Id> traceIdAndLogIdMap = new Map<String, Id>{
      log.TraceId__c => log.Id
    };
    LogEvent__e logEvent = new LogEvent__e(
      APIVersion__c = '53.0',
      EnvironmentType__c = 'Sandbox',
      InstanceName__c = 'TestD',
      LogMessage__c = 'Test log message',
      TraceId__c = 'abcdef123',
      Payload__c = 'Sensitive payload'
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>{ logEvent };
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap = new Map<String, List<LogEvent__e>>{
      logEvent.TraceId__c => logEvents
    };
    Test.startTest();
    LogEventActions.createLogEntryAndSecureLogEntryRecords(
      traceIdAndlogDetailsListMap,
      traceIdAndLogIdMap
    );
    Test.stopTest();
    List<LogEntry__c> logEntries = [SELECT Id FROM LogEntry__c];
    List<SecureLogEntry__c> secureLogEntries = [
      SELECT Id, LogMessage__c
      FROM SecureLogEntry__c
    ];

    System.assertEquals(
      1,
      logEntries.size(),
      'Log entry record should have been created'
    );
    System.assertEquals(
      1,
      secureLogEntries.size(),
      'Secure log entry record should have been created'
    );
    System.assertEquals(
      'Test log message',
      secureLogEntries[0].LogMessage__c,
      'Secure log entry log message should match'
    );
  }

  @isTest
  static void testGetTraceIdsWithoutExistingLogs() {
    Set<String> traceIds = new Set<String>{ 'abc123', 'def456' };
    Log__c log = new Log__c(TraceId__c = 'abc123');
    Map<String, Log__c> traceIdWithLogMap = new Map<String, Log__c>{
      'abc123' => log
    };
    Test.startTest();
    Set<String> traceIdsWithoutExistingLog = LogEventActions.getTraceIdsWithoutExistingLogs(
      traceIds,
      traceIdWithLogMap
    );
    Test.stopTest();
    System.assertEquals(
      true,
      traceIdsWithoutExistingLog.contains('def456'),
      'Trace Id without log should match'
    );
  }

  @isTest
  static void testCreateLogs() {
    Set<String> traceIdsWithoutLog = new Set<String>{ 'abc123' };
    LogEvent__e logEvent = new LogEvent__e(
      APIVersion__c = '53.0',
      EnvironmentType__c = 'Sandbox',
      InstanceName__c = 'TestD',
      TraceId__c = 'abcdef123',
      Payload__c = 'Sensitive payload'
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>{ logEvent };
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap = new Map<String, List<LogEvent__e>>{
      'abc123' => logEvents
    };
    Test.startTest();
    LogEventActions.createLogs(traceIdsWithoutLog, traceIdAndlogDetailsListMap);
    Test.stopTest();
    List<Log__c> logs = [SELECT Id FROM Log__c];
    System.assertEquals(1, logs.size(), 'Log record should have been created');
  }

  @isTest
  static void testCreateLogsWithException() {
    Set<String> traceIdsWithoutLog = new Set<String>{ 'abc123' };
    LogEvent__e logEvent = new LogEvent__e(
      APIVersion__c = '53.0000000',
      EnvironmentType__c = 'Sandbox',
      InstanceName__c = 'TestD',
      TraceId__c = 'abcdef123',
      Payload__c = 'Sensitive payload'
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>{ logEvent };
    Map<String, List<LogEvent__e>> traceIdAndlogDetailsListMap = new Map<String, List<LogEvent__e>>{
      'abc123' => logEvents
    };
    Test.startTest();
    try {
      LogEventActions.createLogs(
        traceIdsWithoutLog,
        traceIdAndlogDetailsListMap
      );
    } catch (LogEventActions.DatabaseException de) {
      System.assertEquals(
        true,
        de.getMessage()
          .contains('Failed to insert the following log records: '),
        'Exception message should match'
      );
    }

    Test.stopTest();
    List<Log__c> logs = [SELECT Id FROM Log__c];
    System.assertEquals(
      0,
      logs.size(),
      'Log record should not have been created'
    );
  }
}
