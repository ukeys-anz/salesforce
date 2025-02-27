/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description Scheduling the class weekly to delete inactive ContactPoint records
 */
public with sharing class DeleteContactPointScheduler implements Schedulable {
  /**
   * @description tto execute batch which deletes inactive ContactPoint records
   * @param sc The context information for the scheduled job.
   */
  public void execute(SchedulableContext sc) {
    Database.executeBatch(new DeleteContactPointBatch('ContactPointEmail'));
    Database.executeBatch(new DeleteContactPointBatch('ContactPointPhone'));
    Database.executeBatch(new DeleteContactPointBatch('ContactPointAddress'));
  }
}
