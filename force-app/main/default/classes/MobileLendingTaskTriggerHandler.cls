/**
 * @author       : Ashish Kumar
 * @since        : Nov 2025
 * @description  : MobileLendingTaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public class MobileLendingTaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingTaskTriggerHandler
   */
  public MobileLendingTaskTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Mobile Lending Task records
   * @param record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Task taskRecord = (Task) record;
    return taskRecord.RecordTypeId == RTTask.mlcrmTask;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    MobileLendingtTaskActions.validateActivityDate(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    MobileLendingtTaskActions.validateActivityDate(
      records,
      (Map<Id, Task>) oldMap
    );
  }
}
