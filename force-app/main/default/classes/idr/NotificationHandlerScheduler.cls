/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  To schedule NotificationHandlerBatch class
 */
public with sharing class NotificationHandlerScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    NotificationHandlerBatch batch = new NotificationHandlerBatch();
    Database.executeBatch(batch);
  }
}
