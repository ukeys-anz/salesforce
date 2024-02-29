/**
 * @author Hrushikesh Pathak
 * @since 02/2024
 * @description  Expire All the Coach Nudge Task if due date is reached.
 */
public with sharing class CoachNudgeTaskAutoExpireScheduler implements Schedulable {
  /**
   * @description execute method to run logic to expire the task
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    List<Task> tasksToUpdate = new List<Task>();
    List<Task> taskRecords = [
      SELECT Id, Status, OwnerId
      FROM Task
      WHERE
        ActivityDate < TODAY
        AND ActivityDate = LAST_N_DAYS:2
        AND Status = :GetHelpTaskActions.TASK_STATUS_NOT_STARTED
        AND RecordTypeId = :GetHelpConstants.COACH_NUDGE_RT_ID
    ];

    tasksToUpdate = checkAndUpdateTaskRecords(taskRecords);
    if (!tasksToUpdate.isEmpty()) {
      DMLUtil.updateRecords(
        tasksToUpdate,
        DMLUtil.ALLOW_PARTIAL_UPDATE,
        DMLUtil.SYSTEM_MODE
      );
    }
  }

  /**
   * @description updateds task record to expired status
   * @param taskRecords task records
   * @return List<Task> task records after updating
   */
  public static List<Task> checkAndUpdateTaskRecords(List<Task> taskRecords) {
    List<Task> tasksToUpdate = new List<Task>();
    for (Task taskRecord : taskRecords) {
      if (String.valueOf(taskRecord.OwnerId).startsWith('00G')) {
        taskRecord.Status = GetHelpTaskActions.TASK_STATUS_EXPIRED;
        tasksToUpdate.add(taskRecord);
      }
    }
    return tasksToUpdate;
  }
}
