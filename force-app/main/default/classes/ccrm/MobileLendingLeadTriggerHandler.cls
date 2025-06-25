/**
 * @author       : Prahlad Bhadani
 * @since        : March 2025
 * @description  : MobileLendingLeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used
 **/
public with sharing class MobileLendingLeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingLeadTriggerHandler
   */
  public MobileLendingLeadTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Mobile Lending Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Lead leadRecord = (Lead) record;
    return leadRecord.RecordTypeId == RTLead.mlcrmLead;
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   * @name onApplyDefaults
   */
  public override void onApplyDefaults() {
    MobileLendingLeadActions.setDefaultValue(records);
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    MobileLendingLeadActions.validateLeadCreation(records);
    CampaignActions.setDefaultCampaignOnMLLead(records);
    LeadActionsHelper.populateFieldsFromCampaign(records);
    LeadActionsHelper.populateRelatedAccount(records);
    LeadActionsHelper.populateLeadSourceForAdobeOrigin(records);
    LeadActionsHelper.populateLeadSourceForUnicaOrigin(records);
    MLCRMCommonUtils.referrerPrefill(records, null);
    LeadManagementActions.populateFromPreviousLead(records);
    LeadManagementActions.prefillManualLeadsFromAccountOnInsert(records);
    LeadManagementActions.prefillUnicaLeadsFromAccountOnInsert(records);
    LeadManagementActions.setDuplicateBlock(records, null);
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);
    MobileLendingLeadActions.populatePrimaryFranchise(records, null);
    TextUtils.maskSObjectDataANZExtended(records, 'Description'); //CC-4053 Redaction
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    MobileLendingLeadActions.setExpiryDate(records, ((Map<Id, Lead>) oldMap));
    MLCRMCommonUtils.referrerPrefill(records, oldMap);
    if (!LeadConversionController.leadConverionFlow) {
      LeadManagementActions.prefillManualLeadsFromAccountOnUpdate(
        records,
        ((Map<Id, Lead>) oldMap)
      );
    }
    LeadManagementActions.setDuplicateBlock(records, (Map<Id, Lead>) oldMap);
    LeadManagementActions.blankFollowUpDateOnLeadConvert(
      (Map<Id, Lead>) oldMap,
      records
    );
    LeadManagementActions.updateLeadStatus(records, (Map<Id, Lead>) oldMap);
    MobileLendingLeadActions.noLongerNewLeads((Map<Id, Lead>) oldMap, records);
    MLCRMCommonUtils.assignTerritoryForMLRecord(records);
    MLCRMCommonUtilsHelper.validateOwnerChange(oldMap, records);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);
    MobileLendingLeadActions.populatePrimaryFranchise(
      records,
      (Map<Id, Lead>) oldMap
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Description'); //CC-4053 Redaction
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    LeadManagementActions.createCampaignMember(records);
    LeadManagementActions.copyLeadId(records);
    MLCRMSharingUtil.shareRecordByTerritory(null, records, 'Lead');
    LeadManagementActions.notifyLeadOwners(null, records);
    //Keep these methods at end
    LeadManagementActions.sendManualLeadsToUnica(records, null);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    LeadManagementActions.publishLeadResponseUpdateToAdobeOrUnica(
      records,
      (Map<Id, Lead>) oldMap
    );
    LeadManagementActions.sendLeadUpdateToUnicaOrAdobe(
      records,
      (Map<Id, Lead>) oldMap
    );
    MLCRMSharingUtil.shareRecordByTerritory(oldMap, records, 'Lead');
    LeadManagementActions.notifyLeadOwners((Map<Id, Lead>) oldMap, records);
  }
}
