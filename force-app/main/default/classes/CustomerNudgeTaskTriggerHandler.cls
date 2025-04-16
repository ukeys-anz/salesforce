/**
 * @author Shivam Swaraj
 * @since October 2024
 * @description  CustomerNudgeTaskTriggerHandler is the handler class for Customer Nudge TaskTrigger.
 */
public with sharing class CustomerNudgeTaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CustomerNudgeTaskTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Customer Nudge Task records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Task) record).RecordTypeId == RTTask.customerNudge;
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Task> taskWithChangedStatus = ListUtil.filter(records, oldMap)
      .changed(Task.Status)
      .toList();
    PushToAppAction.createTaskCloudEvent(taskWithChangedStatus);
  }

  /**
   * @description onAfterInsert update the task subject by appending the task number generated
   */
  public override void onAfterInsert() {
    PushToAppAction.createTaskCloudEvent(records);
  }
}
