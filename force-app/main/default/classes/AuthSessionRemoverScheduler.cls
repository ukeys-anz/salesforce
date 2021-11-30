/**
 * @author Victor
 * @since 11/2021
 * @description  To schedule AuthSessionRemoverBatch class
 */
public with sharing class AuthSessionRemoverScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    AuthSessionRemoverBatch batch = new AuthSessionRemoverBatch();
    Database.executeBatch(batch);
  }

  /**
   * @description schedule method to invoke schedule job
   * @param jobName
   * @param cronExp
   * @return String job Id
   */
  public static String schedule(String jobName, String cronExp) {
    if (String.isBlank(jobName) || String.isBlank(cronExp)) {
      return null;
    }

    AuthSessionRemoverScheduler job = new AuthSessionRemoverScheduler();

    return System.schedule(jobName, cronExp, job);
  }
}
