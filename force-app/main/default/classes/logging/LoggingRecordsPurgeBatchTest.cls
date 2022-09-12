/**
 * @author Nakul Kumar
 * @since June 2022
 * @description Test class for {@link LoggingRecordsPurgeScheduler}
 */

@IsTest
public with sharing class LoggingRecordsPurgeBatchTest {
  @TestSetup
  static void setup() {
    LogsPurgingSettings__c logsPurgingSettings = new LogsPurgingSettings__c(
      LogsRetentionDays__c = 30
    );
    insert logsPurgingSettings;
    LoggingSettings__c loggingSetting = new LoggingSettings__c(
      SetupOwnerId = UserInfo.getUserId(),
      DefaultLoggingLevel__c = 'DEBUG',
      DefaultSaveMethod__c = 'EVENT_BUS',
      SecureLogEnabled__c = true
    );
    insert loggingSetting;
    Log__c log = new Log__c(
      StartTime__c = datetime.now(),
      EnvironmentType__c = 'Sandbox'
    );
    insert log;
    Test.setCreatedDate(log.Id, Date.today().addDays(-30));
    LogEntry__c logEntry = new LogEntry__c(Log__c = log.Id);
    insert logEntry;
    Test.setCreatedDate(logEntry.Id, Date.today().addDays(-30));
    SecureLogEntry__c secureLogEntry = new SecureLogEntry__c(Log__c = log.Id);
    insert secureLogEntry;
  }

  @IsTest
  static void testLoggingRecordsPurgeBatchDefault() {
    Integer logRetentionDuration = Integer.valueOf(
      LoggingRecordsPurgeBatch.logPurgingSettings.LogsRetentionDays__c
    );
    DateTime dateToPurge = Date.today().addDays(-logRetentionDuration);
    System.assert(
      Database.countquery('SELECT COUNT() From LoggingSettings__c') > 0,
      'Check if LoggingSettings__c records exist!'
    );
    System.assert(
      Database.countquery('SELECT COUNT() From SecureLogEntry__c') > 0,
      'Check if SecureLogEntry__c records exist!'
    );
    System.assert(
      Database.countquery(
        'SELECT COUNT() From LogEntry__c Where CreatedDate <=: dateToPurge'
      ) > 0,
      'Check if LogEntry__c records exist!'
    );
    System.assert(
      Database.countquery(
        'SELECT COUNT() From Log__c Where CreatedDate <=: dateToPurge'
      ) > 0,
      'Check if Log__c records exist!'
    );
    Test.startTest();
    Database.executeBatch(new LoggingRecordsPurgeBatch());
    Test.stopTest();
    System.assert(
      Database.countquery('SELECT COUNT() From LoggingSettings__c') == 0,
      'Check if LoggingSettings__c records are deleted!'
    );
    System.assert(
      Database.countquery('SELECT COUNT() From SecureLogEntry__c') == 0,
      'Check if SecureLogEntry__c records are deleted'
    );
    System.assert(
      Database.countquery(
        'SELECT COUNT() From LogEntry__c Where CreatedDate <=: dateToPurge'
      ) == 0,
      'Check if LogEntry__c records are deleted'
    );
    System.assert(
      Database.countquery(
        'SELECT COUNT() From Log__c Where CreatedDate <=: dateToPurge'
      ) == 0,
      'Check if Log__c records are deleted'
    );
  }
}
