/**
 * @author Ayushi G
 * @since  03/2025
 * @description Handler class for ReferralLeadExpiryBatch, for updating Leads with cancelled status.
 */
public with sharing class ReferralLeadExpiryHandler {
  private class CustomSharingException extends Exception {
  }
  @testVisible
  private static final String REFERRAL_STATUS_CANCELLED = 'Cancelled';
  @testVisible
  private static final String NOTIFICATION_TITLE = 'Referral Cancelled';
  @testVisible
  private static final String NOTIFICATION_BODY = 'The referral sent by you is cancelled.';
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  @testVisible
  private static final String EXP_REM_NOTIFICATION_TITLE = 'Referral expire soon';
  @testVisible
  private static final String EXP_REM_NOTIFICATION_BODY = 'One of your Referral is due to expire soon.';
  private static final Id REFERRAL_NOTIFICATION_ID = CommonUtil.getCustomNotificationTypeByName(
      'Commercial_Referral_Notification'
    )
    .Id;

  private static final CommercialReferralLeadRepository REFERRAL_REPO = (CommercialReferralLeadRepository) Lib_InstanceProvider.forType(
    CommercialReferralLeadRepository.class
  );

  /**
   * @description method to updated selected Leads with Status as 'Cancelled'
   * @name updateCancelledLeads
   * @param leadList list of lead records that are having Expiry_Date__c passed are needed to be updated.
   */
  public static void updateCancelledLeads(List<Lead> leadList) {
    ListUtil.setField(
      leadList,
      Lead.Referral_Status__c,
      REFERRAL_STATUS_CANCELLED
    );
    saveUpdatedLeads(leadList);
  }

  /**
   * @description This method returns a list of leads that has been updated to cancelled
   * @name saveUpdatedLeads
   * @param updatedLeads list of updated leads
   */
  @TestVisible
  private static void saveUpdatedLeads(List<Lead> updatedLeads) {
    try {
      if (updatedLeads.isEmpty()) {
        return;
      }
      List<Database.SaveResult> results = DML.doUpdate(
        updatedLeads,
        new DmlConfig().allowPartial().withoutSharing()
      );
    } catch (Exception e) {
      Logger.error('Error occured while updating Lead Status to Cancelled', e);
      Logger.saveLog();
    }
  }

  /**
   * @description This is used to send bell notification to sender
   * @name sendNotification
   * @param leads List of lead records
   */
  public static void sendNotification(List<Lead> leads) {
    for (Lead referralRec : leads) {
      InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
        REFERRAL_NOTIFICATION_ID,
        referralRec.Id,
        referralRec.FinServ__ReferredByUser__c,
        NOTIFICATION_TITLE,
        NOTIFICATION_BODY
      );
      CommonUtil.sendInAppNotification(notificationWrapper);
    }
  }

  /**
   * @description This is used to send bell notification to receiver's manager or to Queue members
   * @name sendExpiryReminder
   * @param referralLeadList List of referral records
   */
  public static void sendExpiryReminder(List<Lead> referralLeadList) {
    sendExpiryReminderNotificationToManager(referralLeadList);
    sendExpiryReminderNotificationToQueue(referralLeadList);
  }

  /**
   * @description This is used to send bell notification to receiver's manager before referral is about to expire
   * @name sendExpiryReminderNotificationToManager
   * @param referralLeadList List of referral records
   */
  @testVisible
  private static void sendExpiryReminderNotificationToManager(
    List<Lead> referralLeadList
  ) {
    //Filter referral leads where owner is user
    List<Lead> leadOwnerUserList = ListUtil.filter(referralLeadList)
      .contains(Lead.OwnerId, '005')
      .toList();

    Set<Id> ownerIdSet = ListUtil.getIds(leadOwnerUserList, Lead.OwnerId);
    List<User> managerList = REFERRAL_REPO.getManagerInfo(ownerIdSet);
    //send notifications to owner's manager
    sendNotificationToManager(leadOwnerUserList, managerList);
  }

  /**
   * @description This is used to send bell notification to receiver's manager before referral is about to expire
   * @name sendNotificationToManager
   * @param leadOwnerUserList List of referral records
   * @param managerList List of manager
   */
  @testVisible
  private static void sendNotificationToManager(
    List<Lead> leadOwnerUserList,
    List<User> managerList
  ) {
    Map<Id, User> ownerIdToManagerMap = new Map<Id, User>(managerList);
    for (Lead referralRec : leadOwnerUserList) {
      String managerId = ownerIdToManagerMap.get(referralRec.OwnerId)
        ?.ManagerId;
      if (managerId == null) {
        continue;
      }
      InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
        REFERRAL_NOTIFICATION_ID,
        referralRec.Id,
        managerId,
        EXP_REM_NOTIFICATION_TITLE,
        EXP_REM_NOTIFICATION_BODY
      );
      CommonUtil.sendInAppNotification(notificationWrapper);
    }
  }

  /**
   * @description This is used to send bell notification to Queue member before referral is about to expire
   * @name sendExpiryReminderNotificationToQueue
   * @param referralLeadList List of referral records
   */
  @testVisible
  private static void sendExpiryReminderNotificationToQueue(
    List<Lead> referralLeadList
  ) {
    //Filter referral leads where owner is Queue
    List<Lead> leadOwnerQueueList = ListUtil.filter(referralLeadList)
      .contains(Lead.OwnerId, '00G')
      .toList();

    // Get list of unique owners
    Set<Id> setOfGroups = ListUtil.getIds(leadOwnerQueueList, Lead.OwnerId);

    // Get list of GroupMembers from using queue
    List<GroupMember> queueMemberList = REFERRAL_REPO.getQueueMembers(
      setOfGroups
    );

    // Create Map of Queue to List of Users in Queue
    Map<Id, List<GroupMember>> queueToUsersMap = (Map<Id, List<GroupMember>>) ListUtil.groupBy(
      queueMemberList,
      GroupMember.GroupId
    );

    //send notifications to Queue member
    sendNotificationToQueue(leadOwnerQueueList, queueToUsersMap);
  }

  /**
   * @description This is used to send bell notification to receiver's manager before referral is about to expire
   * @name sendExpiryReminderNotificationToQueue
   * @param leadOwnerQueueList List of lead referrals with owner as queue
   * @param queueToUsersMap Map of Queue to queue members
   */
  @testVisible
  private static void sendNotificationToQueue(
    List<Lead> leadOwnerQueueList,
    Map<Id, List<GroupMember>> queueToUsersMap
  ) {
    for (Lead referralRec : leadOwnerQueueList) {
      Set<String> userSet = ListUtil.getStrings(
        queueToUsersMap.get(referralRec.OwnerId),
        GroupMember.UserOrGroupId
      );
      InAppNotificationWrapper notificationWrapper = new InAppNotificationWrapper(
        REFERRAL_NOTIFICATION_ID,
        referralRec.Id,
        userSet,
        EXP_REM_NOTIFICATION_TITLE,
        EXP_REM_NOTIFICATION_BODY
      );

      CommonUtil.sendInAppNotification(notificationWrapper);
    }
  }
}
