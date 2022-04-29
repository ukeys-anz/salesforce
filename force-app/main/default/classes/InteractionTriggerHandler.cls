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
    InteractionActions actions = new InteractionActions();
    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    List<Interaction> cancelledInteractions = actions.findCancelledInteractions(
      oldMap,
      records
    );
    if (!cancelledInteractions.isEmpty()) {
      actions.deleteInteractionEvents(cancelledInteractions);
      contactRequestList = actions.getRelatedContactRequest(
        cancelledInteractions
      );
    }

    if (contactRequestList.size() > 0) {
      ContactRequestTriggerActions.updateConfirmedCount(
        contactRequestList,
        false
      );
    }

    List<ContactRequest> rescheduledContactRequestList = new List<ContactRequest>();
    List<Interaction> rescheduledInteractions = actions.getRescheduledInteractions(
      oldMap,
      records
    );
    List<Event> relatedEvents = actions.getRelatedEvents(records);

    if (rescheduledInteractions.size() > 0) {
      rescheduledContactRequestList = actions.getRelatedContactRequest(
        rescheduledInteractions
      );
    }

    if (rescheduledContactRequestList.size() > 0) {
      ContactRequestTriggerActions.updateConfirmedCount(
        rescheduledContactRequestList,
        false
      );
    }

    if (relatedEvents.size() > 0) {
      actions.updateEventSchedule(relatedEvents, records);
    }
  }

  /**
   *  @description onBeforeInsert to handle before insert trigger actions.
   */

  public override void onBeforeInsert() {
    InteractionActions actions = new InteractionActions();
    actions.updateOwnerNewInteractions(records);
  }

  /** @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    InteractionActions actions = new InteractionActions();
    List<Interaction> acceptedInteractions = actions.getAcceptedInteractions(
      oldMap,
      records
    );
    if (acceptedInteractions.size() > 0) {
      actions.updateStatustoScheduled(records);
    }
  }
}
