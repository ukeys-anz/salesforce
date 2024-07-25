/**
 * @author Naman Garg
 * @since 12/2023
 * @description  To schedule CCRMPopulateCPIDUserBatch class
 */
public with sharing class CCRMPopulateCPIDUserScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @name execute
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    CCRMPopulateCPIDUserBatch batch = new CCRMPopulateCPIDUserBatch();
    Database.executeBatch(batch);
  }
}
