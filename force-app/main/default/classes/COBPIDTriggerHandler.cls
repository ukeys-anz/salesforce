/**
 * @description COBPIDTriggerHandler is the handler class for COB PID Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Batya Aisman Sufrin
 * @since 05/2023
 */
public with sharing class COBPIDTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public COBPIDTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    COBPIDActions.setOCRMatch(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    COBPIDActions.setOCRMatch(records);
  }
}
