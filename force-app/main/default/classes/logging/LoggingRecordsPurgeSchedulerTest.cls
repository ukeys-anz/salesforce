/**
 * @author Nakul Kumar
 * @since June 2022
 * @description Test class for {@link LoggingRecordsPurgeScheduler}
 */

@IsTest
public with sharing class LoggingRecordsPurgeSchedulerTest {
  @TestSetup
  static void setUp() {
    LogsPurgingSettings__c logsPurgingSettings = new LogsPurgingSettings__c(
      LogsRetentionDays__c = 30
    );
    insert logsPurgingSettings;
  }

  @IsTest
  static void testLoggingRecordsPurgerSchedulerWithDefaultBatchSize() {
    String cronExp = '0 0 13 * * ?';
    Id jobId;
    Test.startTest();
    jobId = System.schedule(
      'Logging Records Purge Batch Job' + System.now(),
      cronExp,
      new LoggingRecordsPurgeScheduler()
    );
    Test.stopTest();
    System.assert(jobId != null, 'LoggingRecordsPurgerScheduler() is not run!');
  }

  @IsTest
  static void testLoggingRecordsPurgerSchedulerWithUserDefinedBatchSize() {
    String cronExp = '0 0 13 * * ?';
    Id jobId;
    Test.startTest();
    jobId = System.schedule(
      'Logging Records Purge Batch Job' + +System.now(),
      cronExp,
      new LoggingRecordsPurgeScheduler(2000)
    );
    Test.stopTest();
    System.assert(jobId != null, 'LoggingRecordsPurgerScheduler() is not run!');
  }
}
