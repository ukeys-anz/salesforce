/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Responsible to trigger the Notification for banker.
 *
 */
public with sharing class IDRCaseNotificationManager {
  /**
   * @description Assesses whether or not to generate a banker notification for AfterUpdate scenario
   * @param records Case records in current trigger context
   * @param oldMap Old values of the cases in current context
   */
  public static void manageNotificationAfterUpdate(
    List<Case> records,
    Map<Id, Case> oldMap
  ) {
    List<Case> parentCases = new List<Case>();
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
    Map<Id, Id> caseWithParentId = new Map<Id, Id>();
    Map<Id, Case> newMapWithCase = new Map<Id, Case>();
    for (Case c : records) {
      newMapWithCase.put(c.id, c);
      if (
        oldMap.get(c.Id).ParentId != c.ParentId &&
        c.Status != 'Closed' &&
        c.RecordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID
      ) {
        caseWithParentId.put(c.id, c.ParentId);
      }
    }

    if (!caseWithParentId.isEmpty()) {
      if (Case.sObjectType.getDescribe().isQueryable()) {
        parentCases = [
          SELECT id, Origin, CaseNumber
          FROM Case
          WHERE id IN :caseWithParentId.values()
        ];
      }
      Map<Id, Case> parentIdWithCaseMap = new Map<Id, Case>();
      for (Case c : parentCases) {
        parentIdWithCaseMap.put(c.id, c);
      }

      for (Case c : records) {
        Case parentCase = parentIdWithCaseMap.get(c.ParentId);
        wrapperList.add(createNotification('Parent Updated', c, parentCase));
      }

      if (!wrapperList.isEmpty()) {
        IDRBankerNotificationBuilder.sendNotification(wrapperList);
      }
    }
  }

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
          Userinfo.getUserId() != records[i].ownerId &&
          IDRCaseActions.isIDRComplaintType(records[i])
        ) {
          //Set notification flag to true in here itself to avoid update in IDRBankerNotificationBuilder
          records[i].IDR_Update_Notification_Flag__c = true;
          wrapperList.add(createNotification(fieldLabel, records[i], null));
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
   * @param parentCase parent case record which is attached to parentId of the above case
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  public static IDRBankerNotificationWrapper createNotification(
    String fieldLabel,
    Case c,
    Case parentCase
  ) {
    IDRBankerNotificationWrapper wrapper;
    String msgBody;
    if (fieldLabel == 'Parent Updated') {
      msgBody =
        'Your case ' +
        c.CaseNumber +
        ' has been linked as a related complaint to ' +
        parentCase.CaseNumber;
      wrapper = new IDRBankerNotificationWrapper(
        c,
        new List<Id>{ c.OwnerId },
        c.CaseNumber,
        msgBody,
        null
      );
    } else {
      msgBody = fieldLabel + 'field has been changed';
      if (fieldLabel.equalsIgnoreCase(IDRConstants.CASE_OWNER_ID)) {
        msgBody = 'Case ' + c.CaseNumber + ' has been assigned to you';
      }
      if (
        fieldLabel.equalsIgnoreCase(IDRConstants.MILESTONE_SLA_FIELD_LABEL) &&
        c.Status != IDRConstants.ESCALATED_STATUS
      ) {
        msgBody = 'Auto esclation is due in ' + c.IDR_Milestone_Sla__c;
      }

      wrapper = new IDRBankerNotificationWrapper(
        c,
        new List<Id>{ c.OwnerId },
        c.CaseNumber,
        msgBody,
        c
      );
    }

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
