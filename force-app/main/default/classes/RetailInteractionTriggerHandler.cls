/**
 * @author Karen Valeriano
 * @since January 2026
 * @description  Handler Class for Retail Interactions.
 */
public with sharing class RetailInteractionTriggerHandler extends Lib_TriggerHandler {
  private static final String ACTION_CODE_CREATE = 'create';

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public RetailInteractionTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler. Filters records to only Retail Interaction record type.
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Interaction interactionRecord = (Interaction) record;
    return interactionRecord.RecordTypeId == RTInteraction.retailInteraction;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  @TestVisible
  protected override void onBeforeInsert() {
    RetailInteractionActions.performRedaction(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   **/
  @TestVisible
  protected override void onAfterInsert() {
    RetailInteractionActions.publishCloudEvents(records, ACTION_CODE_CREATE);
  }
}
