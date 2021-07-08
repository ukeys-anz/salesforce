public with sharing class IDRPendCaseTaskRemindersHelper {
  public static List<Case> getCasesHelper(List<Id> caseIdList) {
    if (
      Case.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.Case.fields.CaseNumber.isAccessible() &&
      Schema.SObjectType.Case.fields.OwnerId.isAccessible()
    ) {
      return IDRPendCaseTaskRemindersSelector.getCasesFromIds(caseIdList);
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'getCasesHelper',
        'Not enough permissions to query/access Case Object/Fields.'
      );
      return null;
    }
  }

  public static void sendRemindersToCaseOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRCaseNotificationManager.manageCaseNotificationForTaskReminders(
      pendCaseTaskWrapperList
    );
  }

  public static void sendRemindersToTaskOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRTaskNotificationManager.manageNotificationForTaskReminders(
      pendCaseTaskWrapperList
    );
  }

  public static List<IDRPendCaseTaskReminderWrapper> verifyIfEmailNotificationIsRequired(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    List<Id> taskOwnerIdList = new List<Id>();
    List<PermissionSetAssignment> psaForTaskOwners;
    Map<Id, User> taskOwnerMap;
    for (IDRPendCaseTaskReminderWrapper pctw : pendCaseTaskWrapperList) {
      taskOwnerIdList.add(pctw.taskRecord.OwnerId);
    }
    if (
      PermissionSetAssignment.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() &&
      Schema.SObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible()
    ) {
      psaForTaskOwners = IDRPendCaseTaskRemindersSelector.getPermissionSetAssignment(
        taskOwnerIdList,
        IDRConstants.ELIGIBLE_TASK_REMINDERS_PERMISSION_SETS
      );
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'verifyIfEmailNotificationIsRequired',
        'Not enough permissions to query/access PermissionSetAssignment Object/Fields.'
      );
      return null;
    }
    if (
      User.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.User.fields.Email.isAccessible() &&
      Schema.SObjectType.User.fields.FirstName.isAccessible()
    ) {
      taskOwnerMap = IDRPendCaseTaskRemindersSelector.getUserDetails(
        taskOwnerIdList
      );
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'verifyIfEmailNotificationIsRequired',
        'Not enough permissions to query/access User Object/Fields.'
      );
      return null;
    }
    if (psaForTaskOwners != null && taskOwnerMap != null) {
      for (IDRPendCaseTaskReminderWrapper pctw : pendCaseTaskWrapperList) {
        for (PermissionSetAssignment psa : psaForTaskOwners) {
          if (pctw.taskRecord.OwnerId == psa.AssigneeId) {
            pctw.emailNotificationRequired = true;
            pctw.taskOwnerUserRecord = taskOwnerMap.get(psa.AssigneeId);
          }
        }
      }
    }

    return pendCaseTaskWrapperList;
  }

  public static void sendEmailNotification(
    List<IDRPendCaseTaskReminderWrapper> verifiedPendCaseTaskWrapperList,
    String whichNotification
  ) {
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    for (
      IDRPendCaseTaskReminderWrapper pctw : verifiedPendCaseTaskWrapperList
    ) {
      if (
        pctw.emailNotificationRequired &&
        pctw.daysBetweenTaskDueDate == 1 &&
        whichNotification == 'Task Reminder'
      ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(pctw.taskOwnerUserRecord.Email);
        mail.setToAddresses(sendTo);
        mail.setSubject('Your task is due by tomorrow');
        String body = 'Dear ' + pctw.taskOwnerUserRecord.FirstName + ', ';
        body +=
          'Your task ' +
          pctw.taskRecord.Subject +
          ' for complaint ' +
          pctw.caseRecord.CaseNumber +
          ' ';
        body += 'is due in tomorrow. ';
        body += 'Thanks, CMOS Team';
        mail.setHtmlBody(body);
        mails.add(mail);
      } else if (
        pctw.emailNotificationRequired && whichNotification == 'Task Assignment'
      ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(pctw.taskOwnerUserRecord.Email);
        mail.setToAddresses(sendTo);
        mail.setSubject('A new task is assigned to you');
        String body = 'Dear ' + pctw.taskOwnerUserRecord.FirstName + ', ';
        body +=
          'A new task ' +
          pctw.taskRecord.Subject +
          ' for complaint ' +
          pctw.caseRecord.CaseNumber +
          ' ';
        body += 'is assigned to you. ';
        body += 'Thanks, CMOS Team';
        mail.setHtmlBody(body);
        mails.add(mail);
      }
    }
    Messaging.sendEmail(mails);
  }
}
