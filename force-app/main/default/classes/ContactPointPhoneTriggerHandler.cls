/**
 * @author Fawad Akhtar
 * @since 03/2023
 * @description ContactPointPhoneTriggerHandler is the handler class for ContactPointPhone Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactPointPhoneActionsTest
 */
public with sharing class ContactPointPhoneTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onBeforUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMContactPointActions.updateContactPoints(records);
  }
}
