/**
 * @author Ayushi Gupta
 * @since  23/04/2024
 * @description Interaction trigger handler for CCRM
 */
public with sharing class CommercialInteractionTriggerHandler extends Lib_TriggerHandler {
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
    return record.get('RecordTypeId') == CCRMConstants.INTERACTION_CCRM_RT_ID;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  protected override void onBeforeInsert() {
    CommercialInteractionActions.setInteractionName(
      records,
      new Map<Id, Interaction>()
    );
    CommercialInteractionActions.setCustomerOnInteraction(records, null);
    CommercialInteractionActions.restrictImagesInRichTextFields(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  protected override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialInteractionActions.setInteractionName(
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
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   **/
  protected override void onAfterInsert() {
    CommercialInteractionActions.publishCloudEvents(
      records,
      CCRMConstants.ACTION_CODE_CREATE
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap Trigger's oldMap
   **/
  protected override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialInteractionActions.publishCloudEvents(
      records,
      CCRMConstants.ACTION_CODE_UPDATE
    );
  }
}
