/**
 * @author shawg2
 * @since January 2024
 * @description Schedulable class for COBOrphanedKYCQABatch class
 */

public with sharing class COBOrphanedKYCQAScheduler implements Schedulable {
  /**
   * @description Schedule COBOrphanedKYCQABatch class
   * @param context unused
   */
  public void execute(SchedulableContext context) {
    Database.executeBatch(new COBOrphanedKYCQABatch());
  }
}
