/**
 * @author Greg Shaw
 * @since  07/2023
 * @description IDRTaskActions2 was split from IDRTaskActions because that class was getting too long
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseActionsTest, IDRTaskActionsTest, TaskTriggerHandlerTest
 * StdCyclomaticComplexity Suppressed : The complexity of this class is more than expected but still readable
 */

@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class IDRTaskActions2 {
  public static final String TASK_TYPE_GENERAL = 'General Task/ Reminder';
  public static final String TASK_SUBJECT_URGENT = 'Urgent Case Allocation';

  /**
   * @description Check Tasks for the Subject 'Urgent Case Allocation'
   * @param lstTasks List of Tasks from Trigger
   * NcssMethodCount Suppressed : To have all the code lines together in one place.
   */
  @SuppressWarnings('PMD.NcssMethodCount')
  public static void checkForUrgentCaseAllocationTask(List<Task> lstTasks) {
    Set<Id> stCaseIds = new Set<Id>();
    String strCasePrefix = Case.getSObjectType().getDescribe().getKeyPrefix();
    String strGroupPrefix = Group.getSObjectType().getDescribe().getKeyPrefix();
    Map<Id, Set<String>> mpGroup2Recipients = new Map<Id, Set<String>>();
    for (Task oTask : lstTasks) {
      if (
        oTask.Type == TASK_TYPE_GENERAL &&
        String.isNotEmpty(oTask.Subject) &&
        oTask.Subject.contains(TASK_SUBJECT_URGENT) &&
        String.isNotEmpty(oTask.WhatId) &&
        ((String) oTask.WhatId).left(3) == strCasePrefix
      ) {
        stCaseIds.add(oTask.WhatId);
        if ( ((String) oTask.OwnerId).left(3) == strGroupPrefix &&
            !mpGroup2Recipients.containsKey(oTask.OwnerId)) {
          mpGroup2Recipients.put(oTask.OwnerId, new Set<String>());
        }
      }
    }
    if (stCaseIds.size() == 0) {
      return;
    }

    CustomNotificationType oNotificationType = CommonUtil.getCustomNotificationTypeByName(
      'CMOS'
    );
    if (oNotificationType == null) {
      Logger.error('Failed to retrieve CMOS Custom Notification Type: ', '');
      Logger.saveLog();
      return;
    }

    Map<Id, Case> mpId2Case = new Map<Id, Case>();
    Set<String> stRecipients;
    for (Case oCase : [
      SELECT Id, CaseNumber
      FROM Case
      WHERE Id IN :stCaseIds
    ]) {
      mpId2Case.put(oCase.Id, oCase);
    }
    Map<Id, Set<Id>> mpUserId2Groups = new Map<Id, Set<Id>>();
    Set<Id> stGroups;
    for (GroupMember oGroupMember : [
      SELECT GroupId, UserOrGroupId
      FROM GroupMember
      WHERE GroupId IN :mpGroup2Recipients.keySet()
    ]) {
      stRecipients = mpGroup2Recipients.get(oGroupMember.GroupId);
      stRecipients.add(oGroupMember.UserOrGroupId);
      if (
        (stGroups = mpUserId2Groups.get(oGroupMember.UserOrGroupId)) == null
      ) {
        stGroups = new Set<Id>();
        mpUserId2Groups.put(oGroupMember.UserOrGroupId, stGroups);
      }
      stGroups.add(oGroupMember.GroupId);
    }
    // Find all inactive users in groups
    for (User oUser : [
      SELECT Id
      FROM User
      WHERE IsActive = FALSE AND Id IN :mpUserId2Groups.keySet()
    ]) {
      for (Id idGroup : mpUserId2Groups.get(oUser.Id)) {
        // Remove inactive users from all recipient lists
        mpGroup2Recipients.get(idGroup).remove(oUser.Id);
      }
    }

    for (Task oTask : lstTasks) {
      if (
          oTask.Type == TASK_TYPE_GENERAL &&
          String.isNotEmpty(oTask.Subject) &&
          oTask.Subject.contains(TASK_SUBJECT_URGENT)) {
        if ( ((String)oTask.OwnerId).left(3) == strGroupPrefix) {
          stRecipients = mpGroup2Recipients.get(oTask.OwnerId);
        } else {
          stRecipients = new Set<String>{oTask.OwnerId};
        }
        if ( stRecipients != null) {
          CommonUtil.sendInAppNotification(
            new InAppNotificationWrapper(
              oNotificationType.Id,
              oTask.Id,
              stRecipients,
              TASK_SUBJECT_URGENT,
              'Request for urgent allocation of Case: ' +
              mpId2Case.get(oTask.WhatId).CaseNumber
            )
          );
        }
      }
    }
  }
}
