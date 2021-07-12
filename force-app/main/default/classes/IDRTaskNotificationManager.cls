/**
 * @author Adnan
 * @since  09/2021
 * @description Responsible for creating and sending task notifications.
 */
public with sharing class IDRTaskNotificationManager {
  /**
   * @description Assesses whether or not to generate a task notification for various scenarios
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   */
  public static void manageNotificationForTaskReminders(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
    for (
      IDRPendCaseTaskReminderWrapper pendCaseTaskWrapper : pendCaseTaskWrapperList
    ) {
      if (pendCaseTaskWrapper.notifyOwner == true) {
        wrapperList.add(
          createNotification(
            pendCaseTaskWrapper.caseRecord,
            pendCaseTaskWrapper.taskRecord,
            pendCaseTaskWrapper.daysBetweenTaskDueDate
          )
        );
      }
      if (pendCaseTaskWrapper.notifyManager == true) {
        wrapperList.add(createNotificationForManagers(pendCaseTaskWrapper));
      }
    }

    IDRBankerNotificationBuilder.sendNotification(wrapperList);
  }

  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param c the case record
   * @param t the task record
   * @param daysRemainingFromDue no of days between task due date and today
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  public static IDRBankerNotificationWrapper createNotification(
    Case c,
    Task t,
    Integer daysRemainingFromDue
  ) {
    String msgBody;
    if (daysRemainingFromDue == 1) {
      msgBody =
        'Your task \'' +
        t.Subject +
        '\' for complaint ' +
        c.CaseNumber +
        ' is due in tomorrow';
    } else {
      msgBody =
        'Your task \'' +
        t.Subject +
        '\' for complaint ' +
        c.CaseNumber +
        ' is due in ' +
        daysRemainingFromDue +
        ' days';
    }
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      t,
      new List<Id>{ t.OwnerId },
      t.Subject,
      msgBody,
      null
    );
    return wrapper;
  }

  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class for case owners manager
   * @param pctw IDRPendCaseTaskReminderWrapper wrapper record
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  public static IDRBankerNotificationWrapper createNotificationForManagers(
    IDRPendCaseTaskReminderWrapper pctw
  ) {
    String msgBody;
    if (pctw.daysBetweenTaskDueDate == 1) {
      msgBody =
        'Task \'' +
        pctw.taskRecord.Subject +
        '\' for comaplaint ' +
        pctw.caseRecord.CaseNumber +
        ' is due by tomorrow by your subordinate - ' +
        pctw.caseOwnerUserRecord.FirstName;
    } else {
      msgBody =
        'Task \'' +
        pctw.taskRecord.Subject +
        '\' for complaint ' +
        pctw.caseRecord.CaseNumber +
        ' is overdue by your subordinate - ' +
        pctw.caseOwnerUserRecord.FirstName;
    }
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      pctw.taskRecord,
      new List<Id>{ pctw.caseOwnerUserRecord.ManagerId },
      pctw.taskRecord.Subject,
      msgBody,
      null
    );
    return wrapper;
  }
}
