/**
 * @description       : Test Class for FilesCleanupSchedular
 * @author            : Anuj Jain - JOIN Squad
 * @group             :
 * @last modified on  : 05-06-2024
 * @last modified by  : Anuj Jain - JOIN Squad
 **/
@IsTest
public with sharing class DAONFilesCleanupSchedularTest {
  @isTest
  static void testSchedulerWithNoCronExpr() {
    Test.startTest();
    String cronExp = '';
    String jobId = DAONFilesCleanupSchedular.schedule(
      'DAONFilesCleanupScheduler Test Job',
      cronExp
    );

    CronTrigger ct = [
      SELECT Id, CronExpression
      FROM CronTrigger
      WHERE id = :jobId
    ];

    Test.stopTest();

    System.assertEquals(
      '0 0 */1 ? * *',
      ct.CronExpression,
      'DAONFilesCleanupScheduler should be invoked every 1 hours.'
    );

    System.assertNotEquals(
      null,
      jobId,
      'Should have a DAONFilesCleanupScheduler job scheduled.'
    );
  }

  @isTest
  static void testSchedulerError() {
    Test.startTest();

    String cronExp = '';
    String jobId = DAONFilesCleanupSchedular.schedule('', cronExp);

    Test.stopTest();
  
    System.assertEquals(null, jobId, 'Should return null');
  }
}