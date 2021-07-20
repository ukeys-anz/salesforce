/**
 * @author Adnan
 * @since  09/2021
 * @description Helper class for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersHelper {
  /**
   * @description Helper method to get all the cases from specified caseIdList
   * @param caseIdList list of case ids
   * @return Map<Id, Case> map of case with its id
   */
  public static Map<Id, Case> getCasesHelper(List<Id> caseIdList) {
    //No need for CRUD validation as all the profiles will have access to CaseNumber, OwnerId of Case Object
    return IDRPendCaseTaskRemindersSelector.getCasesFromIds(caseIdList);
  }
}
