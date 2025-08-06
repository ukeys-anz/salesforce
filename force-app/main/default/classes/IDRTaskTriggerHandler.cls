/**
 * @author CMOS
 * @since 06/2025
 * @description  IDRTaskTriggerHandler is the handler class for Handling task actions.
 */
public class IDRTaskTriggerHandler extends Lib_TriggerHandler {
  private static final String IDR_TASK_SUBJECT = 'Please Review PSI';
  Set<Id> eligibleRecordTypes = new Set<Id>{
    RTTask.idrTask,
    RTTask.idrSystemTask
  };
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public IDRTaskTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of IDR_Task and IDR_System_Task record types
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record type  is either IDR_Task  or IDR_System_Task else false
   */
  public override Boolean isValidRecord(SObject record) {
    Id taskRTId = ((Task) record).RecordTypeId;
    return eligibleRecordTypes.contains(taskRTId);
  }
  /**
   * @description onAfterInsert to handle after Insert trigger actions.
   */
  public override void onAfterInsert() {
    List<Task> filteredTasksToProcess = new List<Task>();
    filteredTasksToProcess.addAll(
      (List<Task>) ListUtil.filter(records)
        .equals(Task.Subject, IDR_TASK_SUBJECT)
        .equals(Task.OwnerId, QueryQueue.get('Systemic_Issue_Team').Id)
        .toList()
    );
    filteredTasksToProcess.addAll(
      (List<Task>) ListUtil.filter(records)
        .equals(Task.OwnerId, QueryQueue.get('Admin_Requests').Id)
        .toList()
    );

    IDRTaskSendNotification.sendNotifications(filteredTasksToProcess);
  }
}
