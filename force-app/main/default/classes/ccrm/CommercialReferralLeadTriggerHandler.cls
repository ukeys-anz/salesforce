/**
 * @author       : Naman Garg
 * @since        : Jan 2025
 * @description  : CommercialReferralLeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialReferralLeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialLeadTriggerHandler
   */
  public CommercialReferralLeadTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Commercial Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Lead leadRecord = (Lead) record;
    return leadRecord.RecordTypeId == RTLead.referralLead;
  }

  /**
   * @description onAfterInsert: After Insert actions on Lead.
   * @name onAfterInsert
   */
  public override void onBeforeInsert() {
    CommercialReferralLeadActions.updateContactInfo(records);
    CampaignActions.setDefaultCampaignOnReferralLead(records);
    CommercialReferralLeadActions.mapReferralCustomerNeed(records);
    CommercialReferralLeadActions.setDefaultInternalReferrer(records);
    CommercialReferralLeadActions.populateNewToBank(records, null);
    CommercialLeadActions.populateInfo(records, null);
    CommercialReferralLeadActions.updateIknowReferralStatus(records);
    CommercialLeadActions.prefillContactInfoForIndLead(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialReferralLeadActions.updateReferralStatus(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.mapLeadStatusWithReferralStatus(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialReferralLeadActions.populateNewToBank(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.populateInfo(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.prefillContactInfoForIndLead(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
  }

  /**
   * @description onAfterInsert: After Insert actions on Lead.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    LeadManagementActions.copyLeadId(records);
    LeadManagementActions.createCampaignMember(records);
    CommercialReferralLeadActions.updateParentLead(records);
    CommercialReferralLeadActions.sendBellNotificationIknowReferral(records);
  }

  /**
   * @description onAfterUpdate: After Update Action of Lead.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Lead.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialReferralLeadActions.shareReferralRecord(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialReferralLeadActions.sendBellNotification(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialReferralLeadActions.publishCloudEvents(
      records,
      (Map<Id, Lead>) oldMap
    );
  }
}
