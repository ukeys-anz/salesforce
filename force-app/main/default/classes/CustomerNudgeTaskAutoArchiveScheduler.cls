/**
 * @author Shivam Swaraj
 * @since 10/2024
 * @description  Archive All the Customer Nudge Task if due date is reached.
 */
public with sharing class CustomerNudgeTaskAutoArchiveScheduler implements Schedulable {
  private static final String TASK_AUTO_ARCHIVED = 'ACTIVITY_STATE_AUTO_ARCHIVED';

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final PushToAppRepository CUSTOMER_NUDGE_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description execute method to run logic to auto archive the customer nudge task
   * @param sc SchedulableContext
   */
  public void execute(SchedulableContext sc) {
    List<Task> taskRecords = CUSTOMER_NUDGE_REPOSITORY.queryCustomerNudgeTasksToArchive();
    ListUtil.setField(taskRecords, Task.Status, TASK_AUTO_ARCHIVED);
    List<Database.SaveResult> recordsSaveResultList = DML_REPOSITORY.doUpdate(
      taskRecords,
      new DmlConfig().allowPartial().systemMode()
    );

    Logger.error(
      'Error while auto archiving the Customer Nudge Task record ' ,
      recordsSaveResultList
    ).save();
  }
}
