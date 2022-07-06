/**
 * @description Trigger Handler for Interaction Object
 * @author Adam Phillip Smith
 * @since 20220329
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class InteractionTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description override of the onAfterInsert to create Events & Interaction Summaries
   */
  public override void onAfterInsert() {
    InteractionActions intActions = new InteractionActions();
    ContactRequestActions cRActions = new ContactRequestActions();
    List<Interaction> interactions = InteractionFilter.returnInteractionsWithAutomatedPurpose(
      records
    );

    InteractionSetters.setInteractionIds(interactions);

    Map<Id, SObject> interactionMap = new Map<Id, SObject>(records);
    Set<Id> interactionIds = new Set<Id>(interactionMap.keyset());

    InteractionSetters.setExternalIds(interactionIds);

    AppointmentNotificationHandler.sendNotifications(interactions);
  }

  /**
   * @description onAfterUpdate runs after an interaction has been updated.
   * @param oldMap Map<Id,SObject> the old versions of the interactions
   */
  @SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount'
  )
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    InteractionActions actionsForInteractions = new InteractionActions();
    ContactRequestActions actionsForContactRequests = new ContactRequestActions();

    List<Interaction> changedOwnerInteractions = actionsForInteractions.findInteractionsOwnershipChanged(
      oldMap,
      records
    );
    List<Interaction> userOwnedInteractions = new List<Interaction>();
    List<Interaction> assignedBacktoQueueInteractions = new List<Interaction>();
    List<Interaction> createCoachingSummaryInteractions = new List<Interaction>();
    List<Interaction> assignCoachingSummaryOwnerInteractions = new List<Interaction>();

    if (!changedOwnerInteractions.isEmpty()) {
      for (Interaction currentInteraction : changedOwnerInteractions) {
        if (
          currentInteraction.OwnerId !=
          InteractionConstants.APPOINTMENT_QUEUE_ID &&
          currentInteraction.RecordTypeId ==
          GetHelpConstants.INTERACTION_APPT_RT_ID
        ) {
          userOwnedInteractions.add(currentInteraction);
        } else {
          assignedBacktoQueueInteractions.add(currentInteraction);
        }
      }
      if (!userOwnedInteractions.isEmpty()) {
        List<Event> events = EventHelper.createEventsFromInteractions(
          userOwnedInteractions
        );
        if (events.isEmpty() == false) {
          EventHelper.insertEvents(events);
        }
        createCoachingSummaryInteractions = InteractionFilter.getInteractionswithoutCoachingSummary(
          userOwnedInteractions
        );
        assignCoachingSummaryOwnerInteractions = InteractionFilter.getInteractionswithCoachingSummary(
          userOwnedInteractions
        );
      }
    }

    if (!createCoachingSummaryInteractions.isEmpty()) {
      List<Coaching_Summary__c> newCoachingSummary = CoachingSummaryHelper.createCoachingSummaryfromInteraction(
        createCoachingSummaryInteractions
      );

      if (newCoachingSummary.isEmpty() == false) {
        CoachingSummaryHelper.insertCoachingSummary(newCoachingSummary);
        CoachingSummaryHelper.assignSummaryToInteraction(
          records,
          newCoachingSummary
        );
      }
    }

    if (!assignCoachingSummaryOwnerInteractions.isEmpty()) {
      List<Coaching_Summary__c> updateCoachingSummaryRecords = CoachingSummaryHelper.assignCoachingSummaryOwner(
        assignCoachingSummaryOwnerInteractions
      );
      if (!updateCoachingSummaryRecords.isEmpty()) {
        CoachingSummaryHelper.updateCoachingSummary(
          updateCoachingSummaryRecords
        );
      }
    }

    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    List<Interaction> interactionToDeleteEvents = assignedBacktoQueueInteractions.Clone();

    if (!assignedBacktoQueueInteractions.isEmpty()) {
      InteractionEventHelper.deleteInteractionEvents(
        assignedBacktoQueueInteractions
      );
    }

    List<Interaction> cancelledInteractions = actionsForInteractions.findCancelledInteractions(
      oldMap,
      records
    );

    AppointmentNotificationHandler.sendNotifications(cancelledInteractions);

    List<Interaction> noShowInteractions = InteractionComparisonHelper.getNoShowInteractions(
      oldMap,
      records
    );

    interactionToDeleteEvents.addAll(cancelledInteractions);
    interactionToDeleteEvents.addAll(noShowInteractions);

    if (!interactionToDeleteEvents.isEmpty()) {
      InteractionEventHelper.deleteInteractionEvents(interactionToDeleteEvents);
      contactRequestList = InteractionDMLHelper.getRelatedContactRequest(
        cancelledInteractions
      );
    }

    List<ContactRequest> requestsToRecalculate = contactRequestList.Clone();
    List<ContactRequest> rescheduledContactRequestList = new List<ContactRequest>();

    List<Interaction> rescheduledInteractions = InteractionComparisonHelper.getRescheduledInteractions(
      oldMap,
      records
    );
    List<Event> relatedEvents = InteractionEventHelper.getRelatedEvents(
      records
    );

    if (!rescheduledInteractions.isEmpty()) {
      rescheduledContactRequestList = InteractionDMLHelper.getRelatedContactRequest(
        rescheduledInteractions
      );
    }

    requestsToRecalculate.addAll(rescheduledContactRequestList);

    if (!requestsToRecalculate.isEmpty()) {
      ContactRequestTriggerActions.updateConfirmedCount(
        requestsToRecalculate,
        false
      );
    }

    if (!relatedEvents.isEmpty()) {
      InteractionEventHelper.updateEventSchedule(relatedEvents, records);
    }
  }

  /**
   *  @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    InteractionActions actions = new InteractionActions();
    ContactRequestActions cRActions = new ContactRequestActions();
    List<Interaction> interactions = InteractionFilter.returnInteractionsWithAutomatedPurpose(
      records
    );

    InteractionSetters.setOwnerNewInteractions(interactions);

    InteractionSetters.setNameOfInteractions(interactions);

    List<Interaction> newInteractions = InteractionFilter.getInteractionsWithoutEnddate(
      interactions
    );

    if (!newInteractions.isEmpty()) {
      actions.updateEndTime(newInteractions);
    }

    InteractionValidations.validateInteractions(interactions);
  }

  /** @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    InteractionActions actions = new InteractionActions();

    List<Interaction> acceptedInteractions = InteractionComparisonHelper.getAcceptedInteractions(
      oldMap,
      records
    );
    if (acceptedInteractions.size() > 0) {
      InteractionSetters.setStatustoScheduled(acceptedInteractions);
      InteractionValidations.validateCoachAssignment(acceptedInteractions);
    }

    List<Interaction> assignedBacktoQueueInteractions = InteractionComparisonHelper.getInteractionsAssignedBacktoQueue(
      oldMap,
      records
    );

    if (assignedBacktoQueueInteractions.size() > 0) {
      InteractionSetters.setOwnerNewInteractions(
        assignedBacktoQueueInteractions
      );
    }

    List<Interaction> reasonOrStartTimeUpdatedInteractions = actions.getInteractionsRequiringEndTimeUpdate(
      oldMap,
      records
    );

    if (!reasonOrStartTimeUpdatedInteractions.isEmpty()) {
      actions.updateEndTime(reasonOrStartTimeUpdatedInteractions);
    }
    actions.unassignInteractions(oldMap, records);
  }
}
