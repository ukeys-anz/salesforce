/**
 * @author CMOS
 * @since 06/2025
 * @description  IDRTaskTriggerHandler is the handler class for Handling task actions.
 */
public class IDRTaskTriggerHandler extends Lib_TriggerHandler {
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
    set<Id> allowedQueues = new Set<Id>{
      QueryQueue.get('Admin_Requests').Id,
      QueryQueue.get('Systemic_Issue_Team').Id
    };
    List<Task> filteredTasks = ListUtil.filter(records)
      .anyEqual(new Set<SObjectField>{ Task.OwnerId }, allowedQueues)
      .toList();

    IDRTaskSendNotification.sendNotifications(filteredTasks);
  }
}
