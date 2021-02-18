/**
 * @author Himabindu Nekkanti
 * @since 02/2021
 * @description  TaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class TaskTriggerHandler extends Lib_TriggerHandler {
    /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
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
   * @description onBeforeInsert to handle before insert trigger actions.
   */
    public override void onAfterInsert() {
        IDRTaskActions.afterInsertActions(records);
    }
   /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
      IDRTaskActions.afterUpdateActions(records);  
  }
    
}