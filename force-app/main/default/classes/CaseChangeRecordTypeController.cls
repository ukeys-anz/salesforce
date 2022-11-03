/**
 * @author Farid Masjedi
 * @since July 2022
 * @description When a Unauthenticated enquiry case which has been created by AEM needs to change to another record type -
 * - This class will run to check the validation
 */
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
      if (
        CheckCaseRecordType.isUnauthenticatedEnquiry(oldRecord) &&
        oldRecord.ANZx_Customer__c
      ) {
        addGeneralEnquiryErrors(record);
        addComplaintErrors(record, oldRecord);
      }
    }
  }

  /**
   * @description When there is a case with General Enquiry record type,
   * this method will check the value of issue type and proprity fields
   * and will throw an error according to the different conditions.
   * @param record new case from the trigger
   */
  public static void addGeneralEnquiryErrors(Case record) {
    if (!CheckCaseRecordType.isGeneralEnquiry(record)) {
      return;
    }

    if (record.Type == null && record.Priority == null) {
      record.addError(CHANGE_ISSUE_TYPE_AND_PRIORITY_VALUES);
    } else if (record.Priority == null) {
      record.addError(CHANGE_PRIORITY_VALUE);
    } else if (record.Type == null) {
      record.AddError(CHANGE_ISSUE_TYPE_VALUE);
    }
  }

  /**
   * @description When there is a case with anz plus comaplint or non-customer complaint record type,
   * this method will check the value of issue type field
   * and will throw an error according to a logic.
   * @param record new case record from the trigger
   * @param oldRecord old case record from the trigger
   */
  public static void addComplaintErrors(Case record, Case oldRecord) {
    if (
      !CheckCaseRecordType.isANZPlusComplaint(record) &&
      !CheckCaseRecordType.isNonCustomerComplaint(record)
    ) {
      return;
    }
    if (
      CommonUtil.getSinglePicklistValue(Case.Type, 'Other') == oldRecord.Type &&
      record.Type == null
    ) {
      record.addError(CHANGE_ISSUE_TYPE_VALUE);
    }
  }
}
