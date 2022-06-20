/**
 * @author Adam Smith
 * @since 20220324
 * @description class for Automating object creation from accepting a Contact Request
 */
public with sharing class ContactRequestActions {
  //local variable holding the Appointment Queue
  private Group localAppointmentQueue;

  /**
   * @description lazy loads the appointment queue and stores in a local variable to save on database calls.
   */
  private Group appointmentQueue {
    get {
      if (localAppointmentQueue == null) {
        localAppointmentQueue = CommonUtil.getQueueByName(
          InteractionConstants.APPOINTMENTS_QUEUE
        );
      }
      return localAppointmentQueue;
    }
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
   * @description creates interactions from a list of requests
   * @param requests List<ContactRequest> requests for which to create Interactions
   * @return List<Interaction> newly created interactions.
   */
  public List<Interaction> createInteractionsFromRequests(
    List<ContactRequest> requests
  ) {
    Map<Id, Account> contactAccountMap = getWhoIdAccountMap(requests);
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
    Map<Id, Account> contactAccountMap = getWhoIdAccountMap(
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
    Map<Id, Account> contactAccountMap
  ) {
    if (request.Appointment_date_and_Time__c == null) {
      request.addError(
        'You must select an Appointment Date and Time before accepting the request'
      );
      return null;
    }
    Integer duration = getDuration(request.RequestReason);
    Account interactionAccount;
    if (contactAccountMap.containsKey(request.WhoId)) {
      interactionAccount = contactAccountMap.get(request.WhoId);
    }
    Id leadId = null;
    if (interactionAccount == null) {
      leadId = request.WhoId;
    }

    Id appointmentRecordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByName()
      .get(InteractionConstants.APPOINTMENT_RECORD_TYPE_NAME)
      .getRecordTypeId();

    string defaultInteractionStatus = InteractionConstants.UNASSIGNED_STATUS;
    Interaction newInteraction = new Interaction(
      Status__c = defaultInteractionStatus,
      Interaction_Purpose__c = request.RequestReason,
      StartTime = request.Appointment_date_and_Time__c,
      AccountId = interactionAccount?.Id,
      Lead__c = leadId,
      Name = request.RequestReason + ' Appointment',
      EndTime = request.Appointment_date_and_Time__c.addMinutes(duration),
      Description = request.RequestDescription,
      Direction__c = getDirection(request.PreferredChannel),
      ContactRequestId__c = request.Id,
      OwnerId = appointmentQueue.Id,
      InteractionType = request.PreferredChannel,
      Channel_Booked__c = request.Channel_Booked__c,
      RecordTypeId = appointmentRecordTypeId,
      Interaction_External_Id__c = 'CR-' + request.Name,
      LocationId = request.Location__c,
      Optional_Notes__c = request.RequestDescription,
      Contact_Mobile__c = interactionAccount?.PersonMobilePhone
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
   * @description goes through a list of ContactRequests and returns a map
   * of ContactId to AccountId based on the WhoId
   * @param requests List<ContactRequest> requests to search through
   * @return Map<Id,Account> map of ContactId to related Account
   */
  public Map<Id, Account> getWhoIdAccountMap(List<ContactRequest> requests) {
    Map<Id, Account> results = new Map<Id, Account>();

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
        SELECT Id, PersonContactId, PersonMobilePhone
        FROM Account
        WHERE PersonContactId IN :whoIds
      ];

      if (!personAccounts.isEmpty()) {
        for (Account personAccount : personAccounts) {
          results.put(personAccount.PersonContactId, personAccount);
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
   * @description Gets the duration for the specified purpose
   * @param purpose String purpose for which to get the Duration
   * @return Integer Duration in minutes
   */
  public Integer getDuration(String purpose) {
    return AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(purpose);
  }
}
