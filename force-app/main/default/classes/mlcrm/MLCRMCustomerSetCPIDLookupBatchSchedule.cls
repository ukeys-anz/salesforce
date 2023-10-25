/**
 * @author Ankit Garg
 * @since 31/July/2023
 * @description To schedule MLCRMCustomerSetCPIDLookupBatch class
 */
public with sharing class MLCRMCustomerSetCPIDLookupBatchSchedule implements Schedulable {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    MLCRMCustomerSetCPIDLookupBatch batch = new MLCRMCustomerSetCPIDLookupBatch();
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
    MLCRMCustomerSetCPIDLookupBatchSchedule job = new MLCRMCustomerSetCPIDLookupBatchSchedule();
    return System.schedule(jobName, cronExp, job);
  }
}
