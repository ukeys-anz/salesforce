/**
 * @author Prakash
 * @since 03/2022
 * @description  ContactRequestTriggerActions is the helper class for ContactRequestTriggerHandler class which handles
 * all the actions on the ContactRequest object.
 */
public with sharing class ContactRequestTriggerActions {
  /**
   * @description Method which updates the confirmed count on the appointment commitment record
   * when a new Contact request record is created. The appointment commitment is
   * associated with the contact request record.
   * @param records The list of newly created contact request records.
   */
  public static void updateConfirmedCount(List<ContactRequest> records) {
    Set<Id> appointmentCommitmentIds = new Set<Id>();

    //Get the list of all appointment commitment records where the confirmed count should be increased by 1.
    for (ContactRequest contReq : records) {
      appointmentCommitmentIds.add(contReq.Appointment_Commitment__c);
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
        apptCommt.Confirmed__c = apptCommt.Confirmed__c == null
          ? 1
          : apptCommt.Confirmed__c + 1;
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
      ContactRequestTriggerActions.updateAppointmentCommitment(apptCommtList);
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
}
