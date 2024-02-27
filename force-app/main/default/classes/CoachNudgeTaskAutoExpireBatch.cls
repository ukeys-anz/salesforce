/**
 * @author Aman Gupta
 * @since 01/2024
 * @description  Expire All the Coach Nudge Task if due date is reached.
 */
public with sharing class CoachNudgeTaskAutoExpireBatch implements Database.Batchable<sObject>, schedulable {
  /**
   * @description Get all coach nudge task for due date in past
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT Id, Status, OwnerId
        FROM Task
        WHERE
          ActivityDate < TODAY
          AND ActivityDate = LAST_N_DAYS:3
          AND Status = 'Not Started'
          AND RecordTypeId = :GetHelpConstants.COACH_NUDGE_RT_ID
      ]
    );
  }

  /**
   * @description  Auto Expire the coach nudge task if criteria matches for the auto expire
   * @param bc Database.BatchableContext
   * @param taskRecords from start method
   */

  public void execute(Database.BatchableContext bc, List<Task> taskRecords) {
    List<Task> tasksToUpdate = new List<Task>();
    for (Task taskRecord : taskRecords) {
      if (String.valueOf(taskRecord.OwnerId).startsWith('00G')) {
        taskRecord.Status = 'Expired';
        tasksToUpdate.add(taskRecord);
      }
    }
    DMLUtil.updateRecords(
      tasksToUpdate,
      DMLUtil.ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }

  /**
   * @description execute method to run batch class
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    CoachNudgeTaskAutoExpireBatch batch = new CoachNudgeTaskAutoExpireBatch();
    Database.executeBatch(batch);
  }
}
