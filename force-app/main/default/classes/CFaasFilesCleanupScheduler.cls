/**
 * @author Karen Valeriano
 * @since November 2022
 * @description  To schedule CFaasFilesCleanup class
 */
public with sharing class CFaasFilesCleanupScheduler implements Schedulable {
  private static final Integer DEFAULT_ELAPSED_HOUR = 2; //default is 2 hours
  private static final Integer DEFAULT_ELAPSED_MINUTES = 0;
  private static final String DEFAULT_CRON_EXPRESSION = '0 0 */2 ? * *'; //defaulted to execute every 2 hours

  /**
   * @description Required by the Database.Schedulable interface, this method kicks off the CFaasFilesCleanup class
   * on a scheduled basis.
   * @param schedulableContext Required for the Schedulable interface, this method contains contextual information about when this instance is/was scheduled.
   */
  public void execute(SchedulableContext schedulableContext) {
    CFaasFilesCleanup.processCleanup(
      DEFAULT_ELAPSED_HOUR,
      DEFAULT_ELAPSED_MINUTES
    );
  }

  /**
   * @description schedule method to invoke schedule job
   * @param jobName
   * @param cronExp
   * @return String job Id
   */
  public static String schedule(String jobName, String cronExp) {
    if (String.isBlank(jobName)) {
      Logger.error(
        'No job name provided for scheduling the CFaaS Files Cleanup job'
      );
      Logger.saveLog();

      return null;
    }

    if (String.isBlank(cronExp)) {
      cronExp = DEFAULT_CRON_EXPRESSION; //Use default (every 2 hours) if no cronExp is specified
    }

    CFaasFilesCleanupScheduler job = new CFaasFilesCleanupScheduler();

    return System.schedule(jobName, cronExp, job);
  }
}
