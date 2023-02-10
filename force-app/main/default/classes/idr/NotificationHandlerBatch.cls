/**
 * @author Afreen Khan
 * @since 11/2020
 * @description  NotificationHandlerBatch is to send the notification, via PE, which were generated outside the allowed AEST hours.
 */

public with sharing class NotificationHandlerBatch implements Database.Batchable<sObject>, Database.Stateful {
  /**
   * @description Get all the Notification records which are due to be sent out
   * @param bc Database.BatchableContext
   * @return Database.QueryLocator scope
   */
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Case__c, Status__c, CreatedDate FROM Notification_Handler__c ' +
      'WHERE Status__c = \'' +
      IDRConstants.NOTIFICATION_PENDING_PUBLISH_STATUS +
      '\''
    );
  }

  /**
   * @description  method which is called when batch is exeuted and will call another method to process the notification
   * @param bc Database.BatchableContext
   * @param handlerRecords from start method
   */

  public void execute(
    Database.BatchableContext bc,
    List<Notification_Handler__c> handlerRecords
  ) {
    processScheduledNotification(handlerRecords);
  }

  /**
   * @description  Process the scheduled Notifications
   * @param handlerRecords from start method
   */
  public void processScheduledNotification(
    List<Notification_Handler__c> handlerRecords
  ) {
    //Send the Notification for the records in context and save the Platform event enqueued status in peresults
    List<Database.SaveResult> peResults = NotificationTriggerHandler.sendNotifications(
      handlerRecords,
      true
    );
    Logger.error('', peResults);
    Logger.saveLog();

    //process the PE enqueued results and update the handler records accordingly
    for (Integer i = 0; i < handlerRecords.size(); i++) {
      Database.SaveResult sr = peResults[i];

      if (sr.isSuccess()) {
        handlerRecords[i].Status__c = IDRConstants.NOTIFICATION_PUBLISH_STATUS;
      } else {
        handlerRecords[i]
          .Status__c = IDRConstants.NOTIFICATION_ERROR_PUBLISH_STATUS;
      }
    }
    if (
      Notification_Handler__c.sObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Notification_Handler__c.fields.Status__c.isUpdateable()
    ) {
      List<Database.saveResult> result = Database.update(handlerRecords, false);

      Logger.error('', result);
      Logger.saveLog();
    } else {
      CommonUtil.logAndThrowIAE(
        'NotificationHandlerBatch',
        'processScheduledNotification',
        'Not enough permissions to update Notification_Handler__c.'
      );
    }
  }

  /**
   * @description To execute any post processing steps
   * @param bc Database.BatchableContext
   */
  public void finish(Database.BatchableContext bc) {
  }
}
