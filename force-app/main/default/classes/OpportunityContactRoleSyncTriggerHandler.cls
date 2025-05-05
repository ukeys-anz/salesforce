/**
 * @description OpportunityContactRoleSyncTriggerHandler is the handler class for OpportunityContactRoleSyncTrigger.
 * @author Ashwin Mohan
 * @since 04/2025
 */
public with sharing class OpportunityContactRoleSyncTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name OpportunityContactRoleSyncTriggerHandler
   */
  public OpportunityContactRoleSyncTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    OpportunityContactRoleSyncActions.insertOCRRecords(records);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    OpportunityContactRoleSyncActions.updateOCRRecords(
      records,
      (Map<Id, Opportunity_Contact_Role_Sync__c>) oldMap
    );
  }

  /**
   * @description onAfterDelete to handle after delete trigger actions.
   * @name onAfterDelete
   */
  public override void onAfterDelete() {
    OpportunityContactRoleSyncActions.deleteOCRRecords(records);
  }
}
