/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Responsible to trigger the Notification for banker.
 */
public with sharing class IDRCaseNotificationManager {
  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records Case records in current trigger context
   * @param oldMap Old values of the cases in current context
   */
  public static void manageNotification(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
    List<Schema.FieldSetMember> fieldsList = getFields();

    for (Integer i = 0; i < records.size(); i++) {
      for (Schema.FieldSetMember f : fieldsList) {
        String fieldName = f.getFieldPath();
        String fieldLabel = f.getLabel();
        if (
          oldMap.containsKey(records[i].Id) &&
          records[i].get(fieldName) !=
          oldMap.get(records[i].Id).get(fieldName) &&
          Userinfo.getUserId() != records[i].ownerId
        ) {
          wrapperList.add(createNotification(fieldLabel, records[i]));
        }
      }
    }

    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
  }

  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param fieldLabel Field label where the change has been detected
   * @param c case record where the  change has detected
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  public static IDRBankerNotificationWrapper createNotification(
    String fieldLabel,
    Case c
  ) {
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper();
    wrapper.sfObject = c;
    wrapper.msgTitle = c.CaseNumber;
    wrapper.msgBody = fieldLabel + 'field has been changed';

    if (fieldLabel.equalsIgnoreCase(IDRConstants.CASE_OWNER_ID)) {
      wrapper.msgBody = 'Case ' + c.CaseNumber + ' has been assigned to you';
    }

    if (
      fieldLabel.equalsIgnoreCase(IDRConstants.MILESTONE_SLA_FIELD_LABEL) &&
      c.Status != IDRConstants.ESCALATED_STATUS
    ) {
      wrapper.msgBody = 'Auto esclation is due in ' + c.IDR_Milestone_Sla__c;
    }

    wrapper.relatedCaseRecord = c;
    wrapper.recipientList = new List<Id>{ c.OwnerId };
    return wrapper;
  }

  /**
   * @description Returns all the fields of getFields
   * @return List<Schema.FieldSetMember> All fields in a field set
   */
  public static List<Schema.FieldSetMember> getFields() {
    return SObjectType.Case.FieldSets.IDR_Notification_Fields.getFields();
  }
}
