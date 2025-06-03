/**
 * @author Vishnu Kasu
 * @since  07/05/2025
 * @description Relationship Banking Manager for Interaction trigger handler
 */
public with sharing class RBMInteractionHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public RBMInteractionHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of RBM Broker Interaction records
   * @param record record to check if relevant to the execution context
   * @return Boolean returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Interaction) record).RecordTypeId ==
      RTInteraction.rbmBrokerInteraction;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onAfterInsert() {
    RBMInteractionActions.createInteractionNotes(records);
    RBMInteractionActions.createInteractionAttendee(records);
    RBMInteractionActions.createAssociatedLoanApplication(records);
    RBMInteractionActions.createInteractionEvents(records);
    RBMInteractionActions.createInteractionClosingNotes(records);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    RBMInteractionActions.updateInteractionName(
      new Map<Id, SObject>(),
      records
    );
    RBMInteractionActions.validAndSetStartTime(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old Interaction records map
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    RBMInteractionActions.updateInteractionName(oldMap, records);
    RBMInteractionActions.clearClosingNotes(records, oldMap);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old Interaction records map
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    RBMInteractionActions.updateAssociatedLoanApplication(records, oldMap);
    RBMInteractionActions.upsertInteractionEvents(records, oldMap);
    RBMInteractionActions.createInteractionClosingNotes(records, oldMap);
  }
}