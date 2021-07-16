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

}
