/**
 * @author Sahil S
 * @since 09/2021
 * @description  To schedule CCRMLeadExpiryBatch class
 */
public with sharing class CCRMLeadExpiryScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @name execute
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    CCRMLeadExpiryBatch batch = new CCRMLeadExpiryBatch();
    Database.executeBatch(batch);
  }
}
