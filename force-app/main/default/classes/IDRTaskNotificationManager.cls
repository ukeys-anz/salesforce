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
      wrapperList.add(
        createNotification(
          pendCaseTaskWrapper.caseRecord,
          pendCaseTaskWrapper.taskRecord,
          pendCaseTaskWrapper.daysBetweenTaskDueDate
        )
      );
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
        'Your task ' +
        t.Subject +
        ' for complaint ' +
        c.CaseNumber +
        ' is due in tomorrow';
    } else {
      msgBody =
        'Your task ' +
        t.Subject +
        ' for complaint ' +
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
}
