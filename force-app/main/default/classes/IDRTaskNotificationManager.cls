public with sharing class IDRTaskNotificationManager {
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
