/**
 * @author CMOS
 * @since  06/2025
 * @description IDRTaskSendNotification is class to send notifications to the queue onwers
 */
public with sharing class IDRTaskSendNotification {
  private static final String ADMIN_TASK = 'Admin Request';

  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records task records in current trigger context
   */
  public static void sendNotifications(List<Task> records) {
    List<IDRBankerNotificationWrapper> wrapperList = createNotification(
      records
    );
    IDRBankerNotificationBuilder.sendNotification(wrapperList);
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
        populateSubject(tskObj),
        String.valueOf(tskObj.ActivityDate),
        null
      );
      sendNotifications.add(wrapper);
    }
    return sendNotifications;
  }
  /**
   * @description get Subject Line for Notifications
   * @param tskObj task record from the trigger
   * @return String subject to send in notifications
   */
  private static String populateSubject(Task tskObj) {
    return (tskObj.OwnerId == QueryQueue.get('Admin_Requests').Id
      ? ADMIN_TASK
      : tskObj.Subject);
  }
}
