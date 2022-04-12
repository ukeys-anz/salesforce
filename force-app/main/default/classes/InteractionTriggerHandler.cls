/**
 * @description Trigger Handler for Interaction Object
 * @author Adam Phillip Smith
 * @since 20220329
 */
public with sharing class InteractionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description override of the onAfterInsert to create Events & Interaction Summaries
   */
  public override void onAfterInsert() {
    ContactRequestActions actions = new ContactRequestActions();
    List<Interaction> interactions = actions.returnInteractionsWithAutomatedPurpose(
      records
    );
    List<InteractionSummary> summaries = actions.createInteractionSummariesFromInteractions(
      interactions
    );
    actions.insertSummaries(summaries);

    List<Event> events = actions.createEventsFromInteractions(interactions);
    actions.insertEvents(events);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    InteractionActions actions = new InteractionActions();
    List<Interaction> cancelledInteractions = actions.findCancelledInteractions(
      oldMap,
      records
    );
    if (!cancelledInteractions.isEmpty()) {
      actions.deleteInteractionEvents(cancelledInteractions);
    }
  }
}
