/**
 * @author Karen Valeriano
 * @since November 2022
 * @description test class for  CFaasFilesCleanupScheduler
 */

@isTest
public with sharing class CFaasFilesCleanupSchedulerTest {
  @isTest
  static void testSchedulerWithNoCronExpr() {
    Test.startTest();

    // GIVEN that no specific CronExpression is provided
    String cronExp = '';

    // WHEN the scheduler is run
    String jobId = CFaasFilesCleanupScheduler.schedule(
      'CFaasFilesCleanupScheduler Test Job',
      cronExp
    );
    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression
      FROM CronTrigger
      WHERE id = :jobId
    ];

    Test.stopTest();

    // THEN the default cronExpression will be used, which is every 2 hours
    System.assertEquals(
      '0 0 */2 ? * *',
      ct.CronExpression,
      'CFaasFilesCleanupScheduler should be invoked every 2 hours.'
    );

    // AND a JobID will be created for the scheduler
    System.assertNotEquals(
      null,
      jobId,
      'Should have a CFaasFilesCleanupScheduler job scheduled.'
    );
  }
}
