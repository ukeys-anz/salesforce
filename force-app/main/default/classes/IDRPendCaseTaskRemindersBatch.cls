/**
 * @author Adnan
 * @since  09/2021
 * @description Batch class to sending reminders for Pend Case Tasks
 */
public with sharing class IDRPendCaseTaskRemindersBatch implements Database.Batchable<sObject> {
  /**
   * @description Get all the task records whose type is Pend Case and withing due date window
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    Date windowFromToday = Date.today()
      .addDays(Integer.valueOf(Label.IDR_Max_Window_For_Task_Reminders));
    return Database.getQueryLocator(
      'SELECT Id, ActivityDate, OwnerId, WhatId, Subject ' +
      'FROM Task ' +
      'WHERE Type = \'Pend Case\' AND WhatId != null AND ActivityDate <=: windowFromToday AND Owner.Type = \'User\' AND Status != \'Completed\''
    );
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param taskScope from start method
   */
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

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public void finish(Database.BatchableContext bc) {
    //No post processing steps as of now
  }
}
