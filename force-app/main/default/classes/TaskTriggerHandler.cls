/**
 * @description TaskTriggerHandler to send custom notification to SI queue members
 * @author Boobalakrishnan Duraisamy
 * @since 02/2021
 */
public with sharing class TaskTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public TaskTriggerHandler() {
    super();
  }
  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    manageNotification((List<Task>) records);
  }

  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records task records in current trigger context
   */
  private static void manageNotification(List<Task> records) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();

    for (Task record : (List<Task>) records) {
      if (
        record.RecordTypeId == IDRCaseActions.IDR_TASK_RT_ID &&
        record.Subject == IDRCaseActions.IDR_TASK_SUBJECT &&
        record.OwnerId == IDRCaseActions.siQueue.id
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
      String.valueOf(record.activityDate),
      null
    );
    return wrapper;
  }
}
