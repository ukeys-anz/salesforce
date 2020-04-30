/**
 *
 * @author Boobalakrishnan Duraisamy
 * @since 04/2020
 * @description GetHelpCaseActions class is to handle all the Get Help Case Actions
 */
public with sharing class GetHelpCaseActions {
  // General Inquiry Record Type Id
  @TestVisible
  public static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();

  // Parent Case validation error message
  private static final String PARENT_CASE_ERROR = 'You cannot add parent case. This case is associated with child cases';

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
    //to store list of cases where the current record is parent case for other case records
    List<Case> childCaseList = new List<Case>();

    if (Schema.sObjectType.Case.isQueryable()) {
      childCaseList = [
        SELECT Id, ParentId
        FROM Case
        WHERE ParentId IN :caseIds
      ];
    }

    for (Case childCase : childCaseList) {
      parentCaseIds.add(childCase.ParentId);
    }

    for (Case record : validateCaseList) {
      if (parentCaseIds.contains(record.id)) {
        record.addError(PARENT_CASE_ERROR);
      }
    }
  }
  /**
   * @description validate the selected additional types
   * @param caseList The case list to validate the additional types on
   */
  public static void validateAdditionalTypes(List<Case> caseList) {
    for (Case singleCase : caseList) {
      if (
        singleCase.RecordTypeId == GENERAL_INQUIRY_RT_ID &&
        String.isNotBlank(singleCase.Additional_Type__c)
      ) {
        List<String> additionalTypes = singleCase.Additional_Type__c.split(';');

        if (additionalTypes.size() > 2) {
          singleCase.addError(
            'You cannot select more than two Additional Types.'
          );
        }

        for (String additionalType : additionalTypes) {
          if (additionalType == singleCase.Type) {
            singleCase.addError(
              'You cannot select a value in Additional Type that is already selected as the Primary Type.'
            );
          }
        }
      }
    }
  }
}
