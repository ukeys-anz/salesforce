/**
 * @author       : Ashish KUmar
 * @since        : May 2025
 * @description  : MobileLendingInteractionTriggerHandler is the handler class for Interaction Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class MobileLendingInteractionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingInteractionTriggerHandler
   */
  public MobileLendingInteractionTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of ML Interaction records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Interaction interactionRecord = (Interaction) record;
    return interactionRecord.RecordTypeId == RTInteraction.mlcrmInteraction;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    TextUtils.maskSObjectDataANZExtended(records, 'Name');
    TextUtils.maskSObjectDataANZExtended(records, 'Optional_Notes__c');
    InteractionEventHelper.assignDefaultTerritory(records);
    TerritoryCommonUtils.validateTerritoryAndOwnerChange(null, records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    TextUtils.maskSObjectDataANZExtended(records, 'Name');
    TextUtils.maskSObjectDataANZExtended(records, 'Optional_Notes__c');
    TerritoryCommonUtils.validateTerritoryAndOwnerChange(
      (Map<Id, Interaction>) oldMap,
      records
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    TerritorySharingUtil.shareRecordByTerritory(null, records, 'Interaction');
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    TerritorySharingUtil.shareRecordByTerritory(oldMap, records, 'Interaction');
  }
}
