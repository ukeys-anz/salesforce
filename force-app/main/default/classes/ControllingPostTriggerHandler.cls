/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description ControllingPostTriggerHandler is the handler class for Controlling_Post__c Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class ControllingPostTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name ControllingPostTriggerHandler
   */
  public ControllingPostTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMControllingPostActions.setResponsibleEmployee(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMControllingPostActions.setResponsibleEmployee(
      records,
      (Map<Id, Controlling_Post__c>) oldMap
    );
  }
}
