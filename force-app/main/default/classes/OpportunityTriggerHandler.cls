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
    CCRMOpportunityActions.mandatoryFieldAndSkipStageCheck(
      records,
      null,
      true,
      false
    );
    //CC-4528 validate Opportunity for MLCRM
    MLCRMOpportunityActions.validateMLCRMOpportunity(records, null);
    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058 This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    CCRMOpportunityActions.populateFieldsAfterInsert(records);
    CCRMRegionSharingUtil.shareOpportunitiesToOwnerRegion(records);
    CCRMOpportunityActions.populateOppName(records, null, true, false);
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
    if (!CCRMLeadConversionActions.leadConverionFlow) {
      CCRMOpportunityActions.validateCloseDate(
        records,
        (Map<Id, Opportunity>) oldMap
      );
    }
    CCRMOpportunityActions.mandatoryFieldAndSkipStageCheck(
      records,
      (Map<Id, Opportunity>) oldMap,
      false,
      true
    );
    //CC-4528 validate Opportunity for MLCRM
    MLCRMOpportunityActions.validateMLCRMOpportunity(
      records,
      (Map<Id, Opportunity>) oldMap
    );
    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058-This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);

    CCRMOpportunityActions.populateOppName(
      records,
      (Map<Id, Opportunity>) oldMap,
      false,
      true
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Opportunity.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CCRMRegionSharingUtil.shareOpportunityToUpdatedOwnerRegion(
      records,
      (Map<Id, Opportunity>) oldMap
    );
    CCRMOpportunityActions.insertActionPlans(
      records,
      (Map<Id, Opportunity>) oldMap
    );
  }
}
