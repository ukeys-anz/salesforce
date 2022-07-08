/**
 * @description Trigger Handler for Interaction Summart Object
 * @author Adam Phillip Smith
 * @since 20220406
 */
public with sharing class InteractionSummaryTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description override of the onAfterInsert to update Interaction with the Summary Id
   */
  public override void onAfterInsert() {
    InteractionSummaryActions actions = new InteractionSummaryActions();
    actions.updateLinkedInteractions(records);
  }
}
