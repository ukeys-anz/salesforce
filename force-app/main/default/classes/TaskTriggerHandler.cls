/**
 * @description TaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Shermal Warnakula
 * @since 03/2021
 */
public with sharing class TaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TaskTriggerHandler() {
    super();
  }
  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    GetHelpTaskActions.beforeInsertActions(records);
  }
}
