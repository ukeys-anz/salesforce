/**
 * @author Farid Masjedi
 * @since 11/2022
 * @description  MilestoneHandler handles Updating milestone on updates
 * @group Utils
 */
public with sharing class MilestoneHandler {
  @TestVisible
  public static final String RESOLUTION_TIME_MILESTONE = 'Resolution Time';
  @TestVisible
  public static final String INVESTIGATION_TIME_MILESTONE = 'Investigation Time';
  @TestVisible
  public static final String OPEN_ESCALATION_TIME = 'Open_Escalation_Time';

  /**
   * @description This method will update milestone on different cases
   * @param oldMap Map<Id, Case> oldMap: Map of the old values of the records to process
   * @param records List<Case> caseList: New record instances to process
   */
  public static void updateMilestone(
    Map<Id, SObject> oldMap,
    List<Case> records
  ) {
    Set<Id> milestoneCaseIds = new Set<Id>();
    for (Case record : (List<Case>) records) {
      Case oldRecord = (Case) oldMap.get(record.id);
      if (
        isGeneralEnquiryValidCase(oldRecord, record) ||
        isANZPlusComplaintValidCase(oldRecord, record) ||
        isDisputeValidCase(oldRecord, record) ||
        isNonCustomerComplaintValidCase(oldRecord, record)
      ) {
        milestoneCaseIds.add(record.Id);
      }
    }

    if (!milestoneCaseIds.isEmpty()) {
      MilestoneUtils.completeMilestones(
        milestoneCaseIds,
        new List<String>{
          RESOLUTION_TIME_MILESTONE,
          INVESTIGATION_TIME_MILESTONE,
          OPEN_ESCALATION_TIME
        },
        System.now()
      );
    }
  }

  /**
   * @description This method will check if a general enquiry case is valid for updating milestone.
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Boolean true/false check if it is valid for updating milestone.
   */
  public static Boolean isGeneralEnquiryValidCase(Case oldRecord, Case record) {
    if (!CheckCaseRecordType.isGeneralEnquiry(record)) {
      return false;
    }

    Boolean checkStatus =
      oldRecord.Status != GetHelpConstants.CLOSED_STATUS &&
      record.Status == GetHelpConstants.CLOSED_STATUS;
    Boolean isAEMConvertedCase = GetHelpCaseActionsHelper.isAEMConverted(
      oldRecord,
      record
    );
    return checkStatus || isAEMConvertedCase;
  }

  /**
   * @description This method will check if a ANZ plus complaint case is valid for updating milestone.
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Boolean true/false check if it is valid for updating milestone.
   */
  public static Boolean isANZPlusComplaintValidCase(
    Case oldRecord,
    Case record
  ) {
    if (!CheckCaseRecordType.isANZPlusComplaint(record)) {
      return false;
    }
    Boolean checkStatus =
      oldRecord.Status != GetHelpConstants.CLOSED_STATUS &&
      oldRecord.Status != GetHelpConstants.ESCALATED_STATUS &&
      oldRecord.Status != GetHelpConstants.WITHDRAWN_STATUS &&
      oldRecord.Status != GetHelpConstants.RESOLVED_STATUS &&
      (record.Status == GetHelpConstants.CLOSED_STATUS ||
      record.Status == GetHelpConstants.ESCALATED_STATUS ||
      record.Status == GetHelpConstants.WITHDRAWN_STATUS ||
      record.Status == GetHelpConstants.RESOLVED_STATUS);
    Boolean isAEMConvertedCase = GetHelpCaseActionsHelper.isAEMConverted(
      oldRecord,
      record
    );
    return checkStatus || isAEMConvertedCase;
  }
  /**
   * @description This method will check if a dispute case is valid for updating milestone.
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Boolean true/false check if it is valid for updating milestone.
   */
  public static Boolean isDisputeValidCase(Case oldRecord, Case record) {
    if (!CheckCaseRecordType.isDispute(record)) {
      return false;
    }
    Boolean checkStatus =
      (oldRecord.Status == GetHelpConstants.OPEN_STATUS &&
      record.Status != GetHelpConstants.OPEN_STATUS) ||
      (oldRecord.Status == GetHelpConstants.UNDER_INVESTIGATION_STATUS &&
      record.Status == GetHelpConstants.CLOSED_STATUS);
    return checkStatus;
  }
  /**
   * @description This method will check if a Non-Customer complaint case is valid for updating milestone.
   * This cases are made from AEM convertion.
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Boolean true/false check if it is valid for updating milestone.
   */
  public static Boolean isNonCustomerComplaintValidCase(
    Case oldRecord,
    Case record
  ) {
    return GetHelpCaseActionsHelper.isAEMConverted(oldRecord, record) &&
      CheckCaseRecordType.isNonCustomerComplaint(record);
  }
}
