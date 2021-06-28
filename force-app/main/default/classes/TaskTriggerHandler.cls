/**
 * @description TaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Boobalakrishnan Duraisamy
 * @since 02/2021
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
    IDRTaskActions.beforeInsertActions(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRTaskActions.beforeUpdateActions(records, (Map<Id, Task>) oldMap);
  }
}
