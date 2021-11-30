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
   * @param cronExp
   * @return String job Id
   */
  public static String schedule(String cronExp) {
    AuthSessionRemoverScheduler job = new AuthSessionRemoverScheduler();

    if (String.isBlank(cronExp)) {
      return null;
    }

    return System.schedule('Batch Delete Long Lived AuthSession', cronExp, job);
  }
}
