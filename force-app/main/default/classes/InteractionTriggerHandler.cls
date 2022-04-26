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
    ContactRequestActions cRActions = new ContactRequestActions();
    List<Interaction> interactions = cRActions.returnInteractionsWithAutomatedPurpose(
      records
    );

    List<InteractionSummary> summaries = cRActions.createInteractionSummariesFromInteractions(
      interactions
    );

    cRActions.insertSummaries(summaries);

    List<Event> events = cRActions.createEventsFromInteractions(interactions);
    cRActions.insertEvents(events);

    cRActions.setInteractionIds(interactions);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    InteractionActions interActions = new InteractionActions();
    List<Interaction> cancelledInteractions = interActions.findCancelledInteractions(
      oldMap,
      records
    );
    if (!cancelledInteractions.isEmpty()) {
      interActions.deleteInteractionEvents(cancelledInteractions);
    }
  }
}
