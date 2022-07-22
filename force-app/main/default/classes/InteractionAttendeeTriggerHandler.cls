/**
 * @description Handler class for the Interaction Attendee trigger
 * @author Rebecca Jan
 * @since 06/2022
 */

public with sharing class InteractionAttendeeTriggerHandler extends Lib_TriggerHandler {
  /**
   *  @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    InteractionAttendeeActions.validateAttendees(records, null);
  }
  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    InteractionAttendeeActions.updateAttendees(records, null);
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap that contains map of the old records
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    InteractionAttendeeActions.validateAttendees(records, null);
  }
  /**
   * @description onAfterUpdate to perform processing during the after update phase
   * @param oldMap that contains map of the old records
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    InteractionAttendeeActions.updateAttendees(
      records,
      (Map<Id, InteractionAttendee>) oldMap
    );
  }
  /**
   * @description onAfterDelete to perform processing during the after delete phase
   */
  public override void onAfterDelete() {
    InteractionAttendeeActions.updateAttendees(records, null);
  }
}
