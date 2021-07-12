/**
 * @author Adnan
 * @since  09/2021
 * @description Helper class for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersHelper {
  /**
   * @description Helper method to get all the cases from specified caseIdList
   * @param caseIdList list of case ids
   * @return List<case> list of case records
   */
  public static List<Case> getCasesHelper(List<Id> caseIdList) {
    if (
      Case.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.Case.fields.CaseNumber.isAccessible() &&
      Schema.SObjectType.Case.fields.OwnerId.isAccessible()
    ) {
      return IDRPendCaseTaskRemindersSelector.getCasesFromIds(caseIdList);
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'getCasesHelper',
        'Not enough permissions to query/access Case Object/Fields.'
      );
      return null;
    }
  }

  /**
   * @description method to send reminders to case owners
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   */
  public static void sendRemindersToCaseOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRCaseNotificationManager.manageCaseNotificationForTaskReminders(
      pendCaseTaskWrapperList
    );
  }

  /**
   * @description method to send reminders to task owners
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   */
  public static void sendRemindersToTaskOwners(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    IDRTaskNotificationManager.manageNotificationForTaskReminders(
      pendCaseTaskWrapperList
    );
  }

  /**
   * @description method to check if task is eligible for email notification
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   * @return List<IDRPendCaseTaskReminderWrapper> updated wrapper with email notification details
   */
  public static List<IDRPendCaseTaskReminderWrapper> verifyIfEmailNotificationIsRequired(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList
  ) {
    List<Id> taskOwnerIdList = new List<Id>();
    for (IDRPendCaseTaskReminderWrapper pctw : pendCaseTaskWrapperList) {
      taskOwnerIdList.add(pctw.taskRecord.OwnerId);
    }
    List<PermissionSetAssignment> psaForTaskOwners = getPermissionSetAssignmentHelper(
      pendCaseTaskWrapperList,
      taskOwnerIdList
    );
    Map<Id, User> taskOwnerMap = getTaskOwnerMapHelper(
      pendCaseTaskWrapperList,
      taskOwnerIdList
    );
    if (psaForTaskOwners != null && taskOwnerMap != null) {
      for (IDRPendCaseTaskReminderWrapper pctw : pendCaseTaskWrapperList) {
        for (PermissionSetAssignment psa : psaForTaskOwners) {
          if (
            pctw.taskRecord.OwnerId == psa.AssigneeId &&
            pctw.daysBetweenTaskDueDate == 1
          ) {
            pctw.emailNotificationRequired = true;
            pctw.taskOwnerUserRecord = taskOwnerMap.get(psa.AssigneeId);
          } else {
            pctw.emailNotificationRequired = false;
          }
        }
      }
    }

    return pendCaseTaskWrapperList;
  }

  /**
   * @description method to get permission set assignement
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   * @param taskOwnerIdList list of task owner ids
   * @return List<PermissionSetAssignment> list of permission set assignments
   */
  public static List<PermissionSetAssignment> getPermissionSetAssignmentHelper(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList,
    List<Id> taskOwnerIdList
  ) {
    List<PermissionSetAssignment> psaForTaskOwners;
    if (
      PermissionSetAssignment.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.PermissionSetAssignment.fields.PermissionSetId.isAccessible() &&
      Schema.SObjectType.PermissionSetAssignment.fields.AssigneeId.isAccessible()
    ) {
      psaForTaskOwners = IDRPendCaseTaskRemindersSelector.getPermissionSetAssignment(
        taskOwnerIdList,
        IDRConstants.ELIGIBLE_TASK_REMINDERS_PERMISSION_SETS
      );
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'verifyIfEmailNotificationIsRequired',
        'Not enough permissions to query/access PermissionSetAssignment Object/Fields.'
      );
      return null;
    }

    return psaForTaskOwners;
  }

  /**
   * @description method to get task owner details
   * @param pendCaseTaskWrapperList list of IDRPendCaseTaskReminderWrapper
   * @param taskOwnerIdList list of task owner ids
   * @return Map<Id, User> returns map of task owner user record with its id
   */
  public static Map<Id, User> getTaskOwnerMapHelper(
    List<IDRPendCaseTaskReminderWrapper> pendCaseTaskWrapperList,
    List<Id> taskOwnerIdList
  ) {
    Map<Id, User> taskOwnerMap;
    if (
      User.SObjectType.getDescribe().isQueryable() &&
      Schema.SObjectType.User.fields.Email.isAccessible() &&
      Schema.SObjectType.User.fields.FirstName.isAccessible()
    ) {
      taskOwnerMap = IDRPendCaseTaskRemindersSelector.getUserDetails(
        taskOwnerIdList
      );
    } else {
      CommonUtil.logAndThrowIAE(
        'IDRPendCaseTaskRemindersHelper',
        'verifyIfEmailNotificationIsRequired',
        'Not enough permissions to query/access User Object/Fields.'
      );
      return null;
    }

    return taskOwnerMap;
  }
}
