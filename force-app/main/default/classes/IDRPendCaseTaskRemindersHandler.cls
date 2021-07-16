/**
 * @author Adnan
 * @since  09/2021
 * @description Handler class for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersHandler {
  /**
   * @description method for creating wrapper to send notifications
   * @param taskList list of task records that are used for creating wrapper
   * @return List<IDRPendCaseTaskReminderWrapper> returns the created wrapper
   */
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
          String.valueOf(daysBetweenTaskDueDate)
        )
        ? true
        : false;
      if (isDueDateWithinWindow) {
        caseIdList.add(t.WhatId);
        pendCaseTaskWrapper.taskId = t.Id;
        pendCaseTaskWrapper.caseId = t.WhatId;
        pendCaseTaskWrapper.taskRecord = t;
        pendCaseTaskWrapper.daysBetweenTaskDueDate = daysBetweenTaskDueDate;
        pendCaseTaskWrapper.notifyOwner = true;
        pendCaseTaskWrapper.notifyManager = daysBetweenTaskDueDate == 1
          ? true
          : false;
        pendCaseTaskWrapperList.add(pendCaseTaskWrapper);
      } else if (t.ActivityDate > Date.today()) {
        caseIdList.add(t.WhatId);
        pendCaseTaskWrapper.taskId = t.Id;
        pendCaseTaskWrapper.caseId = t.WhatId;
        pendCaseTaskWrapper.taskRecord = t;
        pendCaseTaskWrapper.daysBetweenTaskDueDate = daysBetweenTaskDueDate;
        pendCaseTaskWrapper.notifyManager = true;
        pendCaseTaskWrapper.notifyOwner = false;
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
          pctw.caseOwnerUserRecord = c.Owner;
        }
      }
    }

    return pendCaseTaskWrapperList;
  }

  /**
   * @description method for sending in app notification to task owners
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   */
  public static void sendInAppNotificationToTaskOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRPendCaseTaskRemindersHelper.sendRemindersToTaskOwners(
      pendCaseTaskWrapperList
    );
  }

  /**
   * @description method for sending in app notification to case owners
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   */
  public static void sendInAppNotificationToCaseOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRPendCaseTaskRemindersHelper.sendRemindersToCaseOwners(
      pendCaseTaskWrapperList
    );
  }

  /**
   * @description method for sending in app notification to case owners when a task is created
   * @param taskList list of task records, whose case owners will recieve in app notification
   */
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
