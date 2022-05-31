/**
 * @description TaskTriggerHandler is the handler class for Task Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Shermal Warnakula, Boobalakrishnan Duraisamy
 * @since 03/2021
 */
public with sharing class TaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TaskTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    IDRTaskActions.beforeInsertActions(records);
    GetHelpTaskActions.beforeInsertActions(records);
  }
  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    manageNotification((List<Task>) records);
    IDRTaskActions.afterInsertActions(records);
  }
  /**
   * @description onBeforeUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRTaskActions.beforeUpdateActions(records, (Map<Id, Task>) oldMap);
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRTaskActions.afterUpdateActions(records);
  }
  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records task records in current trigger context
   */
  private static void manageNotification(List<Task> records) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();

    for (Task record : (List<Task>) records) {
      if (
        record.RecordTypeId == IDRConstants.IDR_SYSTEM_TASK_RT_ID &&
        record.Subject == IDRTaskActions.IDR_TASK_SUBJECT &&
        record.OwnerId == IDRTaskActions.siQueue.Id
      ) {
        wrapperList.add(createNotification(record));
      }
    }
    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
  }
  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param record task record from the trigger
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  private static IDRBankerNotificationWrapper createNotification(Task record) {
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      record,
      new List<Id>{ record.OwnerId },
      record.Subject,
      String.valueOf(record.ActivityDate),
      null
    );
    return wrapper;
  }
}
