/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Builds and send the  Banker Notification as per their preference.
 */
public with sharing class IDRBankerNotificationBuilder {
  public static Map<Id, UserPreference> userPreferenceMap;

  /**
   * @description prepare the notification based on preference and sends to appropriate chnnel
   * @param wrapperList List of wrapper class which holds the notification details
   */
  public static void sendNotification(
    List<IDRBankerNotificationWrapper> wrapperList
  ) {
    CustomNotificationType type = CommonUtil.getCustomNotificationTypeByName(
      'IDR_Banker_Notification'
    );

    populateUserPreference(wrapperList);

    for (IDRBankerNotificationWrapper wrapperRecord : wrapperList) {
      Set<String> recipientIds = new Set<String>();
      Set<String> emailrecipients = new Set<String>();

      populateRecipientsList(recipientIds, emailrecipients, wrapperRecord);

      if (!recipientIds.isEmpty()) {
        sendInAppNotification(wrapperRecord, type.Id, recipientIds);
      }
    }
  }

  /**
   * @description populate the recepients
   * @param recipients list of inapp and case recepients
   * @param emailRecipients list of email recepients
   * @param wrapperRecord wrapper class which holds the notification details
   */
  public static void populateRecipientsList(
    Set<String> recipients,
    Set<String> emailRecipients,
    IDRBankerNotificationWrapper wrapperRecord
  ) {
    for (Id recipient : wrapperRecord.recipientList) {
      if (userPreferenceMap.containsKey(recipient)) {
        if (userPreferenceMap.get(recipient).inApp) {
          recipients.add(recipient);
        }
      } else {
        recipients.add(recipient);
      }
    }
  }

  /**
   * @description Send the in app notification
   * @param wrapperRecord wrapper reccord
   * @param notificationTypeId Id of the IDR Banker Notification Type
   * @param recipientIds Users ids to recieve this notification
   */
  public static void sendInAppNotification(
    IDRBankerNotificationWrapper wrapperRecord,
    String notificationTypeId,
    Set<String> recipientIds
  ) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setBody(wrapperRecord.msgBody);
    notification.setTitle(wrapperRecord.msgTitle);
    notification.setNotificationTypeId(notificationTypeId);
    notification.setTargetId(wrapperRecord.sfObject.Id); // target object id
    try {
      notification.send(recipientIds);
    } catch (Exception e) {
      lib_systemLog log = new lib_systemLog(
        IDRBankerNotificationBuilder.class.getName(),
        'sendInAppNotification'
      );
      log.error(
        'Problem sending in app notification: ' + recipientIds,
        e.getMessage(),
        UserInfo.getUserId()
      );
      log.publishEvent();
    }
  }

  /**
   * @description builds a map of user and their notification preference
   * @param wrapperList List of wrapper class which holds the notification details
   */
  public static void populateUserPreference(
    List<IDRBankerNotificationWrapper> wrapperList
  ) {
    Set<Id> userIds = new Set<Id>();
    userPreferenceMap = new Map<Id, UserPreference>();

    for (IDRBankerNotificationWrapper wrapperRecord : wrapperList) {
      userIds.addAll(wrapperRecord.recipientList);
    }

    for (Id recepientId : userIds) {
      UserPreference up = new UserPreference();
      up.userId = recepientId;
      up.email = false;
      up.caseFlag = true;
      up.inApp = true;

      userPreferenceMap.put(recepientId, up);
    }
  }

  /**
   * @description Wrapper class to hold the user preference
   */
  public class UserPreference {
    public String userId;
    public Boolean email;
    public Boolean caseFlag;
    public Boolean inApp;
  }
}
