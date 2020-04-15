/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 04/2020
 * @description GetHelpCaseActions class is to handle all the Get Help Case Actions
 */
public with sharing class GetHelpCaseActions {
  // General Inquiry Record Type Id
  @TestVisible
  static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();

  /**
   * @description validateParentCase method is called before updating the case record to check and throw error if the record is having child cases
   * @param caseIds list of case ids from the trigger
   * @param validateCaseList list of case records from the trigger
   */
  public static void validateParentCase(
    List<Id> caseIds,
    List<Case> validateCaseList
  ) {
    Set<Id> parentCaseIds = new Set<Id>();
    List<Case> parentCaseList = new List<Case>();

    if (Schema.sObjectType.Case.isQueryable()) {
      parentCaseList = [
        SELECT Id, ParentId
        FROM Case
        WHERE ParentId IN :caseIds
      ];
    }

    for (Case parentCase : parentCaseList) {
      parentCaseIds.add(parentCase.ParentId);
    }

    for (Case record : validateCaseList) {
      if (
        record.RecordTypeId == GENERAL_INQUIRY_RT_ID &&
        parentCaseIds.contains(record.id)
      ) {
        record.addError(Label.Msg_Parent_Case_Validation);
      }
    }
  }
}
