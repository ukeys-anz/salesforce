public with sharing class IDRPendCaseTaskRemindersSelector {
  public static List<Case> getCasesFromIds(List<Id> caseIdList) {
    return [
      SELECT Id, CaseNumber, OwnerId
      FROM Case
      WHERE Id IN :caseIdList AND Owner.Type = 'User'
    ];
  }
}
