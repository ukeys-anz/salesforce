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
    List<Interaction> interactions = InteractionFilter.returnInteractionsWithAutomatedPurpose(
      records
    );

    //Creating a map of all interactions by record type, to be used later. This reduces number of loops.
    Map<String, List<Interaction>> mapOfInteractionsByRecordType = InteractionFilter.getInteractionsByRecordType(
      records
    );

    List<Interaction> apptInteractions = mapOfInteractionsByRecordType.containsKey(
        GetHelpConstants.INTERACTION_APPT_RT_ID
      )
      ? mapOfInteractionsByRecordType.get(
          GetHelpConstants.INTERACTION_APPT_RT_ID
        )
      : new List<Interaction>();

    List<Interaction> storeInteractions = mapOfInteractionsByRecordType.containsKey(
        GetHelpConstants.INTERACTION_STORE_RT_ID
      )
      ? mapOfInteractionsByRecordType.get(
          GetHelpConstants.INTERACTION_STORE_RT_ID
        )
      : new List<Interaction>();

    List<Interaction> chatInteractions = mapOfInteractionsByRecordType.containsKey(
        GetHelpConstants.INTERACTION_MESSAGE_RT_ID
      )
      ? mapOfInteractionsByRecordType.get(
          GetHelpConstants.INTERACTION_MESSAGE_RT_ID
        )
      : new List<Interaction>();

    List<Interaction> generalInteractions = mapOfInteractionsByRecordType.containsKey(
        GetHelpConstants.INTERACTION_GENERAL_RT_ID
      )
      ? mapOfInteractionsByRecordType.get(
          GetHelpConstants.INTERACTION_GENERAL_RT_ID
        )
      : new List<Interaction>();

    Map<Id, SObject> apptMap = new Map<Id, SObject>(apptInteractions);
    Set<Id> apptIds = new Set<Id>(apptMap.keyset());
    InteractionSetters.setInteractionIds(apptInteractions);
    InteractionSetters.setExternalIds(apptIds);
    InteractionAttendeeActions.insertDefaultAttendee(records);

    //Add Interaction Number for Store too.

    generalInteractions.addAll(storeInteractions);

    System.debug('generalInteractions ' + generalInteractions);
    System.debug('storeInteractions ' + storeInteractions);
    //Add Interaction Number for Chat too
    generalInteractions.addAll(chatInteractions);

    Map<Id, SObject> generalMap = new Map<Id, SObject>(generalInteractions);
    InteractionSetters.setGeneralExternalIds(generalMap.keyset());

    AppointmentNotificationEventCreator.getInstance()
      .addInteractions(interactions);
    AppointmentNotificationEventCreator.getInstance().publishEvents();
    MLCRMSharingUtil.shareRecordByTerritory(null, records, 'Interaction');
  }

  /**
   * @description onAfterUpdate runs after an interaction has been updated.
   * @param oldMap Map<Id,SObject> the old versions of the interactions
   */
  @SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount'
  )
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Interaction> interactiontoDeleteEvents = new List<Interaction>();

    List<Interaction> changedOwnerInteractions = InteractionActions.findInteractionsOwnershipChanged(
      oldMap,
      records
    );
    List<Interaction> userOwnedInteractions = new List<Interaction>();
    List<Interaction> createCoachingSummaryInteractions = new List<Interaction>();
    List<Interaction> assignCoachingSummaryOwnerInteractions = new List<Interaction>();

    for (Interaction currentInteraction : changedOwnerInteractions) {
      if (
        currentInteraction.OwnerId !=
        InteractionConstants.APPOINTMENT_QUEUE_ID &&
        currentInteraction.RecordTypeId ==
        GetHelpConstants.INTERACTION_APPT_RT_ID
      ) {
        userOwnedInteractions.add(currentInteraction);
      }
    }
    interactiontoDeleteEvents.addAll(changedOwnerInteractions);
    InteractionAttendeeActions.insertOwnerChangeAttendee(
      changedOwnerInteractions
    );

    createCoachingSummaryInteractions = InteractionFilter.getInteractionswithoutCoachingSummary(
      userOwnedInteractions
    );
    assignCoachingSummaryOwnerInteractions = InteractionFilter.getInteractionswithCoachingSummary(
      userOwnedInteractions
    );

    if (createCoachingSummaryInteractions.isEmpty() == false) {
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

    if (assignCoachingSummaryOwnerInteractions.isEmpty() == false) {
      List<Coaching_Summary__c> updateCoachingSummaryRecords = CoachingSummaryHelper.assignCoachingSummaryOwner(
        assignCoachingSummaryOwnerInteractions
      );
      if (updateCoachingSummaryRecords.isEmpty() == false) {
        CoachingSummaryHelper.updateCoachingSummary(
          updateCoachingSummaryRecords
        );
      }
    }

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    List<Interaction> cancelledInteractions = InteractionActions.findCancelledInteractions(
      oldMap,
      records
    );

    AppointmentNotificationEventCreator.getInstance()
      .addInteractions(cancelledInteractions);
    AppointmentNotificationEventCreator.getInstance().publishEvents();

    List<Interaction> noShowInteractions = InteractionComparisonHelper.getNoShowInteractions(
      oldMap,
      records
    );

    interactionToDeleteEvents.addAll(cancelledInteractions);
    interactionToDeleteEvents.addAll(noShowInteractions);

    if (interactionToDeleteEvents.isEmpty() == false) {
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

    if (rescheduledInteractions.isEmpty() == false) {
      rescheduledContactRequestList = InteractionDMLHelper.getRelatedContactRequest(
        rescheduledInteractions
      );
    }

    requestsToRecalculate.addAll(rescheduledContactRequestList);

    if (requestsToRecalculate.isEmpty() == false) {
      ContactRequestTriggerActions.updateConfirmedCount(
        requestsToRecalculate,
        false
      );
    }

    List<Event> relatedEvents = InteractionEventHelper.getRelatedEvents(
      records
    );

    if (relatedEvents.isEmpty() == false) {
      InteractionEventHelper.updateEventSchedule(relatedEvents, records);
    }

    List<Event> events = EventHelper.createEventsFromInteractions(
      userOwnedInteractions
    );
    if (events.isEmpty() == false) {
      EventHelper.insertEvents(events);
    }
    MLCRMSharingUtil.shareRecordByTerritory(oldMap, records, 'Interaction');
  }

  /**
   *  @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    List<Interaction> interactions = InteractionFilter.returnInteractionsWithAutomatedPurpose(
      records
    );

    InteractionSetters.setOwnerNewInteractions(interactions);

    InteractionSetters.setNameOfInteractions(records, new Map<Id, SObject>{});

    List<Interaction> newInteractions = InteractionFilter.getInteractionsWithoutEnddate(
      interactions
    );

    if (!newInteractions.isEmpty()) {
      InteractionActions.updateEndTime(newInteractions);
    }

    InteractionValidations.validateInteractions(interactions);
    InteractionEventHelper.assignDefaultTerritory(records);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(null, records);

    //Added to create Twilio Details when an Interaction created in the system for Chat and Call
    TwilioServiceUtil.insertTwilioDetailsOnInteractionCreation(records);
  }

  /** @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
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

    List<Interaction> reasonOrStartTimeUpdatedInteractions = InteractionActions.getInteractionsRequiringEndTimeUpdate(
      oldMap,
      records
    );

    if (!reasonOrStartTimeUpdatedInteractions.isEmpty()) {
      InteractionActions.updateEndTime(reasonOrStartTimeUpdatedInteractions);
    }
    InteractionActions.unassignInteractions(oldMap, records);
    //Creating a map of all interactions by record type, to be used later. This reduces number of loops.
    Map<String, List<Interaction>> mapOfInteractionsByRecordType = InteractionFilter.getInteractionsByRecordType(
      records
    );

    List<Interaction> apptInteraction = mapOfInteractionsByRecordType.containsKey(
        GetHelpConstants.INTERACTION_APPT_RT_ID
      )
      ? mapOfInteractionsByRecordType.get(
          GetHelpConstants.INTERACTION_APPT_RT_ID
        )
      : new List<Interaction>();

    if (!apptInteraction.isEmpty()) {
      InteractionValidations.validateInteractions(apptInteraction);
    }
    InteractionSetters.setNameOfInteractions(records, oldMap);
    MLCRMCommonUtils.validateTerritoryAndOwnerChange(oldMap, records);
  }
}
