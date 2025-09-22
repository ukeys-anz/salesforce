/**
 * @author Ayushi Gupta
 * @since  23/04/2024
 * @description Interaction trigger handler for CCRM
 */
public with sharing class CommercialInteractionTriggerHandler extends Lib_TriggerHandler {
  private static final String ACTION_CODE_CREATE = 'create';
  private static final String ACTION_CODE_UPDATE = 'update';
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CommercialInteractionTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Interaction records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Interaction interactionRecord = (Interaction) record;
    return interactionRecord.RecordTypeId ==
      RTInteraction.commercialInteraction;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  @TestVisible
  protected override void onBeforeInsert() {
    CommercialInteractionActions.setNameWithChannel(records);
    CommercialInteractionActions.setCustomerOnInteraction(records, null);
    CommercialInteractionActions.restrictImagesInRichTextFields(records, null);
    CommercialInteractionActions.performRedaction(records);
    CommercialInteractionActions.populateCLG(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  @TestVisible
  protected override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialInteractionActions.updateNameWithChannelChange(
      records,
      (Map<Id, Interaction>) oldMap
    );
    CommercialInteractionActions.setCustomerOnInteraction(
      records,
      (Map<Id, Interaction>) oldMap
    );
    CommercialInteractionActions.restrictImagesInRichTextFields(
      records,
      (Map<Id, Interaction>) oldMap
    );
    CommercialInteractionActions.performRedaction(records);
    CommercialInteractionActions.populateCLG(
      records,
      (Map<Id, Interaction>) oldMap
    );
    CommercialInteractionActions.validateAndPopulateCLG(
      records,
      (Map<Id, Interaction>) oldMap
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   **/
  @TestVisible
  protected override void onAfterInsert() {
    CommercialInteractionActions.publishCloudEvents(
      records,
      ACTION_CODE_CREATE
    );
    CommercialInteractionActions.createBrokerInteractionAttendee(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap Trigger's oldMap
   **/
  @TestVisible
  protected override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialInteractionActions.publishCloudEvents(
      records,
      ACTION_CODE_UPDATE
    );
  }
}
