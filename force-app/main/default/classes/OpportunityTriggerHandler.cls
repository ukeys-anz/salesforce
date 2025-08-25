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
    if (!LeadConversionController.leadConverionFlow) {
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

    //Check if AFP with closed won/lost stage related to opp has mandatory fields filled
    CCRMOpportunityActions.checkClosedStageFieldsOnAFPRelatedToOpp(
      oppWrapper.filteredOpps,
      (Map<Id, Opportunity>) oldMap
    );

    if (!CCRMOpportunityActions.insertOpportunityContext) {
      CCRMOpportunityActions.updateOpportunityNameOnUpdate(
        oppWrapper.filteredOpps,
        (Map<Id, Opportunity>) oldMap
      );
    }
  }
}
