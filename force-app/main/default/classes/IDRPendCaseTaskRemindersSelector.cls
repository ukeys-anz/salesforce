/**
 * @author Adnan
 * @since  09/2021
 * @description Selector class which contains queries for IDRPendCaseTaskRemindersBatch and for creating and sending task notifications
 */
public with sharing class IDRPendCaseTaskRemindersSelector {
  /**
   * @description method to get case records from soql query
   * @param caseIdList list of case ids
   * @return List<Case> returns list of case records
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //CRUD check is done in parent class
  public static List<Case> getCasesFromIds(List<Id> caseIdList) {
    return [
      SELECT Id, CaseNumber, OwnerId
      FROM Case
      WHERE Id IN :caseIdList AND Owner.Type = 'User'
    ];
  }

  /**
   * @description method to get permission set asssignment from soql query
   * @param userIdList list of user ids
   * @param permissionsList list containing permission set names
   * @return List<PermissionSetAssignment> returns list of permission set assignment records
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //CRUD check is done in parent class
  public static List<PermissionSetAssignment> getPermissionSetAssignment(
    List<Id> userIdList,
    List<String> permissionsList
  ) {
    return [
      SELECT PermissionSetId, AssigneeId
      FROM PermissionSetAssignment
      WHERE AssigneeId IN :userIdList AND PermissionSet.Name IN :permissionsList
    ];
  }

  /**
   * @description method to get user records from soql query
   * @param userIdList list of user ids
   * @return Map<Id, User> returns a map of user records with its id
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //CRUD check is done in parent class
  public static Map<Id, User> getUserDetails(List<Id> userIdList) {
    return new Map<Id, User>(
      [SELECT Id, Email, FirstName FROM User WHERE Id IN :userIdList]
    );
  }
}
