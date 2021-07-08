public with sharing class IDRPendCaseTaskRemindersSelector {
  public static List<Case> getCasesFromIds(List<Id> caseIdList) {
    return [
      SELECT Id, CaseNumber, OwnerId
      FROM Case
      WHERE Id IN :caseIdList AND Owner.Type = 'User'
    ];
  }

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

  public static Map<Id, User> getUserDetails(List<Id> userIdList) {
    return new Map<Id, User>(
      [SELECT Id, Email, FirstName FROM User WHERE Id IN :userIdList]
    );
  }
}
