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
  private static final String NO_POST_PROCESSING_STEPS_MSG = 'No post processing steps as of now';

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, ActivityDate, OwnerId, WhatId, Subject, Due_in_Days__c ' +
      'FROM Task ' +
      'WHERE Type = \'' +
      IDRConstants.TASK_TYPE_PEND_CASE +
      '\'' +
      ' AND WhatId != null AND Owner.Type = \'User\' AND Status != \'' +
      IDRConstants.TASK_STATUS_COMPLETED +
      '\'' +
      ' AND Due_in_Days__c <= ' +
      Label.IDR_Max_Window_For_Task_Reminders +
      ' AND RecordTypeId = \'' +
      IDRConstants.IDR_TASK_RT_ID +
      '\''
    );
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param taskScope from start method
   */
  public void execute(Database.BatchableContext bc, List<Task> taskScope) {
    List<IDRBankerNotificationWrapper> notificaitonWrapperList = IDRPendCaseTaskRemindersHandler.createWrapper(
      taskScope
    );
    IDRBankerNotificationBuilder.sendNotification(notificaitonWrapperList);
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
    System.debug(LoggingLevel.debug, NO_POST_PROCESSING_STEPS_MSG);
  }
}
