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

    if (
      !caseWithParentId.isEmpty() &&
      Case.sObjectType.getDescribe().isQueryable()
    ) {
      Map<Id, Case> parentIdWithCaseMap = new Map<Id, Case>();
      for (Case c : [
        SELECT id, Origin, CaseNumber
        FROM Case
        WHERE id IN :caseWithParentId.values()
      ]) {
        parentIdWithCaseMap.put(c.id, c);
      }

      for (Case c : records) {
        Case parentCase = parentIdWithCaseMap.get(c.ParentId);
        wrapperList.add(createNotification('Parent Updated', c, parentCase));
      }

      //Send Notification
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
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
    } else if (fieldLabel == 'Email Response Attached') {
      msgBody =
        'A new email response has been received on case : ' + c.CaseNumber;
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

  /**
   * @description To notify banker and their line manager when case is due to esclate in 1 business day
   * @param records list of case record in current trigger context
   * @param oldMap Old copy of case records before this transaction intiated
   */
  public static void notifyBankersForEscalation(
    List<Case> records,
    Map<Id, Sobject> oldMap
  ) {
    List<Case> toBeEsclationCases = new List<Case>();
    Set<Id> caseOwnerIds = new Set<Id>();
    Set<Id> caseOwnersManagerIds = new Set<Id>();
    List<IDR_Notification_Event__e> notificationList = new List<IDR_Notification_Event__e>();

    for (Case record : records) {
      Case oldCase = (oldMap.containsKey(record.Id)
        ? (Case) oldMap.get(record.Id)
        : null);
      if (
        oldCase != null &&
        oldCase.IDR_Milestone_Sla__c != record.IDR_Milestone_Sla__c &&
        record.IDR_Milestone_Sla__c == IDRConstants.MILESTONE_SLA_RED &&
        record.IsEscalated == false
      ) {
        toBeEsclationCases.add(record);
        caseOwnerIds.add(record.OwnerId);
      }
    }
    Map<Id, User> ownerMap = new Map<Id, User>(
      [
        SELECT
          Id,
          Email,
          FirstName,
          Manager.Name,
          Manager.FirstName,
          Manager.Email
        FROM User
        WHERE Id IN :caseOwnerIds
      ]
    );
    for (Case record : toBeEsclationCases) {
      notificationList.add(buildEscalationNotificationEvent(record, ownerMap));
    }
    List<Database.SaveResult> sr = EventBus.publish(notificationList);

    Lib_SystemLog log = new Lib_SystemLog(
      IDRCaseActions.class.getName(),
      'notifyBankersForEscalation'
    );
    log.addDatabaseSaveResult(
      'IDR_Notification_Event__e',
      sr,
      notificationList
    );
    log.insertLogAsync();
  }

  /**
   * @description Build Platform Event record with details related to banker and line manager
   * @param c Case record
   * @param ownerMap Map containing details of owner and line manager
   * @return IDR_Notification_Event__e notification event
   */
  private static IDR_Notification_Event__e buildEscalationNotificationEvent(
    Case c,
    Map<Id, User> ownerMap
  ) {
    IDR_Notification_Event__e nEvent = new IDR_Notification_Event__e();
    nEvent.Case_ID__c = c.Id;
    nEvent.Case_Number__c = c.CaseNumber;
    nEvent.Is_Banker_Notification__c = true;
    nEvent.Case_Owner_Email__c = ownerMap.get(c.OwnerId).Email;
    nEvent.Case_Owner_First_Name__c = ownerMap.get(c.OwnerId).FirstName;
    nEvent.Line_Manager_Email__c = ownerMap.get(c.OwnerId).Manager.Email;
    nEvent.Line_Manager_First_Name__c = ownerMap.get(c.OwnerId)
      .Manager.FirstName;
    nEvent.MessageID__c = '' + c.ID + Datetime.now().millisecond();
    nEvent.EmailFlag__c = true;
    nEvent.EmailTemplate__c = IDRConstants.BANKER_EMAIL_NOTIFICATION_TEMPLATE;

    return nEvent;
  }
}
