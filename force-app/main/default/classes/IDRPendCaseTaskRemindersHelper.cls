public with sharing class IDRPendCaseTaskRemindersHelper {
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
}
