/**
 * @author Adam Phillip Smith
 * @since 20220627
 * @description  Helper for DML operations on the Appointment Commitment Object
 */
public with sharing class AppointmentCommitmentDMLHelper {
  /**
   * @description Method which updates the confirmed count on the appointment commitment record
   * @param apptCommtList The list of appointment commitment records to be updated.
   */

  public static void updateAppointmentCommitment(
    List<Appointment_Commitment__c> apptCommtList
  ) {
    //Update the appointment commitment records with the updated confirmed count.

    if (Appointment_Commitment__c.sObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(apptCommtList, false);
      Logger.error('', results);
      Logger.saveLog();
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
