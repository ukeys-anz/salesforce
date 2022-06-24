/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Interaction Actions
 * Adding suppression for Excessive Public Count as tech debt to be resolved
 * later in the Epic's development as per request.
 */
@SuppressWarnings(
  'PMD.CyclomaticComplexity,PMD.ExcessivePublicCount,PMD.ExcessiveClassLength'
)
public with sharing class InteractionActions {
  public static final Id QUEUE_ID = CommonUtil.getGroupId(
    InteractionConstants.APPOINTMENTS_QUEUE
  );

  /**
   * @description Gets the list of interactions and returns the ones where the owner has been assigned back to Queue.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions assigned back to Queue
   */
  public List<Interaction> getInteractionsAssignedBacktoQueue(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> assignedToQueueInteractions = new List<Interaction>();

    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        interact.OwnerId != oldInteraction.OwnerId &&
        interact.OwnerId == QUEUE_ID
      ) {
        assignedToQueueInteractions.add(interact);
      }
    }

    return assignedToQueueInteractions;
  }

  /**
   * @description Gets the list of interactions and returns the ones where the status is updated as No show
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions updated as No show
   */
  public List<Interaction> getNoShowInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> noShowInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) Trigger.oldMap
        .get(interact.Id);
      if (
        oldInteraction.Status__c != interact.Status__c &&
        interact.Status__c == InteractionConstants.NO_SHOW_STATUS
      ) {
        noShowInteractions.add(interact);
      }
    }

    return noShowInteractions;
  }

  /**
   * @description goes through a list of interactions and returns the ones that have been cancelled.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of cancelled interactions
   */
  public List<Interaction> findCancelledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();

    if (interactions.isEmpty()) {
      return result;
    }

    for (Interaction currentInteraction : interactions) {
      if (
        currentInteraction.Status__c != InteractionConstants.CANCELLED_STATUS ||
        !oldMap.containsKey(currentInteraction.Id)
      ) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );
      if (oldInteraction.Status__c != InteractionConstants.CANCELLED_STATUS) {
        result.add(currentInteraction);
      }
    }
    return result;
  }

  /**
   * @description deletes events linked to a list of interactions
   * @param interactions List of interactions to search through and delete related events.
   */
  public void deleteInteractionEvents(List<Interaction> interactions) {
    Set<Id> interactionIds = (new Map<Id, Interaction>(interactions)).keySet();
    if (interactionIds.isEmpty()) {
      return;
    }

    List<Event> linkedEvents = EventHelper.queryRelatedEvents(interactionIds);

    if (!linkedEvents.isEmpty()) {
      EventHelper.deleteEvents(linkedEvents);
    }
  }

  /**
   * @description Assign the ownership of newly created interactions to the Interaction Queue and update status to Unassigned
   * @param interactions List of newly created interactions.
   */
  public void updateOwnerNewInteractions(List<Interaction> interactions) {
    for (Interaction interact : interactions) {
      interact.OwnerID = QUEUE_ID;
      interact.Status__c = InteractionConstants.UNASSIGNED_STATUS;
    }
  }

  /**
   * @description Get the list of updated Interactions where a Coach has taken ownership from the queue
   * @param oldMap The oldValues before the update.
   * @param interactions The new values of the interaction after update.
   * @return List<Interaction> The list of interactions where the owner has been updated
   */
  public List<Interaction> getAcceptedInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> acceptedInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.OwnerId != interact.OwnerId &&
        oldInteraction.OwnerId == QUEUE_ID
      ) {
        acceptedInteractions.add(interact);
      }
    }
    return acceptedInteractions;
  }

  /**
   * @description Get the list of updated Interactions where the status has been updated to Rescheduled
   * @param oldMap The oldValues before the update.
   * @param interactions The new values of the interaction after update.
   * @return List<Interaction> The list of interactions where the status has been updated to rescheduled
   */
  public List<Interaction> getRescheduledInteractions(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> rescheduledInteractions = new List<Interaction>();
    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.Status__c != interact.Status__c &&
        interact.Status__c == InteractionConstants.RESCHEDULED_STATUS
      ) {
        rescheduledInteractions.add(interact);
      }
    }
    return rescheduledInteractions;
  }

  /**
   * @description Get the list of events related to Interaction which was rescheduled
   * @param interactions The list of interactions which were rescheduled
   * @return List<Event> List of event records related to the interaction which were rescheduled.
   */
  public List<Event> getRelatedEvents(List<Interaction> interactions) {
    List<Event> eventList = new List<Event>();
    Set<Id> interactionIds = new Set<Id>();
    for (Interaction interact : interactions) {
      interactionIds.add(interact.Id);
    }
    return EventHelper.queryRelatedEvents(interactionIds);
  }

  /**
   * @description Update the events date and time to match with the interaction
   * @param eventRecords The list of events to be updated
   * @param interactions The interactions which are rescheduled
   */
  public void updateEventSchedule(
    List<Event> eventRecords,
    List<Interaction> interactions
  ) {
    Map<Id, Interaction> interactionMap = new Map<Id, Interaction>();
    for (Interaction interact : interactions) {
      interactionMap.put(interact.Id, interact);
    }

    for (Event evt : eventRecords) {
      evt.StartDateTime = interactionMap.get(evt.WhatId).StartTime;
      evt.EndDateTime = interactionMap.get(evt.WhatId).EndTime;
    }

    EventHelper.updateEvents(eventRecords);
  }

  /**
   * @description Update the status of the interactions to scheduled if the owner is updated
   * @param interactions The list of interactions where the owner is updated from Queue to Coach
   */
  public void updateStatustoScheduled(List<Interaction> interactions) {
    for (Interaction interact : interactions) {
      interact.Status__c = InteractionConstants.SCHEDULED_STATUS;
    }
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that ownership has changed.
   * @param oldMap Map<Id, SObject> map of old versions of the interactions
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that have had their ownership changed.
   */
  public List<Interaction> findInteractionsOwnershipChanged(
    Map<Id, SObject> oldMap,
    List<Interaction> records
  ) {
    List<Interaction> result = new List<Interaction>();
    for (Interaction currentInteraction : records) {
      if (oldMap.containsKey(currentInteraction.Id)) {
        Interaction oldInteraction = (Interaction) oldMap.get(
          currentInteraction.Id
        );
        if (oldInteraction.OwnerId != currentInteraction.OwnerId) {
          result.add(currentInteraction);
        }
      }
    }
    return result;
  }

  /**
   * @description Goes through a list of Interactions and assigns the current owner of interaction to the coaching summary.
   * @param interactions List<Interaction> list of the interaction through which to iterate.
   * @return List<Coaching_Summary> list of coaching summary records updated with new owner.
   */
  public List<Coaching_Summary__c> assignCoachingSummaryOwner(
    List<Interaction> interactions
  ) {
    List<Coaching_Summary__c> coachingSummaryList = new List<Coaching_Summary__c>();
    for (Interaction interact : interactions) {
      Coaching_Summary__c coachSummary = new Coaching_Summary__c(
        Id = interact.Coaching_Summary__c
      );
      coachSummary.OwnerId = interact.OwnerId;
      coachingSummaryList.add(coachSummary);
    }
    return coachingSummaryList;
  }

  /**
   * @description goes through a list of interactions and sets the external Id to the autonumber if it is not already set
   * @param interactions list of interactions to cycle
   */
  public void setExternalIds(List<Interaction> interactions) {
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.Interaction_External_Id__c == null) {
        currentInteraction.Interaction_External_Id__c = currentInteraction.Interaction_Auto_Number__c;
      }
    }
  }

  /**
   * @description future method to set the external Id after creation
   * @param interactionIds the Ids to update
   */
  @future
  public static void setExternalIds(Set<Id> interactionIds) {
    InteractionActions actions = new InteractionActions();

    List<Interaction> interactions = InteractionDMLHelper.getInteractions(
      interactionIds
    );
    if (!interactions.isEmpty()) {
      List<Interaction> interactionsToSet = new List<Interaction>();
      for (Interaction currentInteraction : interactions) {
        if (currentInteraction.Interaction_External_Id__c == null) {
          interactionsToSet.add(currentInteraction);
        }
      }

      if (!interactionsToSet.isEmpty()) {
        actions.setExternalIds(interactions);
        InteractionDMLHelper.updateInteractions(interactions);
      }
    }
  }

  /**
   * @description Method to updated interactions without end time
   * @param interactions List<Interaction> list of interaction records without end time.
   */
  public void updateEndTime(List<Interaction> interactions) {
    ContactRequestActions crActions = new ContactRequestActions();
    for (Interaction interact : interactions) {
      Integer duration = interact.Interaction_Purpose__c != null
        ? crActions.getDuration(interact.Interaction_Purpose__c)
        : 0;
      interact.EndTime = interact.StartTime != null
        ? interact.StartTime.addMinutes(duration)
        : null;
    }
  }

  /**
   * @description Gets the list of interactions and returns the ones where the reason or starttime has been updated.
   * @param oldMap Map<Id,SObject> map of the old versions of the interactions
   * @param interactions List<Interaction> list of interactions through which to search.
   * @return List<Interaction> list of interactions where end time needs to be updated.
   */
  public List<Interaction> getInteractionsRequiringEndTimeUpdate(
    Map<Id, SObject> oldMap,
    List<Interaction> interactions
  ) {
    List<Interaction> interactionList = new List<Interaction>();

    for (Interaction interact : interactions) {
      Interaction oldInteraction = (Interaction) oldMap.get(interact.Id);
      if (
        oldInteraction.Interaction_Purpose__c !=
        interact.Interaction_Purpose__c ||
        oldInteraction.StartTime != interact.StartTime
      ) {
        interactionList.add(interact);
      }
    }
    return interactionList;
  }

  /**
   * @description goes through a list of Interactions and if they have moved status to unassigned set the owner to the queue
   * @param oldMap Map<Id,SObject> old map of interactions
   * @param records List<Interaction> list of interactions of which to search
   * @return List<Interaction> interactions that have been updated
   */
  public List<Interaction> unassignInteractions(
    Map<Id, sObject> oldMap,
    List<Interaction> records
  ) {
    Id groupId = CommonUtil.getGroupId(InteractionConstants.APPOINTMENTS_QUEUE);
    Id appointmentRTID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get(InteractionConstants.APPOINTMENT_RECORD_TYPE_NAME)
      .getRecordTypeId();
    List<Interaction> results = new List<Interaction>();
    for (Interaction currentInteraction : records) {
      if (
        !oldMap.containsKey(currentInteraction.Id) ||
        currentInteraction.Status__c !=
        InteractionConstants.UNASSIGNED_STATUS ||
        currentInteraction.RecordTypeId != appointmentRTID
      ) {
        continue;
      }

      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );

      if (oldInteraction.Status__c == InteractionConstants.UNASSIGNED_STATUS) {
        continue;
      }

      currentInteraction.OwnerId = groupId;
      results.add(currentInteraction);
    }
    return results;
  }

  /** @description Loop through list of new interactions and validate the data.
   * @param interactions New interaction records to be created.
   */
  public void validateInteractions(List<Interaction> interactions) {
    Set<Id> accountIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();
    for (Interaction interact : interactions) {
      if (interact.AccountId != null) {
        accountIds.add(interact.AccountId);
      }
      if (interact.Lead__c != null) {
        leadIds.add(interact.Lead__c);
      }
    }
    Map<Id, List<Interaction>> accountInteractionMap = InteractionDMLHelper.getAccountInteractionMap(
      accountIds
    );
    Map<Id, List<Interaction>> leadInteractionMap = existingLeadInteractions(
      leadIds
    );
    validateOverlappingInteractions(
      accountInteractionMap,
      leadInteractionMap,
      interactions
    );

    validateLocations(interactions);
  }

  /**
   * @description goes through a list of interactions and adds an error if any have a channel of store, but no location
   * @param interactions List<Interaction> to search through for offenders.
   */
  private void validateLocations(List<Interaction> interactions) {
    for (Interaction currentInteraction : interactions) {
      if (
        currentInteraction.InteractionType == 'Store' &&
        currentInteraction.LocationId == null
      ) {
        currentInteraction.addError(System.Label.Interaction_Store_Required);
      }
    }
  }

  /** @description Method to get the list of existing scheduled interactions for the lead
   * @param leadIds Set of lead ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of lead ids and list of scheduled interactions creared for the customer
   */
  public Map<Id, List<Interaction>> existingLeadInteractions(Set<Id> leadIds) {
    Map<Id, List<Interaction>> leadInteractionMap = new Map<Id, List<Interaction>>();
    List<Interaction> interactionsForLeads = InteractionDMLHelper.getInteractionsByLead(
      leadIds
    );

    for (Interaction interact : interactionsForLeads) {
      List<Interaction> tempInteractionList = new List<Interaction>();
      if (leadInteractionMap.containsKey(interact.Lead__c)) {
        tempInteractionList = leadInteractionMap.get(interact.Lead__c);
      }
      tempInteractionList.add(interact);
      leadInteractionMap.put(interact.Lead__c, tempInteractionList);
    }
    return leadInteractionMap;
  }

  /** @description Method to identify if the customer has any existing interactions at the same time.
   * @param accountInteractionMap Map of account id and the existing list of scheduled interactions
   * @param leadInteractionMap Map of lead id and the existing list of scheduled interactions
   * @param interactions list of new interactions created.
   */
  public void validateOverlappingInteractions(
    Map<Id, List<Interaction>> accountInteractionMap,
    Map<Id, List<Interaction>> leadInteractionMap,
    List<Interaction> interactions
  ) {
    Set<Id> customersWithExistingInteractions = new Set<Id>();
    for (Interaction interact : interactions) {
      List<Interaction> customersInteractions = new List<Interaction>();

      if (accountInteractionMap.containsKey(interact.AccountId)) {
        customersInteractions.addAll(
          accountInteractionMap.get(interact.AccountId)
        );
      }
      if (leadInteractionMap.containsKey(interact.Lead__c)) {
        customersInteractions.addAll(leadInteractionMap.get(interact.Lead__c));
      }
      if (!customersInteractions.isEmpty()) {
        Interaction existingInteraction = getInteractionAtSameTime(
          interact,
          customersInteractions
        );
        Boolean existingInteractionAvailable = existingInteraction != null;
        if (existingInteractionAvailable) {
          if (!String.isEmpty(interact.ContactRequestId__c)) {
            interact.addError(
              System.Label.Interaction_User_Created_Error_Message +
              existingInteraction.Interaction_External_Id__c
            );
          } else {
            interact.addError(
              System.Label.Interaction_Coach_Created_Error_Message
            );
          }
        }
      }
    }
  }

  /** @description Method to loop through list of existing interactions to identify if there are any overlaps
   * @param newinteraction The new interaction record created
   * @param interactions list of existing interactions for the customer
   * @return Boolean Returns true or false if there are conflicting
   */
  public Boolean verifyTimeSlots(
    Interaction newinteraction,
    List<Interaction> interactions
  ) {
    Boolean existingInteractionAvailable = false;
    existingInteractionAvailable =
      getInteractionAtSameTime(newinteraction, interactions) != null;
    return existingInteractionAvailable;
  }

  /** @description Method to loop through list of existing interactions to identify if there are any overlaps
   * @param newInteraction The new interaction record created
   * @param interactions list of existing interactions for the customer
   * @return Interaction Returns the conflicting interaction if one exists or null
   */
  public Interaction getInteractionAtSameTime(
    Interaction newInteraction,
    List<Interaction> interactions
  ) {
    for (Interaction interact : interactions) {
      Boolean doDatesIntersect = Lib_SystemLog.doPeriodsIntersect(
        newInteraction.StartTime,
        newInteraction.EndTime,
        interact.StartTime,
        interact.EndTime
      );
      if (doDatesIntersect && interact.Id != newInteraction.Id) {
        return interact;
      }
    }
    return null;
  }

  /** @description Method to validate if the coach has an existing appointment while accepting a new one
   * @param interactions List of new interactions accepted by the coach
   */
  public void validateCoachAssignment(List<Interaction> interactions) {
    Set<Id> coachIds = new Set<Id>();
    for (Interaction interact : interactions) {
      coachIds.add(interact.OwnerId);
    }

    Map<Id, List<Interaction>> existingCoachInteractions = new Map<Id, List<Interaction>>();
    existingCoachInteractions = getCoachExistingInteractions(coachIds);
    validateOverlappingCoachInteractions(
      existingCoachInteractions,
      interactions
    );
  }

  /** @description Method to get the list of existing scheduled interactions for the coach
   * @param coachIds Set of coach ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of owner ids and list of scheduled interactions creared for the corresponding coach
   */
  public Map<Id, List<Interaction>> getCoachExistingInteractions(
    Set<Id> coachIds
  ) {
    Map<Id, List<Interaction>> coachInteractions = new Map<Id, List<Interaction>>();
    List<Interaction> leadInteractions = InteractionDMLHelper.existingUniqueInteractions(
      coachIds
    );
    for (Interaction interact : leadInteractions) {
      List<Interaction> tempInteractionList = new List<Interaction>();
      if (coachInteractions.containsKey(interact.OwnerId)) {
        tempInteractionList = coachInteractions.get(interact.OwnerId);
      }
      tempInteractionList.add(interact);
      coachInteractions.put(interact.OwnerId, tempInteractionList);
    }
    return coachInteractions;
  }

  /** @description Method to identify if the coach has any existing interactions at the same time.
   * @param existingCoachInteractions  Map of owner id and the existing list of scheduled interactions
   * @param interactions list of new interactions created.
   */
  public void validateOverlappingCoachInteractions(
    Map<Id, List<Interaction>> existingCoachInteractions,
    List<Interaction> interactions
  ) {
    for (Interaction interact : interactions) {
      Boolean hasOwnerExistingInteractions = existingCoachInteractions.containsKey(
        interact.OwnerId
      );
      if (hasOwnerExistingInteractions) {
        Boolean existingInteractionAvailable = verifyTimeSlots(
          interact,
          existingCoachInteractions.get(interact.OwnerId)
        );
        if (existingInteractionAvailable) {
          interact.addError(
            System.Label.Coach_Existing_Interaction_Error_Message
          );
        }
      }
    }
  }

  /** @description Method to set the Interaction Name for manual interaction creations
   * @param interactions list of new interactions created.
   */
  public void setNameOfInteractions(List<Interaction> interactions) {
    for (Interaction interact : interactions) {
      interact.Name = interact.Interaction_Purpose__c + ' Appointment';
    }
  }

  /**
   * @description goes through a list of interactions and sets the Interaction Id
   * on the linked Contact Request by searching the database for requests related to the Interactionss.
   * @param interactions List<Interaction> list of interactions to cycle through
   */
  public void setInteractionIds(List<Interaction> interactions) {
    Set<Id> requestIds = new Set<Id>();

    for (Interaction currentInteraction : interactions) {
      requestIds.add(currentInteraction.ContactRequestId__c);
    }

    List<ContactRequest> contactRequests = ContactRequestDMLHelper.getContactRequest(
      requestIds
    );
    setInteractionIds(contactRequests, interactions);

    ContactRequestDMLHelper.updateContactRequests(contactRequests);
  }

  /**
   * @description goes through a list of requests and sets the Interaction Id
   * by searching the database for interactions related to the Contact Requests.
   * @param requests List<ContactRequest> list of contact requests to cycle through
   */
  public void setInteractionIds(List<ContactRequest> requests) {
    Set<Id> requestIds = (new Map<Id, ContactRequest>(requests)).keyset();

    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      List<Interaction> interactions = [
        SELECT Id, ContactRequestId__c
        FROM Interaction
        WHERE Id IN :requestIds
      ];
      setInteractionIds(requests, interactions);
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'setInteractionIds',
        'Not enough permissions to query Interactions.'
      );
    }
  }

  /**
   * @description goes through a list of requests and sets the Interaction Id
   * based upon a list of interactions
   * @param requests List<ContactRequest> list of contact requests to cycle through
   * @param interactions List<Interaction> list of interactions to draw from.
   */
  public void setInteractionIds(
    List<ContactRequest> requests,
    List<Interaction> interactions
  ) {
    if (requests.isEmpty() || interactions.isEmpty()) {
      return;
    }
    Map<Id, Id> contactRequestInteractionIdMap = new Map<Id, Id>();
    for (Interaction currentInteraction : interactions) {
      contactRequestInteractionIdMap.put(
        currentInteraction.ContactRequestId__c,
        currentInteraction.Id
      );
    }

    for (ContactRequest request : requests) {
      if (contactRequestInteractionIdMap.containsKey(request.Id)) {
        request.Interaction__c = contactRequestInteractionIdMap.get(request.Id);
      }
    }
  }

  /**
   * @description gets accounts related to an list of interactions in a map.
   * @param interactions List<Interaction> interactions for which to get the accounts
   * @return Map<Id,Account> map of accounts.
   */
  public Map<Id, Account> getAccountMapFromInteractions(
    List<Interaction> interactions
  ) {
    Map<Id, Account> result = new Map<Id, Account>();

    Set<Id> accountIds = new Set<Id>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        accountIds.add(currentInteraction.AccountId);
      }
    }
    if (!accountIds.isEmpty()) {
      AccountQueryHelper accountHelper = new AccountQueryHelper();
      result = new Map<Id, Account>(
        accountHelper.findAccountsByAccountIds(accountIds)
      );
    }
    return result;
  }

  /**
   * @description gets leads related to a list of interactions in a map.
   * @param interactions List<Interaction> interactions for which to get the leads
   * @return Map<Id,Lead> map of leads.
   */
  public Map<Id, Lead> getLeadMapFromInteractions(
    List<Interaction> interactions
  ) {
    Map<Id, Lead> result = new Map<Id, Lead>();

    Set<Id> leadIds = new Set<Id>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        if (currentInteraction.Lead__c != null) {
          leadIds.add(currentInteraction.Lead__c);
        }
      }
    }
    if (!leadIds.isEmpty()) {
      result = LeadDMLHelper.getLeadInfoMap(leadIds);
    }
    return result;
  }
}
