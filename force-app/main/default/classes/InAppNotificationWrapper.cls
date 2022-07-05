/**
 * @author Shermal Warnakula
 * @since Nov 2021
 * @description In App Notification Wrapper Class.
 */
public with sharing class InAppNotificationWrapper {
  /**
   * @description ID of the Custom Notification Type being used for the notification
   */
  public String notificationTypeId { get; set; }
  /**
   * @description Record ID for the target record of the notification
   */
  public String targetObjectId { get; set; }
  /**
   * @description set of recipient IDs
   */
  public Set<String> recipientList { get; set; }
  /**
   * @description custom notification title
   */
  public String msgTitle { get; set; }
  /**
   * @description custom notification body
   */
  public String msgBody { get; set; }

  /**
   * @description constructor to populate InAppNotificationWrapper parameters
   * @param notificationTypeId ID of Custom Notification Type being used for the notification
   * @param targetObjectId record ID for the target record of the notification
   * @param recipientList set of recipient IDs
   * @param msgTitle custom notification title
   * @param msgBody custom notification body
   */
  public InAppNotificationWrapper(
    String notificationTypeId,
    String targetObjectId,
    Set<String> recipientList,
    String msgTitle,
    String msgBody
  ) {
    this.notificationTypeId = notificationTypeId;
    this.targetObjectId = targetObjectId;
    this.recipientList = recipientList;
    this.msgTitle = msgTitle;
    this.msgBody = msgBody;
  }

  /**
   * @description additional constructor taking single Recipient ID along with other required parameters
   * @param notificationTypeId ID of Custom Notification Type being used for the notification
   * @param targetObjectId record ID for the target record of the notification
   * @param recipientId recipient ID
   * @param msgTitle custom notification title
   * @param msgBody custom notification body
   */
  public InAppNotificationWrapper(
    String notificationTypeId,
    String targetObjectId,
    String recipientId,
    String msgTitle,
    String msgBody
  ) {
    this.notificationTypeId = notificationTypeId;
    this.targetObjectId = targetObjectId;
    Set<String> recipientList = new Set<String>();
    recipientList.add(recipientId);
    this.recipientList = recipientList;
    this.msgTitle = msgTitle;
    this.msgBody = msgBody;
  }
}
