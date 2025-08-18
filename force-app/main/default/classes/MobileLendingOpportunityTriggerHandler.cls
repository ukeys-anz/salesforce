/**
 * @author       : Hitesh
 * @since        : Feb 2025
 * @description  : MobileLendingOpportunityTriggerHandler is the handler class for Opportunity Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class MobileLendingOpportunityTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingOpportunityTriggerHandler
   */
  public MobileLendingOpportunityTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of ML Opportunity records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Opportunity opportunityRecord = (Opportunity) record;
    return opportunityRecord.RecordTypeId == RTOpportunity.mlOpportunity;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    //CC-12479 prevent duplicate Loanapp_Reference_Number__c records on Opportunity
    OpportunityActions.preventDuplicateLoanappReferenceNumber(records, null);

    //CC-4528 validate Opportunity for MLCRM
    OpportunityActions.validateClosedOpportunity(records, null);

    OpportunityActions.populateName(records);

    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058 This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);

    //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Description');

    MLCRMCommonUtils.referrerPrefill(records, null);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    //CC-1252-Make Opportunities visible to Owners & users above them in the ML hierarchy
    MLCRMSharingUtil.shareRecordByTerritory(null, records, 'Opportunity');
    OpportunityActions.createOpportunityContactRole(records);
  }

  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    if (!LeadConversionController.leadConverionFlow) {
      OpportunityActions.setHasCloseDateChanged(
        records,
        (Map<Id, Opportunity>) oldMap
      );
    }

    OpportunityActions.transferOpportunityOwnership(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );

    //CC-12479 prevent duplicate Loanapp_Reference_Number__c records on Opportunity
    OpportunityActions.preventDuplicateLoanappReferenceNumber(
      records,
      (Map<Id, Opportunity>) oldMap
    ); // check with Prahlad if need to add for CCRM as well

    //CC-4528 validate Opportunity for MLCRM
    OpportunityActions.validateClosedOpportunity(
      records,
      (Map<Id, Opportunity>) oldMap
    );

    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-7788 and CC-8135 This method is used to validate that loan writer and franchise admin cannot change the owner of the record not owner by themself
    MLCRMCommonUtilsHelper.validateOwnerChange(oldMap, records);
    //CC-1058-This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);
    OpportunityActions.updatePrimaryApplicantOnUpdate(
      records,
      (Map<Id, Opportunity>) oldMap
    );

    //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Description');
    MLCRMCommonUtils.referrerPrefill(records, oldMap);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Opportunity.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    //CC-1252-Make Opportunities visible to Owners & users above them in the ML hierarchy
    MLCRMSharingUtil.shareRecordByTerritory(oldMap, records, 'Opportunity');
    OpportunityActions.updateOCRSyncRecordsOnLARChange(
      records,
      (Map<Id, Opportunity>) oldMap
    );
  }
}
