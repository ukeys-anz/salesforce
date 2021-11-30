/**
 * @author Victor
 * @since 11/2021
 * @description test class for AuthSessionRemoverScheduler
 */
@isTest
public with sharing class AuthSessionRemoverSchedulerTest {
  @isTest
  public static void testScheduleDelete() {
    Test.startTest();
    String cronExp = '0 0 */8 ? * *';

    String jobId = AuthSessionRemoverScheduler.schedule(cronExp);

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression
      FROM CronTrigger
      WHERE id = :jobId
    ];

    // Verify the expressions are the same
    System.assertEquals(
      cronExp,
      ct.CronExpression,
      'AuthSessionRemoverScheduler should be invoked every 8 hours.'
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      jobId,
      'Should have a AuthSessionRemover job scheduled.'
    );
  }
}
