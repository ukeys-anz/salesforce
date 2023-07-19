/**
 * @author Greg Shaw
 * @since  07/2023
 * @description IDRTaskActions2 was split from IDRTaskActions because that class was getting too long
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCaseActionsTest, IDRTaskActionsTest, TaskTriggerHandlerTest
 */

public with sharing class IDRTaskActions2 {

  public static final String TASK_TYPE_GENERAL = 'General Task/ Reminder';
  public static final String TASK_SUBJECT_URGENT = 'Urgent Case Allocation';

  /**
   * @description Check Tasks for the Subject 'Urgent Case Allocation'
   * @param lstTasks List of Tasks from Trigger
   */
  public static void checkForUrgentCaseAllocationTask( List<Task> lstTasks) {

    Set<Id> stCaseIds = new Set<Id>();
    String strCasePrefix = Case.getSObjectType().getDescribe().getKeyPrefix();
    for ( Task oTask : lstTasks) {
      if (oTask.Type == TASK_TYPE_GENERAL &&
      String.isNotEmpty(oTask.Subject) &&
      oTask.Subject.contains(TASK_SUBJECT_URGENT) &&
      String.isNotEmpty(oTask.WhatId) &&
      ((String) oTask.WhatId).left(3) == strCasePrefix) {
        stCaseIds.add(oTask.WhatId);
      }
    }
    if ( stCaseIds.size() == 0 ) {
      return;
    }

    CustomNotificationType oNotificationType = CommonUtil.getCustomNotificationTypeByName('CMOS');
    if ( oNotificationType == null ) {
      Logger.error(
      'Failed to retrieve CMOS Custom Notification Type: ',
      ''
      );
      Logger.saveLog();
      return;
    }

    Map<Id, Case> mpId2Case = new Map<Id, Case>();
    Map<Id, Set<String>> mpGroup2Recipients = new Map<Id, Set<String>>();
    Set<String> stRecipients;
    String strGroupPrefix = Group.getSObjectType().getDescribe().getKeyPrefix();
    for ( Case oCase : [SELECT Id, OwnerId, CaseNumber
                        FROM Case
                        WHERE Id IN :stCaseIds]) {
      if ( ((String) oCase.OwnerId).left(3) == strGroupPrefix) {
        mpId2Case.put(oCase.Id, oCase);
        if ( !mpGroup2Recipients.containsKey(oCase.OwnerId)) {
          mpGroup2Recipients.put(oCase.OwnerId, new Set<String>());
        }
      }
    }
    for ( GroupMember oGroupMember : [SELECT GroupId, UserOrGroupId
                                      FROM GroupMember
                                      WHERE GroupId IN :mpGroup2Recipients.keySet()]) {
      stRecipients = mpGroup2Recipients.get(oGroupMember.GroupId);
      stRecipients.add(oGroupMember.UserOrGroupId);
    }

    for ( Task oTask : lstTasks) {
      if( oTask.Type == TASK_TYPE_GENERAL &&
      String.isNotEmpty(oTask.Subject) &&
      oTask.Subject.contains(TASK_SUBJECT_URGENT)) {
        stRecipients = mpGroup2Recipients.get(mpId2Case.get(oTask.WhatId).OwnerId);
        CommonUtil.sendInAppNotification(new InAppNotificationWrapper(
        oNotificationType.Id,
        oTask.Id,
        stRecipients,
        TASK_SUBJECT_URGENT,
        'Request for urgent allocation of Case: ' + mpId2Case.get(oTask.WhatId).CaseNumber
        ));
      }
    }
  }
}