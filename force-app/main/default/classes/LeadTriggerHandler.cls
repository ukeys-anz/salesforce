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
    TextUtils.maskSObjectData(records, 'Description');
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    AbnAcnUtil.validateABN(records, null);
    AbnAcnUtil.validateACN(records, null);
    CCRMLeadActions.populateFields(records);
    CCRMLeadActions.populateFromPreviousLead(records);
    CCRMControllingPostActions.retrieveControllingPost(records, null);
    CCRMLeadActions.prefillManualLeadsFromAccountOnInsert(records);
    CCRMLeadActions.prefillUnicaLeadsFromAccountOnInsert(records);
    CCRMCampaignActions.setDefaultCampaign(records);
    CCRMLeadActions.setValidationStatus(records, null);
    CCRMLeadActions.validateIngestedLeads(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    //Check ABN and ACN
    AbnAcnUtil.validateABN(records, (Map<Id, Lead>) oldMap);
    AbnAcnUtil.validateACN(records, (Map<Id, Lead>) oldMap);
    CCRMLeadActions.setExpiryDate(
      ((List<Lead>) records),
      ((Map<Id, Lead>) oldMap)
    );
    CCRMLeadActions.prefillManualLeadsFromAccountOnUpdate(
      ((List<Lead>) records),
      ((Map<Id, Lead>) oldMap)
    );
    CCRMLeadActions.setValidationStatus(records, (Map<Id, Lead>) oldMap);
    //Mask Lead Description where applicable
    TextUtils.maskSObjectData(records, 'Description');
    CCRMLeadActions.leadCompletedActionBeforeUpdate(
      (Map<Id, Lead>) oldMap,
      records
    );
    CCRMControllingPostActions.retrieveControllingPost(records, oldMap);
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
    CCRMLeadActions.notifyLeadOwners(null, records);
    CCRMLeadActions.createCampaignMember(records);
    CCRMLeadActions.validateAbnAcnForCallout(records, null);
    //Keep these methods at end
    CCRMLeadActions.sendManualLeadsToUnica(records, null);
    CCRMLeadActions.copyLeadId(records);
    CCRMRegionSharingUtil.shareLeadsToOwnerRegion(records);
  }

  /**
   * @description onAfterUpdate: After Update Action of Lead.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Lead.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    if (!checkRecursive.firstCall) {
      CheckRecursive.run();
      CCRMLeadActions.notifyLeadOwners((Map<Id, Lead>) oldMap, records);
      CCRMLeadActions.validateAbnAcnForCallout(records, (Map<Id, Lead>) oldMap);
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
  }
}
