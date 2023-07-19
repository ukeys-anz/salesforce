/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 12/2020
 * @description Responsible to create Task and trigger the Notification when another user adds a case comment
 */
public with sharing class IDRCaseCommentsNotificationManager {
  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records CaseComment records in current trigger context
   */
  public static void manageNotification(List<CaseComment> records) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();

    Map<Id, Case> caseMap = getCaseRecords(records);
    List<Case> caseUpdatedList = new List<Case>();

    for (CaseComment record : (List<CaseComment>) records) {
      Case caseRec = caseMap.get(record.ParentId);
      if (caseRec != null) {
        if (
          caseRec.OwnerId != record.CreatedById &&
          IDRCaseActions.isIDRComplaintType(caseRec)
        ) {
          if (
            (!(caseRec.Status == 'Closed' ||
            caseRec.Status == 'Withdrawn' ||
            caseRec.Status == 'Resolved')) ||
            (!((record.CommentBody).startsWith('New attachment added; ')))
          ) {
            wrapperList.add(createNotification(caseRec));
          }
        }
        if (
          (caseRec.Status == 'Closed' ||
          caseRec.Status == 'Withdrawn' ||
          caseRec.Status == 'Resolved') &&
          caseRec.IDR_Additional_Correspondence_reviewed__c == true
        ) {
          caseRec.IDR_Additional_Correspondence_reviewed__c = false;
          caseUpdatedList.add(caseRec);
        }
      }
    }

    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }

    if (!caseUpdatedlist.isEmpty()) {
      update caseUpdatedList;
    }
    manageNotificationTask(records);
  }
  /**
   * @description Assesses whether or not to Task should be created. 
   * @param records CaseComment records in current trigger context
   */
  public static void manageNotificationTask(List<CaseComment> records) {
    Map<Id, Case> caseMap = getCaseRecords(records);
    List<Case> caseUpdatedList = new List<Case>();
    Task[] assiTasks = new List<Task>();

    for (CaseComment record : (List<CaseComment>) records) {
      Case caseRec = caseMap.get(record.ParentId);
      if (caseRec != null) {
        String customerName = (caseRec.IDR_NC_First_Name__c != null ||
          caseRec.IDR_NC_Last_Name__c != null)
          ? ('Customer Name : ' +
            (caseRec.IDR_NC_First_Name__c != null
              ? caseRec.IDR_NC_First_Name__c + ' '
              : '') +
            (caseRec.IDR_NC_Last_Name__c != null
              ? caseRec.IDR_NC_Last_Name__c
              : ''))
          : '';
        String subjectStr = (customerName != '')
          ? ('New Correspondence received on a Closed Complaint added by ' +
            UserInfo.getName() +
            ' on case ' +
            caseRec.CaseNumber +
            ' ' +
            customerName)
          : ('New Correspondence received on a Closed Complaint added by ' +
            UserInfo.getName() +
            ' on case ' +
            caseRec.CaseNumber);
        if (
          caseRec.OwnerId != record.CreatedById &&
          IDRCaseActions.isIDRComplaintType(caseRec) &&
          (caseRec.Status == 'Closed' ||
          caseRec.Status == 'Withdrawn' ||
          caseRec.Status == 'Resolved')
        ) {
          Task newCorrsTask = IDRTaskActions.createAssignmentTask(
            caseRec,
            subjectStr
          );
          newCorrsTask.Description = 'You must add a task comment detailing the action taken in your review of the new correspondence received on the closed complaint before marking this task as completed';
          assiTasks.add(newCorrsTask);
        }
      }
    }
    if (!assiTasks.isEmpty()) {
      //insert Assignment Tasks on New Correspondence received on Closed Complaint
      IDRTaskActions.insertAssignmentTask(assiTasks);
    }
  }

  /**
   * @description get case record details associated with the case comments
   * @param records case comment records from the trigger
   * @return getCaseMap case map
   */
  private static Map<Id, Case> getCaseRecords(List<CaseComment> records) {
    Set<Id> caseIds = new Set<Id>();
    Map<Id, Case> getCaseMap = new Map<Id, Case>();

    for (CaseComment record : (List<CaseComment>) records) {
      caseIds.add(record.ParentId);
    }

    for (Case c : [
      SELECT
        Id,
        RecordTypeId,
        CaseNumber,
        OwnerId,
        Status,
        IDR_Additional_Correspondence_reviewed__c,
        IDR_NC_First_Name__c,
        IDR_NC_Last_Name__c
      FROM Case
      WHERE Id IN :caseIds AND Owner.isActive = TRUE
    ]) {
      getCaseMap.put(c.Id, c);
    }
    return getCaseMap;
  }

  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param record case record from the trigger
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  private static IDRBankerNotificationWrapper createNotification(Case record) {
    String customerName = (record.IDR_NC_First_Name__c != null ||
      record.IDR_NC_Last_Name__c != null)
      ? ('Customer Name : ' +
        (record.IDR_NC_First_Name__c != null
          ? record.IDR_NC_First_Name__c + ' '
          : '') +
        (record.IDR_NC_Last_Name__c != null ? record.IDR_NC_Last_Name__c : '') +
        '\n')
      : '';
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      record,
      new List<Id>{ record.OwnerId },
      record.CaseNumber,
      customerName + 'New Case Comment added by ' + UserInfo.getName(),
      record
    );

    return wrapper;
  }
}
