/**
 * @description CommercialOppLineItemTriggerHandler is the handler class for Opportunity Product Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Naman Garg
 * @since Jun 2025
 */
public with sharing class CommercialOppLineItemTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialOppLineItemTriggerHandler
   */
  public CommercialOppLineItemTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeDelete to handle before delete trigger actions.
   * @name onBeforeDelete
   */
  public override void onBeforeDelete() {
    CommercialOppLineItemActions.preventOliDeletion(
      null,
      (Map<Id, OpportunityLineItem>) oldMap
    );
  }
}
