/**
 * @author Farid Masjedi
 * @since July 2022
 * @description When a Unauthenticated enquiry case which has been created by AEM needs to change to another record type -
 * - This class will run to check the validation
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class CaseChangeRecordTypeController {
  // Change Unauthenticated Enquiry record type | Issue Type & Priority should be change message
  @TestVisible
  private static final String CHANGE_ISSUE_TYPE_AND_PRIORITY_VALUES = 'These required fields must be completed: Issue Type, Priority';
  // Change Unauthenticated Enquiry record type | Issue Type should be change message
  @TestVisible
  private static final String CHANGE_ISSUE_TYPE_VALUE = 'These required fields must be completed: Issue Type';
  // Change Unauthenticated Enquiry record type | Priority should be change message
  @TestVisible
  private static final String CHANGE_PRIORITY_VALUE = 'These required fields must be completed: Priority';

  /**
   * @description  When a case with Unauthenticated Enquiry record type changed to other record type,
   * this method will check the value of different fields and will throw an error according to the different conditions.
   * @param caseList list of cases from the trigger
   * @param oldCaseMap old case map
   */
  public static void recordTypeChangeValidation(
    List<Case> caseList,
    Map<Id, Case> oldCaseMap
  ) {
    for (Case record : caseList) {
      Case oldRecord = oldCaseMap.get(record.Id);

      Boolean isOldRecordUnauthenticatedEnquiryCase = GetHelpCaseActionsHelper.isUnauthenticatedEnquiry(
        oldRecord
      );
      Boolean isGeneralEnquiryCase = GetHelpCaseActionsHelper.isGeneralEnquiry(
        record
      );
      Boolean isANZPlusComplaintCase = GetHelpCaseActionsHelper.isANZPlusComplaint(
        record
      );
      Boolean isNonCustomerComplaintCase = GetHelpCaseActionsHelper.isNonCustomerComplaint(
        record
      );

      if (isOldRecordUnauthenticatedEnquiryCase && oldRecord.ANZx_Customer__c) {
        if (
          isGeneralEnquiryCase &&
          record.Type == null &&
          record.Priority == null
        ) {
          record.AddError(CHANGE_ISSUE_TYPE_AND_PRIORITY_VALUES);
        } else if (isGeneralEnquiryCase && record.Type == null) {
          record.AddError(CHANGE_ISSUE_TYPE_VALUE);
        } else if (isGeneralEnquiryCase && record.Priority == null) {
          record.AddError(CHANGE_PRIORITY_VALUE);
        } else if (
          (isANZPlusComplaintCase || isNonCustomerComplaintCase) &&
          PicklistUtil.getPicklistValue('Case', 'Type', 'Other') ==
          oldRecord.Type &&
          record.Type == null
        ) {
          record.addError(CHANGE_ISSUE_TYPE_VALUE);
        }
      }
    }
  }
}
