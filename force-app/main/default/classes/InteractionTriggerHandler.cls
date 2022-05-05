/**
 * @description Trigger Handler for Interaction Object
 * @author Adam Phillip Smith
 * @since 20220329
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class InteractionTriggerHandler extends Lib_TriggerHandler {
  public static final String APPOINTMENTS_QUEUE = 'Appointments_Queue';
  public static final Id QUEUE_ID = CommonUtil.getGroupId(APPOINTMENTS_QUEUE);

  /**
   * @description override of the onAfterInsert to create Events & Interaction Summaries
   */
  public override void onAfterInsert() {
    ContactRequestActions cRActions = new ContactRequestActions();
    List<Interaction> interactions = cRActions.returnInteractionsWithAutomatedPurpose(
      records
    );

    cRActions.setInteractionIds(interactions);

    Map<Id, SObject> interactionMap = new Map<Id, SObject>(records);
    Set<Id> interactionIds = new Set<Id>(interactionMap.keyset());

    InteractionActions.setExternalIds(interactionIds);
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
        if (currentInteraction.OwnerId != QUEUE_ID) {
          userOwnedInteractions.add(currentInteraction);
        } else {
          assignedBacktoQueueInteractions.add(currentInteraction);
        }
      }
      if (!userOwnedInteractions.isEmpty()) {
        List<Event> events = actionsForContactRequests.createEventsFromInteractions(
          userOwnedInteractions
        );
        if (events.isEmpty() == false) {
          actionsForContactRequests.insertEvents(events);
        }
        createCoachingSummaryInteractions = actionsForInteractions.getInteractionswithoutCoachingSummary(
          userOwnedInteractions
        );
        assignCoachingSummaryOwnerInteractions = actionsForInteractions.getInteractionswithCoachingSummary(
          userOwnedInteractions
        );
      }
    }

    if (!createCoachingSummaryInteractions.isEmpty()) {
      List<Coaching_Summary__c> newCoachingSummary = actionsForInteractions.createCoachingSummaryfromInteraction(
        createCoachingSummaryInteractions
      );

      if (newCoachingSummary.isEmpty() == false) {
        actionsForInteractions.insertCoachingSummary(newCoachingSummary);
        actionsForInteractions.assignSummaryToInteraction(
          records,
          newCoachingSummary
        );
      }
    }

    if (!assignCoachingSummaryOwnerInteractions.isEmpty()) {
      List<Coaching_Summary__c> updateCoachingSummaryRecords = actionsForInteractions.assignCoachingSummaryOwner(
        assignCoachingSummaryOwnerInteractions
      );
      if (!updateCoachingSummaryRecords.isEmpty()) {
        actionsForInteractions.updateCoachingSummary(
          updateCoachingSummaryRecords
        );
      }
    }

    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    List<Interaction> interactionToDeleteEvents = assignedBacktoQueueInteractions.Clone();

    if (!assignedBacktoQueueInteractions.isEmpty()) {
      actionsForInteractions.deleteInteractionEvents(
        assignedBacktoQueueInteractions
      );
    }

    List<Interaction> cancelledInteractions = actionsForInteractions.findCancelledInteractions(
      oldMap,
      records
    );

    List<Interaction> noShowInteractions = actionsForInteractions.getNoShowInteractions(
      oldMap,
      records
    );

    interactionToDeleteEvents.addAll(cancelledInteractions);
    interactionToDeleteEvents.addAll(noShowInteractions);

    if (!interactionToDeleteEvents.isEmpty()) {
      actionsForInteractions.deleteInteractionEvents(interactionToDeleteEvents);
      contactRequestList = actionsForInteractions.getRelatedContactRequest(
        cancelledInteractions
      );
    }

    List<ContactRequest> requestsToRecalculate = contactRequestList.Clone();
    List<ContactRequest> rescheduledContactRequestList = new List<ContactRequest>();

    List<Interaction> rescheduledInteractions = actionsForInteractions.getRescheduledInteractions(
      oldMap,
      records
    );
    List<Event> relatedEvents = actionsForInteractions.getRelatedEvents(
      records
    );

    if (!rescheduledInteractions.isEmpty()) {
      rescheduledContactRequestList = actionsForInteractions.getRelatedContactRequest(
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
      actionsForInteractions.updateEventSchedule(relatedEvents, records);
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

    List<Interaction> assignedBacktoQueueInteractions = actions.getInteractionsAssignedBacktoQueue(
      oldMap,
      records
    );

    if (assignedBacktoQueueInteractions.size() > 0) {
      actions.updateOwnerNewInteractions(assignedBacktoQueueInteractions);
    }
  }
}
