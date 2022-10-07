/**
 * @description OpportunityLineItemTriggerHandler is the handler class for Opportunity Product Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Mairaj Haider
 * @since 06/2022
 */
public with sharing class OpportunityLineItemTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name OpportunityLineItemTriggerHandler
   */
  public OpportunityLineItemTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMOpportunityLineItemActions.validateLegalEntityExist(records, null);
  }
}
