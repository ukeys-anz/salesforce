/**
 * @author Prakash
 * @since 03/2022
 * @description  ContactRequestTriggerHandler is the handler class for ContactRequestTrigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class ContactRequestTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterInsert etc.
   */
  public ContactRequestTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    ContactRequestTriggerActions.updateConfirmedCount(records);
  }
}
