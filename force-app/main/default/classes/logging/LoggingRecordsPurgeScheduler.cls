/**
 * @author Nakul Kumar
 * @since June 2022
 * @description Apex scheduler to run the apex class, LoggingRecordsPurgeBatch
 */

public with sharing class LoggingRecordsPurgeScheduler implements System.Schedulable {
  private final Integer batchSize;

  /**
   * @description Default constructor.  Sets initial batch size to 200.
   */
  public LoggingRecordsPurgeScheduler() {
    this(200);
  }

  /**
   * @description Construct that accepts the batch size as a parameter.
   * @param batchSize - The size of the records per batch job / instance.  Max is 5000. Minium is 1.
   */
  public LoggingRecordsPurgeScheduler(Integer batchSize) {
    this.batchSize = batchSize;
  }

  /**
   * @description Required by the Database.Schedulable interface, this method kicks off the LoggingRecordsPurgeBatch batch class
   * on a scheduled basis.
   * @param schedulableContext Required for the Schedulable interface, this method contains contextual information about when this instance is/was scheduled.
   */
  public void execute(SchedulableContext schedulableContext) {
    Database.executebatch(new LoggingRecordsPurgeBatch(), this.batchSize);
  }
}
