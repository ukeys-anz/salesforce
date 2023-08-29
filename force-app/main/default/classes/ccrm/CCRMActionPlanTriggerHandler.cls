/**
 * @author Ankita Kumari
 * @since 07/2023
 * @description CCRM Action Plan ctrigger Handler.
 */
public class CCRMActionPlanTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CCRMActionPlanTriggerHandler
   */
  public CCRMActionPlanTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    CCRMActionplanActions.updateTaskRecordType(
      (Map<Id, ActionPlan>) Trigger.newMap
    );
  }
}
