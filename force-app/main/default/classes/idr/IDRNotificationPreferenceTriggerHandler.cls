/**
 *
 * @author Afreen
 * @since 11/2020
 * @description handler class for the Notification Preference trigger
 */
public with sharing class IDRNotificationPreferenceTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   */
  public IDRNotificationPreferenceTriggerHandler() {
    super();
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   * @param records list of  IDR_Notification_Preference__c in current trigger context
   */
  public override void onApplyDefaults() {
    populateUserID((List<IDR_Notification_Preference__c>) records);
  }

  /**
   * @description Populating the User Id with Owner id to restrict the user to create multiple records for themselves.
   */
  public void populateUserID(
    List<IDR_Notification_Preference__c> preferenceList
  ) {
    for (IDR_Notification_Preference__c record : preferenceList) {
      record.User_Id__c = record.OwnerId;
    }
  }
}
