/**
 * @author Sahil S
 * @since 10/2021
 * @description  To schedule CCRMLeadExpiryReminderBatch class
 */
public with sharing class CCRMLeadExpiryReminderScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @name execute
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    CCRMLeadExpiryReminderBatch batch = new CCRMLeadExpiryReminderBatch();
    Database.executeBatch(batch);
  }
}
