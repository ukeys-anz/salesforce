/**
 * @description Actions for Interaction Summary
 * @author Adam Phillip Smith
 * @since 20220408
 */
public with sharing class InteractionSummaryActions {
  /**
   * @description Goes through Interaction Summaries and sets the
   * Linked Interaction's Interaction Summary field to match the Interaction Summary
   * @param records List<SObject> lis of Interaction Summaries to go through.
   */
  public void updateLinkedInteractions(List<SObject> records) {
    List<Interaction> interactions = new List<Interaction>();
    for (SObject record : records) {
      InteractionSummary summary = (InteractionSummary) record;
      if (summary == null) {
        //not an interaction summary, move along.
        continue;
      }
      Interaction currentInteraction = new Interaction(
        Id = summary.InteractionId,
        Interaction_Summary__c = summary.Id
      );
      interactions.add(currentInteraction);
    }
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      update interactions;
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionSummaryTriggerHandler',
        'onAfterInsert',
        'Not enough permissions to update Interactions.'
      );
    }
  }
}
