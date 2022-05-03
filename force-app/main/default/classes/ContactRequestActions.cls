/**
 * @author Adam Smith
 * @since 20220324
 * @description class for Automating object creation from accepting a Contact Request
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class ContactRequestActions {
  private static string appointmentQueueName = 'Appointments_Queue';

  /**
   * @description Goes through a list of Contact Request records, and returns the ones that
   * have been switch to the currently logged in user.
   * @param oldMap Map of the old version of Contact Request records
   * @param requestRecords List of the new version of Contact request records
   * @return List<ContactRequest>
   */
  public List<ContactRequest> findRequestsThatNowBelongToUser(
    Map<id, SObject> oldMap,
    List<SObject> requestRecords
  ) {
    List<ContactRequest> requests = new List<ContactRequest>();
    Id contactRequestQueueId = getContactRequestGroupId();
    for (SObject requestSObject : requestRecords) {
      ContactRequest newRequest = (ContactRequest) requestSObject;
      ContactRequest oldRequest = (ContactRequest) oldMap.get(newRequest.Id);
      if (
        oldRequest.OwnerId != newRequest.OwnerId &&
        UserInfo.getUserId() == newRequest.OwnerId &&
        oldRequest.OwnerId == contactRequestQueueId
      ) {
        requests.add(newRequest);
      }
    }
    return requests;
  }

  //local variable holding the Appointment Queue
  private Group localAppointmentQueue;

  /**
   * @description lazy loads the appointment queue and stores in a local variable to save on database calls.
   */
  private Group appointmentQueue {
    get {
      if (localAppointmentQueue == null) {
        localAppointmentQueue = CommonUtil.getQueueByName(appointmentQueueName);
      }
      return localAppointmentQueue;
    }
  }

  /**
   * @description gets the Contact Request Group Id
   * @return Id the Group Id
   */
  public Id getContactRequestGroupId() {
    return CommonUtil.getGroupId('Contact_Request');
  }

  /**
   * @description goes through a list of Contact Requests, if the purpose is
   * marked as automated, creates Interactions, Interaction Summaries, and events.
   * @param requests List<ContactRequest> list of contact requests to be processed.
   * @return List<ContactRequest> newly updated contact requests.
   */
  public List<ContactRequest> acceptContactRequests(
    List<ContactRequest> requests
  ) {
    List<ContactRequest> results = new List<ContactRequest>();
    List<Interaction> interactions = new List<Interaction>();

    List<ContactRequest> requestsWithAutomatedPurpose = returnRequestsWithAutomatedPurpose(
      requests
    );

    for (ContactRequest request : requestsWithAutomatedPurpose) {
      request.Status = 'Accepted';
      results.add(request);
    }

    return results;
  }

  /**
   * @description does the database call to insert Interactions
   * @param interactions List<Interaction> list of interactions.
   */
  public void insertInteractions(List<Interaction> interactions) {
    if (Interaction.SObjectType.getDescribe().isCreateable()) {
      List<Database.SaveResult> results = Database.Insert(interactions);
      lib_systemLog log = new lib_systemLog(
        'ContactRequestActions',
        'insertInteractions'
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
        'ContactRequestActions',
        'insertInteractions',
        'Not enough permissions to create Interactions.'
      );
    }
  }

  /**
   * @description does the database call to insert Interaction Summaries
   * @param summaries List<InteractionSummary> list of interaction summaries.
   */
  public void insertSummaries(List<InteractionSummary> summaries) {
    if (InteractionSummary.SObjectType.getDescribe().isCreateable()) {
      List<Database.SaveResult> results = Database.Insert(summaries);
      lib_systemLog log = new lib_systemLog(
        'ContactRequestActions',
        'insertSummaries'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'InteractionSummary',
        results,
        summaries
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'insertSummaries',
        'Not enough permissions to create Interaction Summaries.'
      );
    }
  }

  /**
   * @description creates interactions from a list of requests
   * @param requests List<ContactRequest> requests for which to create Interactions
   * @return List<Interaction> newly created interactions.
   */
  public List<Interaction> createInteractionsFromRequests(
    List<ContactRequest> requests
  ) {
    Map<Id, Id> contactAccountMap = getWhoIdAccountMap(requests);
    List<Interaction> result = new List<Interaction>();
    for (ContactRequest request : requests) {
      Interaction newInteraction = createInteractionFromRequest(
        request,
        contactAccountMap
      );
      if (newInteraction != null) {
        result.add(newInteraction);
      }
    }
    return result;
  }

  /**
   * @description override for creates a new interaction from a Contact Request
   * that searches for the WhoId's Account record.
   * @param request ContactRequest object from which to create the Interaction.
   * @return Interaction newly created & inserted Interaction object.
   */
  public Interaction createInteractionFromRequest(ContactRequest request) {
    Map<Id, Id> contactAccountMap = getWhoIdAccountMap(
      new List<ContactRequest>{ request }
    );
    return createInteractionFromRequest(request, contactAccountMap);
  }

  /**
   * @description creates a new interaction from a Contact Request
   * @param request ContactRequest object from which to create the Interaction.
   * @param contactAccountMap Map<Id,Id> contains a map of ContactId to their AccountId.
   * @return Interaction newly created & inserted Interaction object.
   */
  public Interaction createInteractionFromRequest(
    ContactRequest request,
    Map<Id, Id> contactAccountMap
  ) {
    if (request.Appointment_date_and_Time__c == null) {
      request.addError(
        'You must select an Appointment Date and Time before accepting the request'
      );
      return null;
    }
    Integer duration = getDuration(request.RequestReason);
    Id accID = contactAccountMap.get(request.WhoId);
    Id leadId = null;
    if (accID == null) {
      leadId = request.WhoId;
    }

    Id appointmentRecordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByName()
      .get('Appointment')
      .getRecordTypeId();

    string defaultInteractionStatus = 'Unassigned';
    Interaction newInteraction = new Interaction(
      Status__c = defaultInteractionStatus,
      Interaction_Purpose__c = request.RequestReason,
      StartTime = request.Appointment_date_and_Time__c,
      AccountId = accID,
      Lead__c = leadId,
      Name = request.RequestReason + ' Appointment',
      EndTime = request.Appointment_date_and_Time__c.addMinutes(duration),
      Description = request.RequestDescription,
      Direction__c = getDirection(request.PreferredChannel),
      ContactRequestId__c = request.Id,
      OwnerId = appointmentQueue.Id,
      InteractionType = request.PreferredChannel,
      Channel_Booked__c = request.Channel_Booked__c,
      RecordTypeId = appointmentRecordTypeId
    );
    return newInteraction;
  }

  /**
   * @description returns the direction based upon the preferred channel
   * @param preferredChannel String the preferred channel.
   * @return the direction
   */
  public string getDirection(string preferredChannel) {
    switch on preferredChannel {
      when 'Call' {
        return 'Outbound';
      }
      when else {
        return '';
      }
    }
  }

  /**
   * @description goes through a list of ContactRequests and returns the ones that
   * have a purpose that is automated.
   * @param requests List<ContactRequest> Requests to search through
   * @return List<ContactRequest> requests that have automation enabled.
   */
  public List<ContactRequest> returnRequestsWithAutomatedPurpose(
    List<ContactRequest> requests
  ) {
    List<ContactRequest> results = new List<ContactRequest>();

    if (!requests.isEmpty()) {
      for (ContactRequest request : requests) {
        if (
          AutomatedRequestMetadataProvider.getInstance()
            .getMap()
            .containsKey(request.RequestReason)
        ) {
          results.add(request);
        }
      }
    }
    return results;
  }

  /**
   * @description goes through a list of interactions and returns the ones that have an automated purpose
   * @param interactions List<Interaction> list of interactions to search through.
   * @return List<Interaction> List of interactions that have an automated purpose
   */
  public List<Interaction> returnInteractionsWithAutomatedPurpose(
    List<Interaction> interactions
  ) {
    List<Interaction> result = new List<Interaction>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        if (
          AutomatedRequestMetadataProvider.getInstance()
            .getMap()
            .containsKey(currentInteraction.Interaction_Purpose__c)
        ) {
          result.add(currentInteraction);
        }
      }
    }
    return result;
  }

  /**
   * @description goes through a list of ContactRequests and returns a map
   * of ContactId to AccountId based on the WhoId
   * @param requests List<ContactRequest> requests to search through
   * @return Map<Id,Id> map of ContactId to related AccountId
   */
  public Map<Id, Id> getWhoIdAccountMap(List<ContactRequest> requests) {
    Map<Id, Id> results = new Map<Id, Id>();

    Set<Id> whoIds = new Set<Id>();
    if (!requests.isEmpty()) {
      for (ContactRequest request : requests) {
        whoIds.add(request.WhoId);
      }
    }
    if (whoIds.isEmpty()) {
      return results;
    }
    if (Account.SObjectType.getDescribe().isQueryable()) {
      List<Account> personAccounts = [
        SELECT Id, PersonContactId
        FROM Account
        WHERE PersonContactId IN :whoIds
      ];

      if (!personAccounts.isEmpty()) {
        for (Account personAccount : personAccounts) {
          results.put(personAccount.PersonContactId, PersonAccount.Id);
        }
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'getWhoIdAccountMap',
        'Not enough permissions to query Account.'
      );
    }

    return results;
  }

  /**
   * @description creates events from Interactions
   * @param interactions List<Interaction> subject from which to create Events
   * @return List<Event> newly created Events.
   */
  public List<Event> createEventsFromInteractions(
    List<Interaction> interactions
  ) {
    Map<Id, Account> accountMap = getAccountMapFromInteractions(interactions);
    Map<Id, Lead> leadMap = getLeadMapFromInteractions(interactions);
    List<Event> result = new List<Event>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        result.add(
          createEventFromInteraction(currentInteraction, accountMap, leadMap)
        );
      }
    }
    return result;
  }

  /**
   * @description does the database call to insert Events
   * @param events List<Event> list of events.
   */
  public void insertEvents(List<Event> events) {
    if (events != null && Event.SObjectType.getDescribe().isCreateable()) {
      List<Database.SaveResult> results = Database.Insert(events);

      lib_systemLog log = new lib_systemLog(
        'ContactRequestActions',
        'insertEvents'
      );
      Boolean hasError = log.addDatabaseSaveResult('Events', results, events);
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'insertEvents',
        'Not enough permissions to create Events.'
      );
    }
  }

  /**
   * @description creates an event from an Interaction
   * @param interactionSubject Interaction subject from which to create an Event
   * @return Event newly created Event.
   */
  public Event createEventFromInteraction(Interaction interactionSubject) {
    Map<Id, Account> accountMap = getAccountMapFromInteractions(
      new List<Interaction>{ interactionSubject }
    );
    Map<Id, Lead> leadMap = getLeadMapFromInteractions(
      new List<Interaction>{ interactionSubject }
    );
    return createEventFromInteraction(interactionSubject, accountMap, leadMap);
  }

  /**
   * @description creates an event from an Interaction
   * @param interactionSubject Interaction subject from which to create an Event
   * @param accountMap Map<Id,Account> map of Accounts to their Id.
   * @param leadMap Map<Id,Lead> map of leads to their Id.
   * @return Event newly created Event.
   */
  public Event createEventFromInteraction(
    Interaction interactionSubject,
    Map<Id, Account> accountMap,
    Map<Id, Lead> leadMap
  ) {
    Account interactionAccount = accountMap.get(interactionSubject.AccountId);
    Event result = new Event();
    result.StartDateTime = interactionSubject.StartTime;
    result.WhatId = interactionSubject.Id;
    if (interactionAccount != null) {
      result.WhoId = interactionAccount.PersonContactId;
      result.Subject = 'Appointment with ' + interactionAccount.Name;
    } else {
      result.Lead__c = interactionSubject.Lead__c;
      Lead interactionLead = leadMap.get(interactionSubject.Lead__c);
      result.Subject = 'Appointment with ' + interactionLead.Name;
    }
    result.EndDateTime = interactionSubject.EndTime;
    result.IsReminderSet = true;
    result.ReminderDateTime = result.StartDateTime.addMinutes(-15);
    return result;
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
      if (Account.SObjectType.getDescribe().isQueryable()) {
        result = new Map<Id, Account>(
          [
            SELECT Id, Name, PersonContactId
            FROM Account
            WHERE Id IN :accountIds
          ]
        );
      } else {
        CommonUtil.logAndThrowIAE(
          'ContactRequestActions',
          'getAccountMapFromInteractions',
          'Not enough permissions to query Accounts.'
        );
      }
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
      if (Lead.SObjectType.getDescribe().isQueryable()) {
        result = new Map<Id, Lead>(
          [SELECT Id, Name FROM Lead WHERE Id IN :leadIds]
        );
      } else {
        CommonUtil.logAndThrowIAE(
          'ContactRequestActions',
          'getLeadMapFromInteractions',
          'Not enough permissions to query Leads.'
        );
      }
    }
    return result;
  }

  /**
   * @description Creates Interaction Summaries from a Interactions
   * @param interactions List<Interaction> Interactions from which to create Interaction Summaries
   * @return List<InteractionSummary> the resultant Interaction Summaries
   */
  public List<InteractionSummary> createInteractionSummariesFromInteractions(
    List<Interaction> interactions
  ) {
    List<InteractionSummary> result = new List<InteractionSummary>();
    if (!interactions.isEmpty()) {
      for (Interaction currentInteraction : interactions) {
        result.add(createInteractionSummaryFromInteraction(currentInteraction));
      }
    }
    return result;
  }

  /**
   * @description Creates an Interaction Summary from an Interaction
   * @param interactionSubject Interaction Interaction from which to create an Interaction Summary
   * @return Interaction Summary the resultant Interaction Summary
   */
  public InteractionSummary createInteractionSummaryFromInteraction(
    Interaction interactionSubject
  ) {
    InteractionSummary summary = new InteractionSummary(
      Name = interactionSubject.Interaction_Purpose__c + ' Appointment Summary',
      Status = 'In Progress',
      InteractionId = interactionSubject.Id,
      AccountId = interactionSubject.AccountId,
      Meeting_Notes__c = ''
    );
    return summary;
  }

  /**
   * @description Gets the duration for the specified purpose
   * @param purpose String purpose for which to get the Duration
   * @return Integer Duration in minutes
   */
  public Integer getDuration(String purpose) {
    return AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(purpose);
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

    List<ContactRequest> contactRequests = new List<ContactRequest>();
    if (ContactRequest.SObjectType.getDescribe().isQueryable()) {
      contactRequests = [
        SELECT Id, Interaction__c
        FROM ContactRequest
        WHERE Id IN :requestIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'setInteractionIds',
        'Not enough permissions to query Contact Request.'
      );
      return;
    }
    setInteractionIds(contactRequests, interactions);

    if (ContactRequest.SObjectType.getDescribe().isUpdateable()) {
      update contactRequests;
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'setInteractionIds',
        'Not enough permissions to update Contact Request.'
      );
      return;
    }
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
}
