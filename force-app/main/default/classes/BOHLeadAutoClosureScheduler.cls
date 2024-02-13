/**
 * @author Hrushikesh Pathak
 * @since 11/2023
 * @description  To schedule BOHLeadAutoClosureBatch class
 */
public with sharing class BOHLeadAutoClosureScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    BOHLeadAutoClosureBatch batch = new BOHLeadAutoClosureBatch();
    Database.executeBatch(batch);
  }
}
