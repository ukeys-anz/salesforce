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
    CommercialOpportunityActions.populateClgAccount(records, null);
  }
}
