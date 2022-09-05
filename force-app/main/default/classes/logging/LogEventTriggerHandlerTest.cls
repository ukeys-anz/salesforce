/**
 * @author Nakul Kumar, Jasmine Nguyen
 * @since July 2022
 * @description Test class for {@link LogEventTriggerHandler and LogEventTrigger}
 */

@IsTest
public with sharing class LogEventTriggerHandlerTest {
  @IsTest
  static void testPublishLogEventWithPayload() {
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
      ApexClassName__c = 'LogEvenHandler',
      ApexMethodName__c = 'testPublishLogEvent',
      LoggingLevel__c = 'INFO',
      Origin__c = 'Apex',
      Payload__c = 'Test Payload with PII data',
      UsedCallouts__c = 100,
      UsedCPUTime__c = 200,
      UsedDMLStatements__c = 100,
      UsedFutureCalls__c = 5,
      UsedHeapSize__c = 1024,
      UsedQueueableJobs__c = 4,
      UsedSOQLQueries__c = 150
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>();
    logEvents.add(logEvent);
    logEvents.add(logEvent.clone());
    Test.startTest();
    List<Database.SaveResult> results = EventBus.publish(logEvents);
    Test.stopTest();
    List<Log__c> logs = [
      SELECT Id, TraceId__c
      FROM Log__c
      WHERE TraceId__c = :traceId
    ];
    System.assert(logs.size() == 1, 'Error in Log creation');
    List<SecureLogEntry__c> secureLogEntries = [
      SELECT Id
      FROM SecureLogEntry__c
      WHERE Log__c = :logs[0].Id
    ];
    System.assert(
      secureLogEntries.size() == 2,
      'Error in Secure Log Entries creation'
    );
    List<LogEntry__c> logEntries = [
      SELECT Id
      FROM LogEntry__c
      WHERE Log__c = :logs[0].Id
    ];
    System.assertEquals(2, logEntries.size(), 'Error in Log Entries creation');
  }

  @IsTest
  static void testPublishLogEventWithoutPayload() {
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
      ApexClassName__c = 'LogEvenHandler',
      ApexMethodName__c = 'testPublishLogEvent',
      LoggingLevel__c = 'INFO',
      Origin__c = 'Apex',
      UsedCallouts__c = 100,
      UsedCPUTime__c = 200,
      UsedDMLStatements__c = 100,
      UsedFutureCalls__c = 5,
      UsedHeapSize__c = 1024,
      UsedQueueableJobs__c = 4,
      UsedSOQLQueries__c = 150
    );
    List<LogEvent__e> logEvents = new List<LogEvent__e>();
    logEvents.add(logEvent);
    Test.startTest();
    List<Database.SaveResult> results = EventBus.publish(logEvents);
    Test.stopTest();
    List<Log__c> logs = [
      SELECT Id, TraceId__c
      FROM Log__c
      WHERE TraceId__c = :traceId
    ];
    System.assert(logs.size() == 1, 'Error in Log creation');
    List<LogEntry__c> logEntries = [
      SELECT Id
      FROM LogEntry__c
      WHERE Log__c = :logs[0].Id
    ];
    System.assertEquals(1, logEntries.size(), 'Error in Log Entries creation');
  }
}
