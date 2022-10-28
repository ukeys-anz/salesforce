/**
 * @author Prakash
 * @since 03/2022
 * @description  ContactRequestTriggerActions is the helper class for ContactRequestTriggerHandler class which handles
 * all the actions on the ContactRequest object.
 */
public with sharing class ContactRequestTriggerActions {
  public static final String STATUS_CANCELLED = 'Cancelled';
  private static final String MISSING_APPT_DATE_ERROR = 'Please select a date for the Contact Request';

  /**
   * @description Method which updates the confirmed count on the appointment commitment record
   * when a new Contact request record is created. The appointment commitment is
   * associated with the contact request record.
   * @param records The list of newly created contact request records.
   * @param apptBooked Boolean parameter to indicate if its appointment booking or cancellation
   */
  public static void updateConfirmedCount(
    List<ContactRequest> records,
    Boolean apptBooked
  ) {
    Map<Id, Integer> confirmCountMap = getConfirmationMap(records);

    Set<Id> appointmentCommitmentIds = confirmCountMap.keySet();

    if (Appointment_Commitment__c.sObjectType.getDescribe().isQueryable()) {
      List<Appointment_Commitment__c> appointmentCommitments = [
        SELECT ID, Confirmed__c, Available__c
        FROM Appointment_Commitment__c
        WHERE ID IN :appointmentCommitmentIds
      ];

      //Get the current confirmed count from each appointment commitment record and increase the count by 1.
      List<Appointment_Commitment__c> apptCommtList = getAppointmentCommitmentUpdates(
        appointmentCommitments,
        confirmCountMap,
        apptBooked
      );
      if (apptCommtList.size() > 0) {
        AppointmentCommitmentDMLHelper.updateAppointmentCommitment(
          apptCommtList
        );
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestTriggerActions',
        'updateAppointmentCommitment',
        'Not enough permissions to query Appointment Commitment object.'
      );
    }
  }

  private static Map<Id, Integer> getConfirmationMap(
    List<ContactRequest> records
  ) {
    Set<Id> appointmentCommitmentIds = new Set<Id>();
    Map<Id, Integer> confirmCountMap = new Map<Id, Integer>();

    //Get the list of all appointment commitment records where the confirmed count should be updated.
    for (ContactRequest contReq : records) {
      appointmentCommitmentIds.add(contReq.Appointment_Commitment__c);
      Integer tempCount = 0;
      if (confirmCountMap.containsKey(contReq.Appointment_Commitment__c)) {
        tempCount = confirmCountmap.get(contReq.Appointment_Commitment__c);
      }
      confirmCountMap.put(contReq.Appointment_Commitment__c, tempCount + 1);
    }

    return confirmCountMap;
  }

  private static List<Appointment_Commitment__c> getAppointmentCommitmentUpdates(
    List<Appointment_Commitment__c> appointmentCommitments,
    Map<Id, Integer> confirmCountMap,
    Boolean apptBooked
  ) {
    List<Appointment_Commitment__c> apptCommtList = new List<Appointment_Commitment__c>();

    for (Appointment_Commitment__c apptCommt : appointmentCommitments) {
      if (apptBooked) {
        apptCommt.Confirmed__c = apptCommt.Confirmed__c == null
          ? 1
          : apptCommt.Confirmed__c + confirmCountMap.get(apptCommt.Id);
      } else {
        apptCommt.Confirmed__c =
          apptCommt.Confirmed__c - confirmCountMap.get(apptCommt.Id);
      }
      apptCommtList.add(apptCommt);
    }
    return apptCommtList;
  }

  /** @description checks if record has been updated to cancelled and if so,
   * updates the associated interaction to cancelled
   * @param oldMap Map of contact requests containing original values prior to update.
   * @param records The list of updated contact request records.
   */
  public static void handleCancelledRequest(
    Map<Id, SObject> oldMap,
    List<ContactRequest> records
  ) {
    Set<Id> interactionIdList = new Set<Id>();
    List<Interaction> interactionCancelList = new List<Interaction>();

    //Loop through contact requests and get records updated to cancel
    for (ContactRequest contactReq : records) {
      ContactRequest oldRecord = (ContactRequest) oldMap.get(contactReq.id);
      if (
        oldRecord.Status != STATUS_CANCELLED &&
        contactReq.Status == STATUS_CANCELLED
      ) {
        //Add interactions to cancel to list
        interactionIdList.add(contactReq.Interaction__c);
      }
    }

    List<Interaction> notCancelledInteractions = InteractionGetters.getCancelledInteractions(
      interactionIdList
    );

    for (Interaction interaction : notCancelledInteractions) {
      interaction.Status__c = STATUS_CANCELLED;
      interactionCancelList.add(interaction);
    }

    //Update interactions to cancelled
    if (
      !interactionCancelList.isEmpty() &&
      Interaction.sObjectType.getDescribe().isUpdateable()
    ) {
      update interactionCancelList;
    }
  }

  /** @description Map the appointment commitment field values to the corresponding contact request records
   * @param crList List of new contact request records to be updated.
   * @param appointmentCommitmentMap Map of appointment commitment records related to the contact request.
   * @return returns the Contact Requests that can be created
   */
  public List<ContactRequest> prepopulateAppointmentCommitmentValues(
    List<ContactRequest> crList,
    Map<Id, Appointment_Commitment__c> appointmentCommitmentMap
  ) {
    List<ContactRequest> goodRequests = new List<ContactRequest>();
    for (ContactRequest contReq : crList) {
      if (
        appointmentCommitmentMap.containsKey(contReq.Appointment_Commitment__c)
      ) {
        Appointment_Commitment__c apptCommt = appointmentCommitmentMap.get(
          contReq.Appointment_Commitment__c
        );
        if (apptCommt.Available__c == apptCommt.Confirmed__c) {
          contReq.addError(System.Label.Appointment_Commitment_Full);
        } else {
          contReq.RequestReason = apptCommt.Type__c;
          contReq.Appointment_date_and_Time__c = apptCommt.Date_and_Time__c;
          contReq.Location__c = apptCommt.Location__c;
          contReq.PreferredChannel = apptCommt.Appointment_Channel__c;
          goodRequests.add(contReq);
        }
      } else {
        goodRequests.add(contReq);
      }
    }
    return goodRequests;
  }

  /** @description Map the appointment commitment field values to the corresponding contact request records
   * @param crList List of new contact request records to be updated.
   * @return Map<Id, Appointment_Commitment__c> Map of appointment commitment records related to the contact request.
   */

  public Map<Id, Appointment_Commitment__c> getRelatedAppCommtDetails(
    List<ContactRequest> crList
  ) {
    Set<Id> apptCommtId = new Set<Id>();
    Map<Id, Appointment_Commitment__c> apptCommtMap = new Map<Id, Appointment_Commitment__c>();
    for (ContactRequest cr : crList) {
      if (cr.Appointment_Commitment__c != null) {
        apptCommtId.add(cr.Appointment_Commitment__c);
      }
    }
    if (Appointment_Commitment__c.SObjectType.getDescribe().isAccessible()) {
      apptCommtMap = new Map<Id, Appointment_Commitment__c>(
        [
          SELECT
            Id,
            Type__c,
            Date_and_Time__c,
            Location__c,
            Appointment_Channel__c,
            Available__c,
            Confirmed__c
          FROM Appointment_Commitment__c
          WHERE ID IN :apptCommtId
        ]
      );
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'getRelatedAppCommtDetails',
        'Not enough permissions to query Appointment Commitment object.'
      );
    }
    return apptCommtMap;
  }

  /**
   * @description goes through a list of ContactRequests and adds an error if any
   * have a channel of store, but no location
   * @param requests List<ContactRequest> to search through for offenders.
   */
  public void validateContactRequests(List<ContactRequest> requests) {
    ContactRequestActions actions = new ContactRequestActions();
    Map<Id, Account> accountMap = actions.getWhoIdAccountMap(requests);

    List<Interaction> interactions = InteractionGetters.getInteractionsForLeadsAndContacts(
      extractWhoIds(requests, accountMap)
    );
    for (ContactRequest currentRequest : requests) {
      if (currentRequest.Appointment_date_and_Time__c == null) {
        currentRequest.addError(MISSING_APPT_DATE_ERROR);
        continue;
      }
      Id requestId = currentRequest.WhoId;
      if (accountMap.containsKey(currentRequest.WhoId)) {
        requestId = accountMap.get(currentRequest.WhoId).Id;
      }

      validateStore(currentRequest);
      //if interaction at same time add error
      for (Interaction currentInteraction : interactions) {
        Integer duration = AutomatedRequestMetadataProvider.getInstance()
          .getPurposeDuration(currentRequest.RequestReason);

        if (
          // need to also check that it is of a relevant account/lead
          (currentInteraction.AccountId == requestId ||
          currentInteraction.Lead__c == requestId) &&
          Lib_SystemLog.doPeriodsIntersect(
            currentInteraction.StartTime,
            currentInteraction.EndTime,
            currentRequest.Appointment_date_and_Time__c,
            currentRequest.Appointment_date_and_Time__c.addMinutes(duration)
          )
        ) {
          currentRequest.addError(
            System.Label.Interaction_User_Created_Error_Message +
            currentInteraction.Interaction_External_Id__c
          );
        }
      }
    }
  }

  /**
   * @description Validates if the ContactRequest is at a store but has no store assigned
   * @param currentRequest request to check
   */
  private void validateStore(ContactRequest currentRequest) {
    if (
      currentRequest.PreferredChannel == 'Store' &&
      currentRequest.Location__c == null
    ) {
      currentRequest.addError(System.Label.Interaction_Store_Required);
    }
  }

  /**
   * @description extracts whoIds from a list of Contact Requests
   * @param requests List of Requests
   * @param accountMap Map of Accounts
   * @return Set of WhoIds
   */
  private Set<Id> extractWhoIds(
    List<ContactRequest> requests,
    Map<Id, Account> accountMap
  ) {
    Set<Id> whoIds = new Set<Id>();
    for (ContactRequest currentRequest : requests) {
      if (accountMap.containsKey(currentRequest.WhoId)) {
        whoIds.add(accountMap.get(currentRequest.WhoId).Id);
      } else {
        whoIds.add(currentRequest.WhoId);
      }
    }
    return whoIds;
  }
}
