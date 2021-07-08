public with sharing class IDRPendCaseTaskRemindersBatch implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date windowFromToday = Date.today()
      .addDays(Integer.valueOf(Label.IDR_Max_Window_For_Task_Reminders));
    return Database.getQueryLocator(
      'SELECT Id, ActivityDate, OwnerId, WhatId, Subject ' +
      'FROM Task ' +
      'WHERE Type = \'Pend Case\' AND WhatId != null AND ActivityDate <=: windowFromToday AND Owner.Type = \'User\''
    );
  }

  public void execute(Database.BatchableContext bc, List<Task> taskScope) {
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList = IDRPendCaseTaskRemindersHandler.createWrapper(
      taskScope
    );
    IDRPendCaseTaskRemindersHandler.sendInAppNotificationToTaskOwners(
      pendCaseTaskWrapperList
    );
    IDRPendCaseTaskRemindersHandler.sendInAppNotificationToCaseOwners(
      pendCaseTaskWrapperList
    );
    IDRPendCaseTaskRemindersHandler.sendEmailNotificationToTaskOwners(
      pendCaseTaskWrapperList,
      'Task Reminder'
    );
  }

  public void finish(Database.BatchableContext bc) {
  }
}
