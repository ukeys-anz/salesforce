/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : CommercialLeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialLeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialLeadTriggerHandler
   */
  public CommercialLeadTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Lead leadRecord = (Lead) record;
    return leadRecord.RecordTypeId == RTLead.commercialLead;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    AbnAcnUtil.validateABN(records, null);
    AbnAcnUtil.validateACN(records, null);
    LeadActionsHelper.populateFieldsFromCampaign(records);
    CampaignActions.setDefaultCampaignOnCommercialLead(records);
    LeadActionsHelper.populateRelatedAccount(records);
    LeadActionsHelper.populateLeadSourceForUnicaOrigin(records);
    LeadActionsHelper.populateRegisteredCompany(records);
    LeadManagementActions.populateFromPreviousLead(records);
    LeadManagementActions.prefillManualLeadsFromAccountOnInsert(records);
    LeadManagementActions.prefillUnicaLeadsFromAccountOnInsert(records);
    AbnAcnServiceActions.setValidationStatus(records, null);
    LeadManagementActions.setDuplicateBlock(records, null);
    TextUtils.maskSObjectDataANZExtended(records, 'Description'); //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Note__c');
    CommercialLeadActions.checkForExistingCustomer(records, null);
    CommercialLeadActions.restrictImagesInRichTextFields(records, null);
    CommercialLeadActions.populateInfo(records, null);
    CommercialLeadActions.populatePrimaryContactMethod(records);
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
    CommercialLeadActions.setSkipValidationOnOwnerChange(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.updateExpirydate(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.setExpiryDate(records, ((Map<Id, Lead>) oldMap));
    if (!LeadConversionController.leadConverionFlow) {
      LeadManagementActions.prefillManualLeadsFromAccountOnUpdate(
        records,
        ((Map<Id, Lead>) oldMap)
      );
    }
    AbnAcnServiceActions.setValidationStatus(records, (Map<Id, Lead>) oldMap);
    AbnAcnServiceActions.removeValidationStatus(
      records,
      (Map<Id, Lead>) oldMap
    );
    LeadManagementActions.setDuplicateBlock(records, (Map<Id, Lead>) oldMap);
    LeadManagementActions.blankFollowUpDateOnLeadConvert(
      (Map<Id, Lead>) oldMap,
      records
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Description'); //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Note__c');
    CommercialLeadActions.checkForExistingCustomer(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.restrictImagesInRichTextFields(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.mapLeadStatusWithReferralStatus(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.populateRegisteredCompanyForIndividual(records);
    CommercialLeadActions.setCompanyToBlankForIndividual(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.validateAndPopulateInfo(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.populateInfo(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    LeadManagementActions.createCampaignMember(records);
    LeadManagementActions.copyLeadId(records);
    LeadManagementActions.notifyLeadOwnersForAdobeOrUnicaOrigin(null, records);
    AbnAcnServiceActions.validateAbnAcnForCallout((List<Lead>) records, null);
    //Keep these methods at end
    CommercialLeadActions.sendManualLeadsToUnica(records, null);
  }

  /**
   * @description onAfterUpdate: After Update Action of Lead.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Lead.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    AbnAcnServiceActions.validateAbnAcnForCallout(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
    //Keep this at end
    CommercialLeadActions.publishLeadResponseUpdateToAdobeOrUnica(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.sendLeadOwnerUpdateToUnica(
      records,
      (Map<Id, Lead>) oldMap
    );
    CommercialLeadActions.sendLeadUpdateToUnicaOrAdobe(
      records,
      (Map<Id, Lead>) oldMap
    );
    LeadManagementActions.notifyLeadOwnersForAdobeOrUnicaOrigin(
      (Map<Id, Lead>) oldMap,
      records
    );
    CommercialLeadActions.setCustomerOnA2ZReview(
      (Map<Id, Lead>) oldMap,
      records
    );
  }
}
