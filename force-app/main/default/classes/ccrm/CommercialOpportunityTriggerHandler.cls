/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : CommercialOpportunityTriggerHandler is the handler class for Opportunity Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialOpportunityTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialOpportunityTriggerHandler
   */
  public CommercialOpportunityTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Opportunity records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Opportunity opportunityRecord = (Opportunity) record;
    return opportunityRecord.RecordTypeId ==
      RTOpportunity.commercialOpportunity;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialOpportunityActions.restrictImagesInRichTextFields(records, null);
    CommercialOpportunityActions.populateFields(records, null);

    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper = CommercialOpportunityActions.setOpportunityWrapper(
      records,
      null
    );

    //Check if Secondary customer needs contains customer needs
    CommercialOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      oppWrapper.filteredOpps,
      null
    );

    //checks for validations on opportunities
    CommercialOpportunityHelper.validateCCRMOpportunity(oppWrapper, true);
    //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Description');
    TextUtils.maskSObjectDataANZExtended(records, 'My_Notes__c');
    CommercialOpportunityActions.populateInfo(records, null);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    CommercialOpportunityActions.updateOpportunityNameOnInsert(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialOpportunityActions.restrictImagesInRichTextFields(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    OpportunityActions.transferOpportunityOwnership(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    CommercialOpportunityActions.populateFields(
      records,
      (Map<Id, Opportunity>) oldMap
    );
    if (!LeadConversionController.leadConverionFlow) {
      CommercialOpportunityActions.validateCloseDate(
        records,
        (Map<Id, Opportunity>) oldMap
      );
    }
    CommercialOpportunityActions.CCRMOpportunityWrapper oppWrapper = CommercialOpportunityActions.setOpportunityWrapper(
      records,
      (Map<Id, Opportunity>) oldMap
    );

    CommercialOpportunityActions.mandatoryFieldAndSkipStageCheck(
      oppWrapper,
      (Map<Id, Opportunity>) oldMap,
      false
    );
    //Check if Secondary customer needs contains customer needs
    CommercialOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      oppWrapper.filteredOpps,
      (Map<Id, Opportunity>) oldMap
    );

    //Check if AFP with closed won/lost stage related to opp has mandatory fields filled
    CommercialOpportunityActions.checkClosedStageFieldsOnAFPRelatedToOpp(
      oppWrapper.filteredOpps,
      (Map<Id, Opportunity>) oldMap
    );
    if (!CommercialOpportunityActions.insertOpportunityContext) {
      CommercialOpportunityActions.updateOpportunityNameOnUpdate(
        oppWrapper.filteredOpps,
        (Map<Id, Opportunity>) oldMap
      );
    }
    //CC-4053 Redaction
    TextUtils.maskSObjectDataANZExtended(records, 'Description');
    TextUtils.maskSObjectDataANZExtended(records, 'My_Notes__c');

    CommercialOpportunityActions.validateAndPopulateInfo(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    CommercialOpportunityActions.populateInfo(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    CommercialOpportunityActions.resetPreferredFranchiseForNonFranchiseSpecialisation(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    CommercialBrokerOpportunityActions.preventCustAndBrokerChange(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap Map of old records
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    CommercialOpportunityActions.updateAFShareRecordsOnOwnerChange(
      (List<Opportunity>) records,
      (Map<Id, Opportunity>) oldMap
    );
    CommercialOpportunityActions.publishReferralStatusUpdateEvents(
      records,
      (Map<Id, Opportunity>) oldMap
    );
  }
}
