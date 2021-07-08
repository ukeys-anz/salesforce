public with sharing class IDRPendCaseTaskRemindersHandler {
  public static List<IDRPendCaseTaskReminderWrapper> createWrapper(
    List<Task> taskList
  ) {
    List<Id> caseIdList = new List<Id>();
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList = new List<IDRPendCaseTaskReminderWrapper>();
    List<String> windowForTaskReminders = Label.IDR_Window_For_Task_Reminders.split(
      ','
    );
    for (Task t : taskList) {
      IDRPendCaseTaskReminderWrapper pendCaseTaskWrapper = new IDRPendCaseTaskReminderWrapper();
      Integer daysBetweenTaskDueDate = Date.today().daysBetween(t.ActivityDate);
      Boolean isDueDateWithinWindow = windowForTaskReminders.contains(
          String.valueOf(Date.today().daysBetween(t.ActivityDate))
        )
        ? true
        : false;
      if (isDueDateWithinWindow) {
        caseIdList.add(t.WhatId);
        pendCaseTaskWrapper.taskId = t.Id;
        pendCaseTaskWrapper.caseId = t.WhatId;
        pendCaseTaskWrapper.taskRecord = t;
        pendCaseTaskWrapper.daysBetweenTaskDueDate = daysBetweenTaskDueDate;
        pendCaseTaskWrapperList.add(pendCaseTaskWrapper);
      }
    }
    List<Case> caseListForReminders = IDRPendCaseTaskRemindersHelper.getCasesHelper(
      caseIdList
    );
    for (IDRPendCaseTaskReminderWrapper pctw : pendCaseTaskWrapperList) {
      for (Case c : caseListForReminders) {
        if (pctw.caseId == c.Id) {
          pctw.caseRecord = c;
        }
      }
    }

    return pendCaseTaskWrapperList;
  }

  public static void sendInAppNotificationToTaskOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRPendCaseTaskRemindersHelper.sendRemindersToTaskOwners(
      pendCaseTaskWrapperList
    );
  }

  public static void sendInAppNotificationToCaseOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRPendCaseTaskRemindersHelper.sendRemindersToCaseOwners(
      pendCaseTaskWrapperList
    );
  }

  public static void sendEmailNotificationToTaskOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList,
    String whichNotification
  ) {
    List<IDRPendCaseTaskReminderWrapper> verifiedPendCaseTaskWrapperList = IDRPendCaseTaskRemindersHelper.verifyIfEmailNotificationIsRequired(
      pendCaseTaskWrapperList
    );
    IDRPendCaseTaskRemindersHelper.sendEmailNotification(
      verifiedPendCaseTaskWrapperList,
      whichNotification
    );
  }

  public static void taskCreationNotificationToCaseOwners(List<Task> taskList) {
    List<Id> caseIdList = new List<Id>();
    for (Task t : taskList) {
      caseIdList.add(t.WhatId);
    }
    List<Case> caseListForNotification = IDRPendCaseTaskRemindersHelper.getCasesHelper(
      caseIdList
    );
    IDRCaseNotificationManager.manageCaseNotificationForTaskCreation(
      caseListForNotification
    );
  }
}
