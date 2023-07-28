/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2023
 * @description handler class for ContactToContactTrigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class ContactToContactTriggerHandler extends Lib_TriggerHandler {
  /** @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMContactToContactActions.setExternalId(records);
  }
}
