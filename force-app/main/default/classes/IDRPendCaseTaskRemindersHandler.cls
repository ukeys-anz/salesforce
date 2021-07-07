public with sharing class IDRPendCaseTaskRemindersHandler {
  public static void sendRemindersToCaseOwners(List<Task> taskList) {
    List<Id> caseIdList = new List<Id>();
    Map<Id, Integer> caseIdWithDueDaysMap = new Map<Id, Integer>();
    List<String> windowForTaskReminders = Label.IDR_Window_For_Task_Reminders.split(
      ','
    );
    for (Task t : taskList) {
      Integer daysBetweenTaskDueDate = Date.today().daysBetween(t.ActivityDate);
      Boolean isDueDateWithinWindow = windowForTaskReminders.contains(
          String.valueOf(Date.today().daysBetween(t.ActivityDate))
        )
        ? true
        : false;
      if (isDueDateWithinWindow) {
        caseIdList.add(t.WhatId);
        caseIdWithDueDaysMap.put(t.WhatId, daysBetweenTaskDueDate);
      }
    }
    List<Case> caseListForReminders = IDRPendCaseTaskRemindersHelper.getCasesHelper(
      caseIdList
    );
    IDRCaseNotificationManager.manageCaseNotificationForTaskReminders(
      caseListForReminders,
      caseIdWithDueDaysMap
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
