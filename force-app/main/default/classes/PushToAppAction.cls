/**
 * @author Kopal Goswami
 * @since April 2025
 * @description This class is used to perform Task DML operations on Customer action on Mobile App
 */
public with sharing class PushToAppAction {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final PushToAppRepository PUSHTOAPP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description this method is used to append TaskNumber field autonumber value to the Subject after creation and taskid into pubSubEventId
   * @param taskRecords list of Customer Nudge task records for which update to be done
   */
  public static void updateCustomerNudgeTask(List<Task> taskRecords) {
    try {
      List<Task> tasksToUpdate = new List<Task>();
      for (Task taskRec : taskRecords) {
        Task taskRecRef = new Task(Id = taskRec.Id);
        taskRecRef.Subject = taskRec.TaskNumber__c + ' - ' + taskRec.Subject;
        taskRecRef.Pub_Sub_Event_Id__c =
          taskRec.Pub_Sub_Event_Id__c +
          '_' +
          taskRec.Id;
        tasksToUpdate.add(taskRecRef);
      }
      DML_REPOSITORY.doUpdate(tasksToUpdate);
    } catch (Exception objException) {
      Logger.error(
          'Push To App Customer Nudge Task Update Failed with error message: ',
          objException
        )
        .save();
      throw objException;
    }
  }

  /**
   * @description this method is used to update related Customer Nudge task to Auto Expire
   * @param casesToUpdate list of Customer Complaint cases for which related push to app tasks to auto expire
   */
  public static void autoExpireCustomerNudgeTask(List<Case> casesToUpdate) {
    try {
      Set<Id> caseRecIds = ListUtil.getIds(casesToUpdate, Case.Id);
      List<Task> tasksToUpdate = PUSHTOAPP_REPOSITORY.getRelatedCustomerNudgeTasksByType(
        caseRecIds,
        PushToAppConstant.PUSH_TO_APP_TASK_TYPE
      );
      ListUtil.setField(tasksToUpdate, Task.Status, 'TASK_STATE_AUTO_ARCHIVED');
      /** 
       *  
        Reason for System Mode:
        Update the task in System mode because, during case escalation, IDR/CMOS users who do not own the
        related task lack permission to update it—causing the task to shift to TASK_STATE_AUTO_ARCHIVED.
        System context ensures the task is updated correctly regardless of record ownership.
      */
      DML_REPOSITORY.doUpdate(
        tasksToUpdate,
        new DmlConfig().systemMode().withoutSharing()
      );
    } catch (Exception objException) {
      Logger.error(
          'Push To App Customer Nudge Task To Auto Expire Update Failed with error message: ',
          objException
        )
        .save();
      throw objException;
    }
  }

  /**
   * @description this method is used to update related TASK_TYPE_ID_UPLOAD customer nudge tasks to customer archived
   * @param casesToUpdate list of KYC QA Case records for which related tasks should be archived
   */
  public static void archiveCustomerNudgeUploadTasks(List<Case> casesToUpdate) {
    try {
      Set<Id> caseRecIds = ListUtil.getIds(casesToUpdate, Case.Id);
      List<Task> tasksToUpdate = PUSHTOAPP_REPOSITORY.getRelatedCustomerNudgeTasksByType(
        caseRecIds,
        PushToAppConstant.ID_UPLOAD_TASK_TYPE
      );
      ListUtil.setField(
        tasksToUpdate,
        Task.Status,
        'TASK_STATE_CUSTOMER_ARCHIVED'
      );
      DML_REPOSITORY.doUpdate(
        tasksToUpdate,
        new DmlConfig().systemMode().withoutSharing()
      );
    } catch (Exception objException) {
      Logger.error(
          'Push To App Customer Nudge Task Archive Update Failed with error message: ',
          objException
        )
        .save();
    }
  }
}
