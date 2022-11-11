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
      milestoneCaseIds.add(updateGeneralEnquiryMilestone(oldRecord, record));
      milestoneCaseIds.add(updateANZPlusComplaintMilestone(oldRecord, record));
      milestoneCaseIds.add(updateDisputeMilestone(oldRecord, record));
      milestoneCaseIds.add(
        updateNonCustomerComplaintMilestone(oldRecord, record)
      );
    }
    milestoneCaseIds.remove(null);

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
   * @description This method will find general enquiry case which needs milestone update
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Id of the record
   */
  public static Id updateGeneralEnquiryMilestone(Case oldRecord, Case record) {
    if (!CheckCaseRecordType.isGeneralEnquiry(record)) {
      return null;
    }

    Boolean checkStatus =
      oldRecord.Status != GetHelpConstants.CLOSED_STATUS &&
      record.Status == GetHelpConstants.CLOSED_STATUS;
    Boolean isAEMConvertedCase = GetHelpCaseActionsHelper.isAEMConverted(
      oldRecord,
      record
    );
    if (checkStatus || isAEMConvertedCase) {
      return record.Id;
    }
    return null;
  }

  /**
   * @description This method will find ANZ plus complaint case which needs milestone update
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Id of the record
   */
  public static Id updateANZPlusComplaintMilestone(
    Case oldRecord,
    Case record
  ) {
    if (!CheckCaseRecordType.isANZPlusComplaint(record)) {
      return null;
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
    if (checkStatus || isAEMConvertedCase) {
      return record.Id;
    }
    return null;
  }
  /**
   * @description This method will find dispute case which needs milestone update
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Id of the record
   */
  public static Id updateDisputeMilestone(Case oldRecord, Case record) {
    if (!CheckCaseRecordType.isDispute(record)) {
      return null;
    }
    Boolean checkStatus =
      (oldRecord.Status == GetHelpConstants.OPEN_STATUS &&
      record.Status != GetHelpConstants.OPEN_STATUS) ||
      (oldRecord.Status == GetHelpConstants.UNDER_INVESTIGATION_STATUS &&
      record.Status == GetHelpConstants.CLOSED_STATUS);
    if (checkStatus) {
      return record.Id;
    }
    return null;
  }
  /**
   * @description This method will find non-customer complaint case which needs milestone update
   * This cases are made from AEM convertion.
   * @param oldRecord the old values of a record to process
   * @param record new record instance to process
   * @return Id of the record
   */
  public static Id updateNonCustomerComplaintMilestone(
    Case oldRecord,
    Case record
  ) {
    if (
      GetHelpCaseActionsHelper.isAEMConverted(oldRecord, record) &&
      CheckCaseRecordType.isNonCustomerComplaint(record)
    ) {
      return record.Id;
    }
    return null;
  }
}
