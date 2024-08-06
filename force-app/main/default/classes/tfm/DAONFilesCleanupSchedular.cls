/**
 * @description       : Schedular class to delete DAON Record Type Files from Content Document/ Version
 * @author            : Anuj Jain - JOIN Squad
 * @group             :
 * @last modified on  : 05-06-2024
 * @last modified by  : Anuj Jain - JOIN Squad
 **/
public with sharing class DAONFilesCleanupSchedular  implements Schedulable  {
  private static final Integer DEFAULT_ELAPSED_HOUR = 1; //default is 1 hours
  private static final Integer DEFAULT_ELAPSED_MINUTES = 0;
  private static final String DEFAULT_CRON_EXPRESSION = '0 0 */1 ? * *'; //defaulted to execute every 1 hours

  /**
   * @description Required by the Database.Schedulable interface, this method kicks off the CFaasFilesCleanup class
   * on a scheduled basis.
   * @param schedulableContext Required for the Schedulable interface, this method contains contextual information about when this instance is/was scheduled.
   */
  public void execute(SchedulableContext schedulableContext) {
    DAONFilesCleanup.processCleanup(DEFAULT_ELAPSED_HOUR, DEFAULT_ELAPSED_MINUTES);
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
        'No job name provided for scheduling the  Files Cleanup job'
      );
      Logger.saveLog();

      return null;
    } 

    if (String.isBlank(cronExp)) {
      cronExp = DEFAULT_CRON_EXPRESSION; //Use default (every 1 hours) if no cronExp is specified
    }

    DAONFilesCleanupSchedular job = new DAONFilesCleanupSchedular();

    return System.schedule(jobName, cronExp, job);
  }
}