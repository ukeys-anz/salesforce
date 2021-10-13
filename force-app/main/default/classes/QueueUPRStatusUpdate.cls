/**
 * @author Boobalakrishnan Duraisamy
 * @since  09/2020
 * @description QueueUPRStatusUpdate class is called in UserTriggerHandler to update User Provisioning Request status Asynchronously to avoid Mixed_DML_Error
 */
public with sharing class QueueUPRStatusUpdate implements Queueable {
  List<User_Provisioning_Request__c> updateUPRList;
  Lib_SystemLog log;

  /**
   * @description Constructor
   * @param triggerUPRList List of UPR records from User Trigger
   * @param triggerLog Lib_SystemLog from User Trigger
   */

  public QueueUPRStatusUpdate(
    List<User_Provisioning_Request__c> triggerUPRList,
    Lib_SystemLog triggerLog
  ) {
    updateUPRList = triggerUPRList;
    log = triggerLog;
  }

  /**
   * @description execute method
   * @param context QueueableContext
   */

  public void execute(QueueableContext context) {
    List<Database.SaveResult> updateUPRResult = Database.update(
      updateUPRList,
      false
    );

    log.insertLog();
  }
}
