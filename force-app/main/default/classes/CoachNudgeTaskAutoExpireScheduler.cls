/**
 * @author Aman Gupta
 * @since 01/2024
 * @description  To schedule CoachNudgeTaskAutoExpireBatch class
 */
public with sharing class CoachNudgeTaskAutoExpireScheduler implements Schedulable {
  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    CoachNudgeTaskAutoExpireBatch batch = new CoachNudgeTaskAutoExpireBatch();
    Database.executeBatch(batch);
  }
}
