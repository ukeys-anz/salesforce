/**
 * @author Ashish Kumar
 * @since 08/2023
 * @description CustomerRelationNotesTriggerHandler is the handler class for customer relationship Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public class CustomerRelationNotesTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name customerRelationNotesTriggerHandler
   */
  public CustomerRelationNotesTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    CustomerRelationNotesTriggerActions.validatePrimaryRelationshipNotes(
      null,
      records
    );
    MLCRMSharingUtil.shareRecordByTerritory(
      null,
      records,
      'Customer_Relationship__c'
    );
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);
    CustomerRelationNotesTriggerActions.validatePrimaryRelationshipNotes(
      (Map<Id, Customer_Relationship__c>) oldMap,
      records
    );
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CustomerRelationNotesTriggerActions.validatePrimaryRelationshipNotes(
      (Map<Id, Customer_Relationship__c>) oldMap,
      records
    );
    MLCRMSharingUtil.shareRecordByTerritory(
      oldMap,
      records,
      'Customer_Relationship__c'
    );
  }
}
