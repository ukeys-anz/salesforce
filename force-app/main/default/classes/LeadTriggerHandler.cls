/**
 * @author Olivier Saier
 * @since 08/2021
 * @description LeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class LeadTriggerHandler extends Lib_TriggerHandler {
  @testVisible
  private static final String DELETE_ERROR = 'You cannot delete leads';

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadTriggerHandler
   */
  public LeadTriggerHandler() {
    super();
  }

  /**
   * @description Mask Lead Description where applicable.
   * @name onApplyDefaults
   */
  public override void onApplyDefaults() {
    // CC-1057 to set the default value of expiry date for Manually created ML Lead
    MLCRMLeadActions.setDefaultValue(records);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    AbnAcnUtil.validateABN(records, null);
    AbnAcnUtil.validateACN(records, null);
    CCRMLeadActions.populateFields(records);
    MLCRMCommonUtils.referrerPrefill(records, null);
    CCRMLeadActions.populateFromPreviousLead(records);
    CCRMControllingPostActions.retrieveControllingPost(records, null);
    CCRMLeadActions.prefillManualLeadsFromAccountOnInsert(records);
    CCRMLeadActions.prefillUnicaLeadsFromAccountOnInsert(records);
    CCRMCampaignActions.setDefaultCampaign(records);
    CCRMLeadActions.setValidationStatus(records, null);
    CCRMLeadActions.validateIngestedLeads(records);
    //CC-1054 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058-This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        MLCRMConstants.MLCRM_LEAD_RT_ID,
        CCRMConstants.CCRM_LEAD_RT_ID
      }
    );
    TextUtils.maskSObjectData(wrapperData.recordList, 'Description');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
    // Method will check if lead is BOH Lead
    BOHLeadActions.getInstance().setBOHLeadFlag(records);
    BOHLeadActions.populateExistingCustomer(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMLeadActionsHelper.transferLeadOwnership(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    //Check ABN and ACN
    AbnAcnUtil.validateABN(records, (Map<Id, Lead>) oldMap);
    AbnAcnUtil.validateACN(records, (Map<Id, Lead>) oldMap);
    CCRMLeadActions.setExpiryDate(
      ((List<Lead>) records),
      ((Map<Id, Lead>) oldMap)
    );
    MLCRMCommonUtils.referrerPrefill(records, oldMap);

    if (!CCRMLeadConversionActions.leadConverionFlow) {
      CCRMLeadActions.prefillManualLeadsFromAccountOnUpdate(
        ((List<Lead>) records),
        ((Map<Id, Lead>) oldMap)
      );
    }
    CCRMLeadActions.setValidationStatus(records, (Map<Id, Lead>) oldMap);

    CCRMLeadActions.leadCompletedActionBeforeUpdate(
      (Map<Id, Lead>) oldMap,
      records
    );
    CCRMControllingPostActions.retrieveControllingPost(records, oldMap);
    //CC-1609 Auto Update Lead status to In Progrees for MLCRM Manual lead update
    CCRMLeadActions.updateLeadStatus(records, (Map<Id, Lead>) oldMap);
    //CC-1609 This method is used to update new flag checkbox to false during implicit update while lead creation
    MLCRMLeadActions.noLongerNewLeads((Map<Id, Lead>) oldMap, records);
    //CC-1054 to set the territory for ML Records based on matching user territory default record.
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    //CC-1058-This method to validate territory and owner change on Sobject to make sure it happen within user's territory.
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);
    MLCRMLeadActions.populatePrimaryFranchise(records, (Map<Id, Lead>) oldMap);
    //Added for CC-4053 Redaction
    TextUtils.RecordListWrapper wrapperData = TextUtils.checkRecordTypeRedactionMethod(
      records,
      new List<Id>{
        MLCRMConstants.MLCRM_LEAD_RT_ID,
        CCRMConstants.CCRM_LEAD_RT_ID
      }
    );

    TextUtils.maskSObjectData(wrapperData.recordList, 'Description');
    TextUtils.maskSObjectDataANZExtended(
      wrapperData.dcrmRecordList,
      'Description'
    );
  }

  /**
   * @description onBeforeDelete: Enforce deletion prevention
   * @name onBeforeDelete
   */
  public override void onBeforeDelete() {
    for (Lead record : (List<Lead>) records) {
      if (CCRMLeadUtil.isCCRMLeadType(record)) {
        record.addError(DELETE_ERROR);
      }
    }
  }

  /**
   * @description onAfterInsert: After Insert actions on Lead.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    CCRMLeadActions.createCampaignMember(records);
    CCRMLeadActions.validateAbnAcnForCallout(records, null);
    //Keep these methods at end
    CCRMLeadActions.sendManualLeadsToUnica(records, null);
    CCRMLeadActions.copyLeadId(records);
    CCRMRegionSharingUtil.shareLeadsToOwnerRegion(records);
    MLCRMSharingUtil.shareRecordByTerritory(null, records, 'Lead');
    CCRMLeadActions.notifyLeadOwners(null, records);
  }

  /**
   * @description onAfterUpdate: After Update Action of Lead.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Lead.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (!checkRecursive.firstCall) {
      CheckRecursive.run();
      CCRMLeadActions.validateAbnAcnForCallout(records, (Map<Id, Lead>) oldMap);
      CCRMRegionSharingUtil.shareLeadsToUpdatedOwnerRegion(
        records,
        (Map<Id, Lead>) oldMap
      );
      //Keep this at end
      if (!System.isFuture()) {
        CCRMLeadActions.publishLeadResponseUpdateToAdobeOrUnica(
          records,
          (Map<Id, Lead>) oldMap
        );
        CCRMLeadActions.sendLeadUpdateToUnicaOrAdobe(
          records,
          (Map<Id, Lead>) oldMap
        );
      }
    }
    LeadChatterMigrationHelper.migrateChatterPostsOnConversion(records, oldMap);
    MLCRMSharingUtil.shareRecordByTerritory(oldMap, records, 'Lead');
    CCRMLeadActions.notifyLeadOwners((Map<Id, Lead>) oldMap, records);
  }
}
