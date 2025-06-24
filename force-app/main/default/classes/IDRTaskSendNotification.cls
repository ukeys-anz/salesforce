/**
 * @author CMOS
 * @since  06/2025
 * @description IDRTaskSendNotification is class to send notifications to the queue onwers
 */
public with sharing class IDRTaskSendNotification {
  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records task records in current trigger context
   */
  public static void sendNotifications(List<Task> records) {
    List<Task> taskListToNotifications = new List<Task>();
    taskListToNotifications.addAll(
      (List<Task>) ListUtil.filter(records)
        .equals(Task.Subject, IDRTaskActions.IDR_TASK_SUBJECT)
        .toList()
    );
    taskListToNotifications.addAll(
      (List<Task>) ListUtil.filter(records)
        .equals(Task.OwnerId, QueryQueue.get('Admin_Requests').Id)
        .toList()
    );
    List<IDRBankerNotificationWrapper> wrapperList = createNotification(
      taskListToNotifications
    );

    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
  }
  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param recordList list of task records
   * @return List of IDRBankerNotificationWrapper
   */
  private static List<IDRBankerNotificationWrapper> createNotification(
    List<Task> recordList
  ) {
    List<IDRBankerNotificationWrapper> sendNotifications = new List<IDRBankerNotificationWrapper>();
    for (Task tskObj : recordList) {
      IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
        tskObj,
        new List<Id>{ tskObj.OwnerId },
        tskObj.Subject,
        String.valueOf(tskObj.ActivityDate),
        null
      );
      sendNotifications.add(wrapper);
    }
    return sendNotifications;
  }
}
