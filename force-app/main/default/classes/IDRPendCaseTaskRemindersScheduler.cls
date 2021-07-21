/**
 * @author Adnan
 * @since 07/2021
 * @description  To schedule IDRPendCaseTaskRemindersBatch class
 */
public with sharing class IDRPendCaseTaskRemindersScheduler {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    IDRPendCaseTaskRemindersBatch batch = new IDRPendCaseTaskRemindersBatch();
    Database.executeBatch(batch);
  }
}
