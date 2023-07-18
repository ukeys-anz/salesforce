/**
 * @description OpportunityTriggerHandler is the handler class for Opportunity Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Emmanuel
 * @since 06/2022
 */
public with sharing class OpportunityTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name OpportunityTriggerHandler
   */
  public OpportunityTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMOpportunityActions.populateFields(records, null);
    CCRMOpportunityActions.populateClgAccount(records, null);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    CCRMOpportunityActions.populateFieldsAfterInsert(records);
    CCRMRegionSharingUtil.shareOpportunitiesToOwnerRegion(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMOpportunityActions.populateFields(
      records,
      (Map<Id, Opportunity>) oldMap
    );
    CCRMOpportunityActions.validateCloseDate(
      records,
      (Map<Id, Opportunity>) oldMap
    );
  }
}
