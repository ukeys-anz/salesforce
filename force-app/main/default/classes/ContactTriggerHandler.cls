/**
 * @author Tan Phan
 * @since 09/2022
 * @description ContactTriggerHandler is the handler class for Contact Trigger which extends Lib_TriggerHandler from the trigger framework used.
 * @runTests CCRMContactActionsTest
 */

public with sharing class ContactTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Before Insert Action of Contact.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
  }

  /**
   * @description After Insert Action of Contact.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
  }
  /**
   * @description Before Update Action of Contact.
   * @name onBeforeUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of contact.
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
  }
}
