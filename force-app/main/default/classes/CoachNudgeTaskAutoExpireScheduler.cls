/**
 * @author Hrushikesh Pathak
 * @since 02/2024
 * @description  Expire All the Coach Nudge Task if due date is reached.
 */
public with sharing class CoachNudgeTaskAutoExpireScheduler implements Schedulable {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final CoachNudgeRepository COACH_NUDGE_REPOSITORY = (CoachNudgeRepository) Lib_InstanceProvider.forType(
    CoachNudgeRepository.class
  );
  /**
   * @description execute method to run logic to expire the task
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    List<Task> tasksToUpdate = new List<Task>();
    List<Task> taskRecords = COACH_NUDGE_REPOSITORY.queryTasksToExpire();
    tasksToUpdate = checkAndUpdateTaskRecords(taskRecords);
    DML_REPOSITORY.updateRecords(
      tasksToUpdate,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.SYSTEM_MODE
    );
  }

  /**
   * @description updateds task record to expired status
   * @param taskRecords task records
   * @return List<Task> task records after updating
   */
  public static List<Task> checkAndUpdateTaskRecords(List<Task> taskRecords) {
    List<Task> tasksToUpdate = new List<Task>();
    for (Task taskRecord : taskRecords) {
      if (!(taskRecord.OwnerId.getSobjectType() == Group.getSobjectType())) {
        continue;
      }
      taskRecord.Status = GetHelpTaskActions.TASK_STATUS_EXPIRED;
      taskRecord.Sub_Status__c = GetHelpTaskActions.TASK_SUB_STATUS_AUTO_CANCELLED;
      tasksToUpdate.add(taskRecord);
    }
    return tasksToUpdate;
  }
}
