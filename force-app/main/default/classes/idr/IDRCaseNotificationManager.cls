/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Responsible to trigger the Notification for banker.
 * StdCyclomaticComplexity Suppressed : contains a method that uses structured if/else but complexity measure is more than limit.
 * @runTests IDRCaseNotificationManagerTest, CaseTriggerHandlerTest, IDREmailServiceTest
 *
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
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
    Task[] assiTasks = new List<Task>();

    for (Integer i = 0; i < records.size(); i++) {
      Case oldRecord = (Case) oldMap.get(records[i].Id);
      if (
        oldRecord.RecordTypeId != GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID
      ) {
        for (Schema.FieldSetMember f : fieldsList) {
          String fieldName = f.getFieldPath();
          String fieldLabel = f.getLabel();
          if (
            oldMap.containsKey(records[i].Id) &&
            records[i].get(fieldName) != oldRecord.get(fieldName) &&
            UserInfo.getUserId() != records[i].OwnerId &&
            IDRCaseActions.isIDRComplaintType(records[i])
          ) {
            if (!(fieldLabel.equalsIgnoreCase(IDRConstants.CASE_OWNER_ID))) {
              wrapperList.add(createNotification(fieldLabel, records[i], null));
            }
            assiTasks.addAll(
              createNotificationTask(fieldLabel, records[i], null)
            );
          }
        }
      }
    }

    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
    if (!assiTasks.isEmpty()) {
      //insert Assignment Tasks on New Email received or Complaint assignment
      IDRTaskActions.insertAssignmentTask(assiTasks);
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

    String customerName = (c.IDR_NC_First_Name__c != null ||
      c.IDR_NC_Last_Name__c != null)
      ? ('Customer Name : ' +
        (c.IDR_NC_First_Name__c != null ? c.IDR_NC_First_Name__c + ' ' : '') +
        (c.IDR_NC_Last_Name__c != null ? c.IDR_NC_Last_Name__c : '') +
        '\n')
      : '';
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
        customerName +
        'A new email response has been received on case : ' +
        c.CaseNumber;

      wrapper = new IDRBankerNotificationWrapper(
        c,
        new List<Id>{ c.OwnerId },
        c.CaseNumber,
        msgBody,
        null
      );
    } else {
      msgBody = fieldLabel + 'field has been changed';
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
   * @description Builds Task A new email response has been received and when A Case has been re-assigned.
   * StdCyclomaticComplexity Suppressed : This method uses structured if/else but complexity measure is more than limit.
   * @param fieldLabel Field label where the change has been detected
   * @param c case record where the  change has detected
   * @param parentCase parent case record which is attached to parentId of the above case
   * @return Task records associated with new email or new case assigned.
   */
  public static List<Task> createNotificationTask(
    String fieldLabel,
    Case c,
    Case parentCase
  ) {
    String subjectStr = null;
    Task[] assiTasks = new List<Task>();

    String caseNumber = c.CaseNumber != null ? c.CaseNumber : '';
    String customerName = (c.IDR_NC_First_Name__c != null ||
      c.IDR_NC_Last_Name__c != null)
      ? ('Customer Name : ' +
        (c.IDR_NC_First_Name__c != null ? c.IDR_NC_First_Name__c + ' ' : '') +
        (c.IDR_NC_Last_Name__c != null ? c.IDR_NC_Last_Name__c : ''))
      : '';
    Map<String, String> mpFieldLabel2Subject = new Map<String, String>{
      'Email Response Attached' => (customerName != '')
        ? ('A new email response has been received on case : ' +
          caseNumber +
          ' ' +
          customerName)
        : ('A new email response has been received on case : ' + caseNumber),
      'Email Attachment Failure' => 'Email attachment has failed to upload ' +
      caseNumber +
      ' ' +
      customerName,
      'Email has failed to upload' => 'Email has failed to upload Case: ' +
      caseNumber +
      ' ' +
      customerName
    };
    subjectStr = mpFieldLabel2Subject.get(fieldLabel);
    if ( subjectStr == null &&
        fieldLabel != 'Parent Updated' &&
        fieldLabel.equalsIgnoreCase(IDRConstants.CASE_OWNER_ID) &&
        (!(String.valueOf(c.OwnerId).startsWith('00G')))
    ) {
        subjectStr =
        'A Case has been assigned to you ' +
        caseNumber +
        ' ' +
        customerName;
    }
    if (String.isNotEmpty(subjectStr)) {
      Task assiTaskRec = IDRTaskActions.createAssignmentTask(c, subjectStr);
      if (fieldLabel == 'Email Response Attached') {
        assiTaskRec.Description = 'Any attachments included with this email will be available to view in the \'Files\' tab in CMOS';
      }
      if (
        fieldLabel == 'Email Attachment Failure' ||
        fieldLabel == 'Email has failed to upload'
      ) {
        assiTaskRec.OwnerId = c.OwnerId != null
          ? !(String.valueOf(c.OwnerId).startsWith('00G'))
              ? c.OwnerId
              : UserInfo.getUserId()
          : UserInfo.getUserId();
      }
      assiTasks.add(assiTaskRec);
    }

    return assiTasks;
  }

  /**
   * @description Returns all the fields of getFields
   * @return List<Schema.FieldSetMember> All fields in a field set
   */
  public static List<Schema.FieldSetMember> getFields() {
    return SObjectType.Case.fieldSets.IDR_Notification_Fields.getFields();
  }

  /**
   * @description To notify banker and their line manager when case is due to esclate in 1 business day
   * @param records list of case record in current trigger context
   * @param oldMap Old copy of case records before this transaction intiated
   */
  public static void notifyBankersForEscalation(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<Case> toBeEsclationCases = new List<Case>();
    Set<Id> caseOwnerIds = new Set<Id>();
    List<IDR_Notification_Event__e> notificationList = new List<IDR_Notification_Event__e>();

    for (Case record : records) {
      Case oldCase = (oldMap.containsKey(record.Id)
        ? (Case) oldMap.get(record.Id)
        : null);
      if (record.IDR_Owner_Type__c == 'User') {
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
    }
    Map<Id, User> ownerMap = new Map<Id, User>(
      [
        SELECT
          Id,
          Email,
          FirstName,
          ManagerId,
          Manager.Name,
          Manager.FirstName,
          Manager.Email
        FROM User
        WHERE Id IN :caseOwnerIds
      ]
    );
    for (Case record : toBeEsclationCases) {
      notificationList.addAll(
        buildEscalationNotificationEvent(record, ownerMap)
      );
    }
    if (notificationList.isEmpty()) {
      return;
    }
    List<Database.SaveResult> sr = EventBus.publish(notificationList);
    Logger.error('', sr);
    Logger.saveLog();
  }

  /**
   * @description Build Platform Event record with details related to banker and line manager
   * @param c Case record
   * @param ownerMap Map containing details of owner and line manager
   * @return IDR_Notification_Event__e one notification event for owner and one for his/her manager.
   */
  private static List<IDR_Notification_Event__e> buildEscalationNotificationEvent(
    Case c,
    Map<Id, User> ownerMap
  ) {
    List<IDR_Notification_Event__e> nEventList = new List<IDR_Notification_Event__e>();
    Integer timeVal = Datetime.now().millisecond();

    IDR_Notification_Event__e nEvent = new IDR_Notification_Event__e();
    nEvent.Case_ID__c = c.Id;
    nEvent.Case_Number__c = c.CaseNumber;
    nEvent.Is_Banker_Notification__c = true;
    nEvent.Case_Owner_Email__c = ownerMap.get(c.OwnerId)?.Email;
    nEvent.Case_Owner_First_Name__c = ownerMap.get(c.OwnerId)?.FirstName;
    nEvent.Line_Manager_Email__c = null;
    nEvent.Line_Manager_First_Name__c = null;
    nEvent.MessageID__c = '' + c.Id + timeVal;
    nEvent.EmailFlag__c = true;
    nEvent.EmailTemplate__c = IDRConstants.BANKER_EMAIL_NOTIFICATION_TEMPLATE;

    nEventList.add(nEvent);

    IDR_Notification_Event__e managerEvent = new IDR_Notification_Event__e();
    managerEvent.Case_ID__c = c.Id;
    managerEvent.Case_Number__c = c.CaseNumber;
    managerEvent.Is_Banker_Notification__c = true;
    managerEvent.Case_Owner_Email__c = ownerMap.get(c.OwnerId)?.Email;
    managerEvent.Case_Owner_First_Name__c = ownerMap.get(c.OwnerId)?.FirstName;
    if (ownerMap.get(c.OwnerId)?.ManagerId != null) {
      managerEvent.Line_Manager_Email__c = ownerMap.get(c.OwnerId)
        .Manager.Email;
      managerEvent.Line_Manager_First_Name__c = ownerMap.get(c.OwnerId)
        .Manager.FirstName;
    } else {
      managerEvent.Line_Manager_Email__c = null;
      managerEvent.Line_Manager_First_Name__c = null;
    }
    timeVal++;
    managerEvent.MessageID__c = '' + c.Id + timeVal;
    managerEvent.EmailFlag__c = true;
    managerEvent.EmailTemplate__c = IDRConstants.MANAGER_EMAIL_NOTIFICATION_TEMPLATE;

    nEventList.add(managerEvent);

    return nEventList;
  }
}
