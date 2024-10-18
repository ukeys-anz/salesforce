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

    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper = CCRMOpportunityActions.setOpportunityWrapper(
      records,
      null,
      false
    );

    //Check if Secondary customer needs contains customer needs
    CCRMOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      oppWrapper.filteredOpps,
      null,
      true
    );

    //checks for validations on opportunities
    CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, true);
    //CC-4528 validate Opportunity for MLCRM
    MLCRMOpportunityActions.validateMLCRMOpportunity(records, null);
    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058 This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);
    //CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID,
        CCRMConstants.CCRM_OPP_RT_ID
      }
    );

    TextUtils.maskSObjectData(wrapperData.recordList, 'Description');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    TextUtils.RecordListWrapper wrapperDataCCRM = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{ CCRMConstants.CCRM_OPP_RT_ID }
    );
    TextUtils.maskSObjectDataANZExtended(
      wrapperDataCCRM.dcrmRecordList,
      'My_Notes__c'
    );
    MLCRMCommonUtils.referrerPrefill(records, null);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    CCRMOpportunityActions.populateFieldsAfterInsert(records);
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper = CCRMOpportunityActions.setOpportunityWrapper(
      records,
      null,
      false
    );
    CCRMOpportunityActions.updateOpportunityNameOnInsert(
      oppWrapper.filteredOpps
    );
    //CC-1252-Make Opportunities visible to Owners & users above them in the ML hierarchy
    MLCRMSharingUtil.shareRecordByTerritory(null, records, 'Opportunity');
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

    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper = CCRMOpportunityActions.setOpportunityWrapper(
      records,
      (Map<Id, Opportunity>) oldMap,
      true
    );

    CCRMOpportunityActions.mandatoryFieldAndSkipStageCheck(
      oppWrapper,
      (Map<Id, Opportunity>) oldMap,
      false
    );

    //Check if Secondary customer needs contains customer needs
    CCRMOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      oppWrapper.filteredOpps,
      (Map<Id, Opportunity>) oldMap,
      false
    );

    //CC-4528 validate Opportunity for MLCRM
    MLCRMOpportunityActions.validateMLCRMOpportunity(
      records,
      (Map<Id, Opportunity>) oldMap
    );
    //CC-1159 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-7788 and CC-8135 This method is used to validate that loan writer and franchise admin cannot change the owner of the record not owner by themself
    MLCRMCommonUtilsHelper.validateOwnerChange(oldMap, records);
    //CC-1058-This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);

    if (!CCRMOpportunityActions.insertOpportunityContext) {
      CCRMOpportunityActions.updateOpportunityNameOnUpdate(
        oppWrapper.filteredOpps,
        (Map<Id, Opportunity>) oldMap
      );
    }

    //CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        MLCRMConstants.MLCRM_OPPORTUNITY_RT_ID,
        CCRMConstants.CCRM_OPP_RT_ID
      }
    );

    TextUtils.maskSObjectData(wrapperData.recordList, 'Description');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    TextUtils.RecordListWrapper wrapperDataCCRM = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{ CCRMConstants.CCRM_OPP_RT_ID }
    );
    TextUtils.maskSObjectDataANZExtended(
      wrapperDataCCRM.dcrmRecordList,
      'My_Notes__c'
    );
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
  }
}
