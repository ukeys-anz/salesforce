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
  public static final String APPOINTMENTS_QUEUE = 'Appointments_Queue';
  public static final String SCHEDULED_STATUS = 'Scheduled';
  public static final String UNASSIGNED_STATUS = 'Unassigned';
  public static final String RESCHEDULED_STATUS = 'Rescheduled';
  public static final String INPROGRESS_STATUS = 'In Progress';
  public static final String NEW_STATUS = 'New';
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
    for (Interaction interact : interactions) {
      interact.OwnerID = QUEUE_ID;
      interact.Status__c = UNASSIGNED_STATUS;
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

    if (ContactRequest.SObjectType.getDescribe().isAccessible()) {
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
      coachSummary.Status__c = NEW_STATUS;
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

  /**
   * @description Returns the list of new interactions without End time
   * @param interactions List<Interaction> list of new interaction records.
   * @return List<Interaction> list of interactions without end time.
   */

  public List<Interaction> getInteractionsWithoutEnddate(
    List<Interaction> interactions
  ) {
    List<Interaction> interactionList = new List<Interaction>();
    for (Interaction interact : interactions) {
      if (interact.EndTime == null) {
        interactionList.add(interact);
      }
    }
    return interactionList;
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

  /** @description sets the interaction's Contact Mobile field and queries the Database for Accounts
   * @param interactions Interaction the interaction of which to set the Contact Mobile.
   */
  public void setInteractionsMobile(List<Interaction> interactions) {
    Map<Id, Account> accountMap = getAccountInfo(interactions);
    Map<Id, Lead> leadMap = getLeadInfo(interactions);
    setInteractionsMobile(interactions, accountMap, leadMap);
  }

  /**
   * @description sets the interaction's Contact Mobile field
   * @param interactions Interaction the interaction of which to set the Contact Mobile.
   * @param accountMap Map<Id,Account> Map of Accounts linked to the interactions
   * @param leadMap Map<Id,Lead> Map of Leads linked to the interactions
   */
  public void setInteractionsMobile(
    List<Interaction> interactions,
    Map<Id, Account> accountMap,
    Map<Id, Lead> leadMap
  ) {
    for (Interaction currentInteraction : interactions) {
      if (
        currentInteraction.AccountId != null &&
        accountMap.containsKey(currentInteraction.AccountId)
      ) {
        currentInteraction.Contact_Mobile__c = accountMap.get(
            currentInteraction.AccountId
          )
          .PersonMobilePhone;
      } else if (
        currentInteraction.Lead__c != null &&
        leadMap.containsKey(currentInteraction.Lead__c)
      ) {
        currentInteraction.Contact_Mobile__c = leadMap.get(
            currentInteraction.Lead__c
          )
          .MobilePhone;
      }
    }
  }

  /**
   * @description gets information about Leads linked to a list of Interactions
   * @param interactions List<Interaction> list of interactions
   * @return Map<Id,Lead> A map of Leads
   */
  private Map<Id, Lead> getLeadInfo(List<Interaction> interactions) {
    Map<Id, Lead> leadMap = new Map<Id, Lead>();
    Set<Id> leadIds = new Set<Id>();
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.Lead__c != null) {
        leadIds.add(currentInteraction.Lead__c);
      }
    }
    if (Lead.SObjectType.getDescribe().isQueryable()) {
      List<Lead> interactionLeads = [
        SELECT Id, MobilePhone
        FROM Lead
        WHERE Id IN :leadIds
      ];
      if (!interactionLeads.isEmpty()) {
        leadMap = new Map<Id, Lead>(interactionLeads);
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getLeadInfo',
        'Not enough permissions to query Leads.'
      );
    }
    return leadMap;
  }

  /**
   * @description gets information about accounts linked to a list of Interactions
   * @param interactions List<Interaction> list of interactions
   * @return Map<Id,Acount> A map of Accounts
   */
  private Map<Id, Account> getAccountInfo(List<Interaction> interactions) {
    Map<Id, Account> accountMap = new Map<Id, Account>();
    Set<Id> accountIds = new Set<Id>();
    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.AccountId != null) {
        accountIds.add(currentInteraction.AccountId);
      }
    }
    if (Account.SObjectType.getDescribe().isQueryable()) {
      List<Account> interactionAccounts = [
        SELECT Id, PersonMobilePhone
        FROM Account
        WHERE Id IN :accountIds
      ];
      if (!interactionAccounts.isEmpty()) {
        accountMap = new Map<Id, Account>(interactionAccounts);
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'getAccountInfo',
        'Not enough permissions to query Accounts.'
      );
    }
    return accountMap;
  }

  /**
   * @description finds & returns interactions without a mobile number
   * @param interactions List<Interaction> list of interactions through which to search
   * @return List<Interaction> List of interactions without mobile number.
   */
  public List<Interaction> findInteractionsWithoutMobile(
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();

    for (Interaction currentInteraction : interactions) {
      if (currentInteraction.Contact_Mobile__c == null) {
        result.add(currentInteraction);
      }
    }

    return result;
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
    Id groupId = CommonUtil.getGroupId('Appointments_Queue');
    Id appointmentRTID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Appointment')
      .getRecordTypeId();
    List<Interaction> results = new List<Interaction>();
    for (Interaction currentInteraction : records) {
      if (
        !oldMap.containsKey(currentInteraction.Id) ||
        currentInteraction.Status__c != UNASSIGNED_STATUS ||
        currentInteraction.RecordTypeId != appointmentRTID
      ) {
        continue;
      }

      Interaction oldInteraction = (Interaction) oldMap.get(
        currentInteraction.Id
      );

      if (oldInteraction.Status__c == UNASSIGNED_STATUS) {
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
    Map<Id, List<Interaction>> accountInteractionMap = existingInteractions(
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
  }

  /** @description Method to get the list of existing scheduled interactions for the customer
   * @param accountIds Set of account ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of account ids and list of scheduled interactions creared for the customer
   */
  public Map<Id, List<Interaction>> existingInteractions(Set<Id> accountIds) {
    Map<Id, List<Interaction>> accountInteractionMap = new Map<Id, List<Interaction>>();
    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      List<Interaction> interactionsForAccounts = [
        SELECT
          Id,
          AccountId,
          StartTime,
          Endtime,
          OwnerId,
          Interaction_External_Id__c
        FROM Interaction
        WHERE Status__c = :SCHEDULED_STATUS AND AccountId IN :accountIds
      ];

      for (Interaction interact : interactionsForAccounts) {
        List<Interaction> tempInteractionList = new List<Interaction>();
        if (accountInteractionMap.containsKey(interact.AccountId)) {
          tempInteractionList = accountInteractionMap.get(interact.AccountId);
        }
        tempInteractionList.add(interact);
        accountInteractionMap.put(interact.AccountId, tempInteractionList);
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return accountInteractionMap;
  }

  /** @description Method to get the list of existing scheduled interactions for the lead
   * @param leadIds Set of lead ids related to the new interactions
   * @return  Map<Id, List<Interaction>> Map of lead ids and list of scheduled interactions creared for the customer
   */
  public Map<Id, List<Interaction>> existingLeadInteractions(Set<Id> leadIds) {
    Map<Id, List<Interaction>> leadInteractionMap = new Map<Id, List<Interaction>>();
    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      List<Interaction> interactionsForAccounts = [
        SELECT
          Id,
          Lead__c,
          StartTime,
          Endtime,
          OwnerId,
          Interaction_External_Id__c
        FROM Interaction
        WHERE Status__c = :SCHEDULED_STATUS AND Lead__c IN :leadIds
      ];

      for (Interaction interact : interactionsForAccounts) {
        List<Interaction> tempInteractionList = new List<Interaction>();
        if (leadInteractionMap.containsKey(interact.Lead__c)) {
          tempInteractionList = leadInteractionMap.get(interact.Lead__c);
        }
        tempInteractionList.add(interact);
        leadInteractionMap.put(interact.Lead__c, tempInteractionList);
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
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
   * @param newinteraction The new interaction record created
   * @param interactions list of existing interactions for the customer
   * @return Interaction Returns the conflicting interaction if one exists or null
   */
  public Interaction getInteractionAtSameTime(
    Interaction newinteraction,
    List<Interaction> interactions
  ) {
    for (Interaction interact : interactions) {
      if (
        newInteraction.StartTime.date() == interact.StartTime.date() &&
        ((newInteraction.StartTime.time() >= interact.StartTime.time() &&
        newInteraction.StartTime.time() < interact.Endtime.time()) ||
        (newInteraction.Endtime.time() > interact.StartTime.time()))
      ) {
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
    if (Interaction.SObjectType.getDescribe().isQueryable()) {
      for (Interaction interact : [
        SELECT Id, AccountId, StartTime, Endtime, OwnerId
        FROM Interaction
        WHERE Status__c = :SCHEDULED_STATUS AND OwnerId IN :coachIds
      ]) {
        List<Interaction> tempInteractionList = new List<Interaction>();
        if (coachInteractions.containsKey(interact.OwnerId)) {
          tempInteractionList = coachInteractions.get(interact.OwnerId);
        }
        tempInteractionList.add(interact);
        coachInteractions.put(interact.OwnerId, tempInteractionList);
      }
      return coachInteractions;
    } else {
      CommonUtil.logAndThrowIAE(
        'InteractionActions',
        'existingInteractions',
        'Not enough permissions to query Interaction object.'
      );
    }
    return null;
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
}
