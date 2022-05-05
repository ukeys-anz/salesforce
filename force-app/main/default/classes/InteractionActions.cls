/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Interaction Actions
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class InteractionActions {
  public static final String APPOINTMENTS_QUEUE = 'Appointments_Queue';
  public static final String SCHEDULED_STATUS = 'Scheduled';
  public static final String UNASSIGNED_STATUS = 'Unassigned';
  public static final String RESCHEDULED_STATUS = 'Rescheduled';
  public static final String INPROGRESS_STATUS = 'In Progress';
  public static final String COACHING_SUMMARY_LABEL = ' Coaching Summary';
  public static final String NO_SHOW_STATUS = 'No Show';
  public static final Id QUEUE_ID = CommonUtil.getGroupId(APPOINTMENTS_QUEUE);

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
        interact.Status__c == NO_SHOW_STATUS
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
        currentInteraction.Status__c != 'Cancelled' ||
        !oldMap.containsKey(currentInteraction.Id)
      ) {
        continue;
      }
      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );
      if (oldInteraction.Status__c != 'Cancelled') {
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

    if (Event.SObjectType.getDescribe().isQueryable()) {
      List<Event> linkedEvents = [
        SELECT Id
        FROM Event
        WHERE WhatId IN :interactionIds
      ];

      if (linkedEvents.isEmpty()) {
        return;
      }

      if (Event.SObjectType.getDescribe().isDeletable()) {
        List<Database.DeleteResult> results = Database.Delete(linkedEvents);
        lib_systemLog log = new lib_systemLog(
          'InteractionActions',
          'deleteInteractionEvents'
        );
        Boolean hasError = log.addDatabaseDeleteResult(
          'Events',
          results,
          linkedEvents
        );
        if (hasError) {
          //log errors to application log
          log.insertLog();
        }
      } else {
        CommonUtil.logAndThrowIAE(
          'InteractionActions',
          'deleteInteractionEvents',
          'Not enough permissions to delete Events'
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'deleteInteractionEvents',
        'Not enough permissions to query Events.'
      );
    }
  }

  /**
   * @description Assign the ownership of newly created interactions to the Interaction Queue and update status to Unassigned
   * @param interactions List of newly created interactions.
   */

  public void updateOwnerNewInteractions(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      for (Interaction interact : interactions) {
        interact.OwnerID = QUEUE_ID;
        interact.Status__c = UNASSIGNED_STATUS;
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateOwnerNewInteractions',
        'Not enough permissions to update Interaction.'
      );
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
        interact.Status__c == RESCHEDULED_STATUS
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
    if (
      Event.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Event.fields.StartDateTime.isAccessible() &&
      Schema.SObjectType.Event.fields.EndDateTime.isAccessible() &&
      Schema.SObjectType.Event.fields.WhatId.isAccessible()
    ) {
      eventList = [
        SELECT Id, WhatId, StartDateTime, EndDateTime
        FROM Event
        WHERE WhatId IN :interactionIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getRelatedEvents',
        'Not enough permissions to query Events.'
      );
    }
    return eventList;
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

    updateEvents(eventRecords);
  }

  /**
   * @description Method to update the events record
   * @param events The list of events to be updated
   */

  public void updateEvents(List<Event> events) {
    if (Event.SObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(events);
      lib_systemLog log = new lib_systemLog(
        'InteractionActions',
        'updateEvents'
      );
      Boolean hasError = log.addDatabaseSaveResult('Event', results, events);
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateEvents',
        'Not enough permissions to update Events.'
      );
    }
  }

  /**
   * @description Update the status of the interactions to scheduled if the owner is updated
   * @param interactions The list of interactions where the owner is updated from Queue to Coach
   */

  public void updateStatustoScheduled(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      for (Interaction interact : interactions) {
        interact.Status__c = SCHEDULED_STATUS;
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateStatustoScheduled',
        'Not enough permissions to update Interaction.'
      );
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
   * @description Get the list of contact requests of those interactions which are cancelled
   * @param interactions The list of interactions which were cancelled
   * @return List<ContactRequest> List of ContactRequest records related to the interaction which were cancelled.
   */
  public List<ContactRequest> getRelatedContactRequest(
    List<Interaction> interactions
  ) {
    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    Set<Id> contactRequestIds = new Set<Id>();
    for (Interaction interact : interactions) {
      contactRequestIds.add(interact.ContactRequestId__c);
    }

    if (
      ContactRequest.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.ContactRequest.fields.Appointment_Commitment__c.isAccessible()
    ) {
      contactRequestList = [
        SELECT Id, Appointment_Commitment__c
        FROM ContactRequest
        WHERE ID IN :contactRequestIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getRelatedContactRequest',
        'Not enough permissions to query Contact Request.'
      );
    }
    return contactRequestList;
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that does not have coaching summary.
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that does not have coaching summary linked to it.
   */

  public List<Interaction> getInteractionswithoutCoachingSummary(
    List<Interaction> records
  ) {
    List<Interaction> interactionWithoutSummary = new List<Interaction>();
    for (Interaction interact : records) {
      if (interact.Coaching_Summary__c == null) {
        interactionWithoutSummary.add(interact);
      }
    }

    return interactionWithoutSummary;
  }

  /**
   * @description Goes through a list of Interactions and using an old map, finds the one that has coaching summary.
   * @param records List<Interaction> list of the interaction through which to iterate.
   * @return List<Interaction> list of interaction that has coaching summary linked to it.
   */

  public List<Interaction> getInteractionswithCoachingSummary(
    List<Interaction> records
  ) {
    List<Interaction> interactionWithSummary = new List<Interaction>();
    for (Interaction interact : records) {
      if (interact.Coaching_Summary__c != null) {
        interactionWithSummary.add(interact);
      }
    }

    return interactionWithSummary;
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
   * @description Creates a new coaching summary record based on the interaction
   * @param interactions List<Interaction> list of the interaction records based on which coaching summary records need to be created.
   * @return List<Coaching_Summary__c> list of coaching summary records to be created.
   */

  public List<Coaching_Summary__c> createCoachingSummaryfromInteraction(
    List<Interaction> interactions
  ) {
    List<Coaching_Summary__c> newCoachingSummaries = new List<Coaching_Summary__c>();
    for (Interaction interact : interactions) {
      Coaching_Summary__c coachSummary = new Coaching_Summary__c();
      coachSummary.Name__c =
        interact.Interaction_Purpose__c + COACHING_SUMMARY_LABEL;
      coachSummary.Status__c = INPROGRESS_STATUS;
      coachSummary.OwnerId = interact.OwnerId;
      coachSummary.Account__c = interact.AccountId;
      coachSummary.Lead__c = interact.Lead__c;
      coachSummary.Reason__c = interact.Interaction_Purpose__c;
      newCoachingSummaries.add(coachSummary);
    }

    return newCoachingSummaries;
  }

  /**
   * @description does the database call to insert Coaching Summary
   * @param coachingSummaries List<Coaching_Summary__c> list of coaching summary.
   */
  public void insertCoachingSummary(
    List<Coaching_Summary__c> coachingSummaries
  ) {
    if (
      coachingSummaries != null &&
      Coaching_Summary__c.SObjectType.getDescribe().isCreateable()
    ) {
      List<Database.SaveResult> results = Database.Insert(coachingSummaries);

      lib_systemLog log = new lib_systemLog(
        'InteractionActions',
        'insertCoachingSummary'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Coaching_Summary__c',
        results,
        coachingSummaries
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'insertCoachingSummary',
        'Not enough permissions to insert coaching summary.'
      );
    }
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

    if (Interaction.SObjectType.getDescribe().isAccessible()) {
      List<Interaction> interactions = [
        SELECT Id, Interaction_External_Id__c, Interaction_Auto_Number__c
        FROM Interaction
        WHERE Id IN :interactionIds AND Interaction_External_Id__c = NULL
      ];
      actions.setExternalIds(interactions);
      if (Interaction.SObjectType.getDescribe().isUpdateable()) {
        update interactions;
      } else {
        CommonUtil.logAndThrowIAE(
          'InteractionActions',
          'setExternalIds',
          'Not enough permissions to update Interaction.'
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'setExternalIds',
        'Not enough permissions to query Interaction.'
      );
    }
  }

  /**
   * @description Method to assign the coaching summary record to the interaction record
   * @param interactions The list of interactions to be updated with the coaching summary record
   * @param coachingSummaries The list of coaching summaries to be associated with interaction record.
   */

  public void assignSummaryToInteraction(
    List<Interaction> interactions,
    List<Coaching_Summary__c> coachingSummaries
  ) {
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 0; i < interactions.size(); i++) {
      Interaction interact = new Interaction(Id = interactions[i].Id);
      interact.Coaching_Summary__c = coachingSummaries[i].Id;
      interactionList.add(interact);
    }
    updateInteractions(interactionList);
  }

  /**
   * @description Method to update the interactions record
   * @param interactions The list of interactions to be updated
   */

  public void updateInteractions(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(interactions);
      lib_systemLog log = new lib_systemLog(
        'InteractionActions',
        'updateInteractions'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Interaction',
        results,
        interactions
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateInteractions',
        'Not enough permissions to update Interactions.'
      );
    }
  }

  /**
   * @description Method to update the coaching summary records
   * @param coachingSummaries The list of coaching summary records to be updated
   */

  public void updateCoachingSummary(
    List<Coaching_Summary__c> coachingSummaries
  ) {
    if (Coaching_Summary__c.SObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(coachingSummaries);
      lib_systemLog log = new lib_systemLog(
        'InteractionActions',
        'updateCoachingSummary'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Coaching_Summary__c',
        results,
        coachingSummaries
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'updateCoachingSummary',
        'Not enough permissions to update Coaching Summary object.'
      );
    }
  }
}
