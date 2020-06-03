/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2020
 * @description  To schedule BatchUpdateCaseDuration class for every one hour
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ScheduleUpdateCaseDuration implements Schedulable {
  //CRON expression to schedule every hour
  public static String cronExp = '0 0 * * * ?';

  /**
   * @description returns scheduler string which will be executed in Anonymous window.
   * @return System.schedule
   */

  global static String scheduleMe() {
    ScheduleUpdateCaseDuration sc = new ScheduleUpdateCaseDuration();
    return System.schedule('Batch Update Case Duration', cronExp, sc);
  }
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */

  global void execute(SchedulableContext sc) {
    BatchUpdateCaseDuration b = new BatchUpdateCaseDuration();
    Database.executeBatch(b);
  }
}
