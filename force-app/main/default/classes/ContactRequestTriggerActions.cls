/**
 * @author Prakash
 * @since 03/2022
 * @description  ContactRequestTriggerActions is the helper class for ContactRequestTriggerHandler class which handles
 * all the actions on the ContactRequest object.
 */

public with sharing class ContactRequestTriggerActions {
  public static final String STATUS_CANCELLED = 'Cancelled';

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

    //Get the current confirmed count from each appointment commitment record and increase the count by 1.
    List<Appointment_Commitment__c> apptCommtList = new List<Appointment_Commitment__c>();
    if (
      Appointment_Commitment__c.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Appointment_Commitment__c.fields.Confirmed__c.isAccessible()
    ) {
      for (Appointment_Commitment__c apptCommt : [
        SELECT ID, Confirmed__c
        FROM Appointment_Commitment__c
        WHERE ID IN :appointmentCommitmentIds
      ]) {
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
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'updateAppointmentCommitment',
        'Not enough permissions to query Appointment Commitment object.'
      );
    }
    if (apptCommtList.size() > 0) {
      updateAppointmentCommitment(apptCommtList);
    }
  }

  /**
   * @description Method which updates the confirmed count on the appointment commitment record
   * @param apptCommtList The list of appointment commitment records to be updated.
   */

  public static void updateAppointmentCommitment(
    List<Appointment_Commitment__c> apptCommtList
  ) {
    //Update the appointment commitment records with the updated confirmed count.

    if (
      Appointment_Commitment__c.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Appointment_Commitment__c.fields.Confirmed__c.isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.Update(apptCommtList, false);

      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        'ContactRequestTriggerActions',
        'updateConfirmedCountBug'
      );
      Boolean hasError = log.addDatabaseSaveResult(
        'Appointment_Commitment__c',
        results,
        new List<Appointment_Commitment__c>()
      );
      if (hasError) {
        //if there is an error add an entry to the application log
        log.insertLog();
      }
    } else {
      //If the user does not have permission to update the appointment commitment object log an error.
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'updateAppointmentCommitment',
        'Not enough permissions to update Appointment Commitment.'
      );
    }
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
    List<Id> interactionIdList = new List<Id>();
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

    if (
      !interactionIdList.isEmpty() &&
      Schema.sObjectType.Interaction.isQueryable()
    ) {
      for (Interaction interaction : [
        SELECT Id, Status__c
        FROM Interaction
        WHERE Id IN :interactionIdList AND Status__c != :STATUS_CANCELLED
      ]) {
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
  }

  /** @description Map the appointment commitment field values to the corresponding contact request records
   * @param crList List of new contact request records to be updated.
   * @param appointmentCommitmentMap Map of appointment commitment records related to the contact request.
   */

  public void prepopulateAppointmentCommitmentValues(
    List<ContactRequest> crList,
    Map<Id, Appointment_Commitment__c> appointmentCommitmentMap
  ) {
    if (ContactRequest.sObjectType.getDescribe().isUpdateable()) {
      for (ContactRequest contReq : crList) {
        Appointment_Commitment__c apptCommt = appointmentCommitmentMap.get(
          contReq.Appointment_Commitment__c
        );
        contReq.RequestReason = apptCommt.Type__c;
        contReq.Appointment_date_and_Time__c = apptCommt.Date_and_Time__c;
        contReq.Location__c = apptCommt.Location__c;
      }
    } else {
      //If the user does not have permission to update the contact request object log an error.
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'prepopulateAppointmentCommitmentValues',
        'Not enough permissions to update Contact Request.'
      );
    }
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
    if (
      Appointment_Commitment__c.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Appointment_Commitment__c.fields.Type__c.isAccessible() &&
      Schema.SObjectType.Appointment_Commitment__c.fields.Date_and_Time__c.isAccessible() &&
      Schema.SObjectType.Appointment_Commitment__c.fields.Location__c.isAccessible()
    ) {
      for (Appointment_Commitment__c apptCommt : [
        SELECT Id, Type__c, Date_and_Time__c, Location__c
        FROM Appointment_Commitment__c
        WHERE ID IN :apptCommtId
      ]) {
        apptCommtMap.put(apptCommt.Id, apptCommt);
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'ContactRequestActions',
        'getRelatedAppCommtDetails',
        'Not enough permissions to query Appointment Commitment object.'
      );
    }
    return apptCommtMap;
  }
}
