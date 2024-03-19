/**
 * @author Somya Tiwari
 * @since  03/2024
 * @description IDR_CaseReportingCalculations is class to handle all the reporting field actions that will be used for reporting.
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDR_CaseReportingCalculations {
  private static List<String> openCaseStatusRG271 = new List<String>{
    IDRConstants.OPEN_STATUS,
    IDRConstants.UNDER_INVESTIGATION_STATUS,
    IDRConstants.ESCALATED_STATUS
  };
  private static List<String> openCaseStatus = new List<String>{
    IDRConstants.OPEN_STATUS,
    IDRConstants.UNDER_INVESTIGATION_STATUS,
    IDRConstants.ESCALATED_STATUS,
    IDRConstants.REOPENED_STATUS
  };

  /**
   * @description  calculateCaseOpenTime method is used to handle the case status changes as follows
   * 1. Update the Case Reporting Field record with the Case Last Opened RG271 whenever the case status changes from non RG271 obligation status to RG271 obligation status
   * 2. Update the Case Reporting Field record with the Case Last Opened  whenever the case status changes from non open status to open status
   * 3. Update the Time in MS fields whenever the status are changed back to Closed status.
   * @param newRecords The actual case record from the trigger
   * @param oldRecordMap The old case record from the trigger
   */
  public static void calculateCaseOpenTime(
    List<Case> newRecords,
    Map<ID, Case> oldRecordMap
  ) {
    List<Case> recordsToProcess = getRecordsToProcess(newRecords, oldRecordMap);
    if (recordsToProcess.isEmpty()) {
      return;
    }
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = getReportingFieldForCases(
      recordsToProcess
    );
    List<Case_Reporting_Field__c> reportingFields = updateCaseReportingField(
      recordsToProcess,
      oldRecordMap,
      caseIdToFieldMap
    );
    DMLUtil.upsertRecords(
      reportingFields,
      DMLUtil.NOT_ALLOW_PARTIAL_UPDATE,
      DMLUtil.SYSTEM_MODE
    );
  }
  /**
   * @description  getRecordsToProcess method is used to handle the case status changes as follows
   * Removes unwanted records from processing further
   * @param newRecords The actual case record from the trigger
   * @param oldRecordMap The  oldmap of case records from the trigger
   * @return List<Case> this can include the cases which we will process further.
   */
  @TestVisible
  private static List<Case> getRecordsToProcess(
    List<Case> newRecords,
    Map<ID, Case> oldRecordMap
  ) {
    List<ID> recordTypes = new List<ID>{
      IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
      IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID
    };
    Case oldCase;
    List<Case> recordsToProcess = new List<Case>();
    for (Case cse : newRecords) {
      oldCase = oldRecordMap.get(cse.Id) != null
        ? oldRecordMap.get(cse.Id)
        : null;
      if (!recordTypes.contains(cse.RecordTypeId)) {
        continue;
      }
      if (
        oldCase != null &&
        oldCase.get('Status') != cse.get('Status') &&
        checkValidStatus(oldCase, cse)
      ) {
        recordsToProcess.add(cse);
      }
      if (oldCase == null) {
        recordsToProcess.add(cse);
      }
    }
    return recordsToProcess;
  }
  /**
   * @description  checkValidStatus method is used to handle the case status changes as follows
   * Removes unwanted records from processing further
   * @param newCase The actual case record from the trigger
   * @param oldCase The old case record from the trigger
   * @return boolean returns true if the status is valid.
   */
  private static boolean checkValidStatus(Case newCase, Case oldCase) {
    if (
      (openCaseStatusRG271.contains(newCase.Status) &&
      !openCaseStatusRG271.contains(oldCase.Status)) ||
      (!openCaseStatusRG271.contains(newCase.Status) &&
      openCaseStatusRG271.contains(oldCase.Status)) ||
      (!openCaseStatus.contains(newCase.Status) &&
      openCaseStatus.contains(oldCase.Status)) ||
      (openCaseStatus.contains(newCase.Status) &&
      !openCaseStatus.contains(oldCase.Status))
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description  calculateOpenTime method is used to calculate the open time
   * @param lastOpenedDate Last Opened Date in Date Time format
   * @return Long timeDifferenceMilliseconds
   */
  private static Long calculateOpenTime(DateTime lastOpenedDate) {
    Long timeDifferenceMilliseconds = 0;
    if (lastOpenedDate != null) {
      timeDifferenceMilliseconds =
        DateTime.now().getTime() - lastOpenedDate.getTime();
    }
    return timeDifferenceMilliseconds;
  }

  /**
   * @description  checkLastOpenedDatePopulation method is used to check if the status is changed from non valid status to Valid status.
   * @param newCase Last Opened Date in Date Time format
   * @param oldCase The old case record from the trigger
   * @param statusToCheck List of status to check against
   * @return Boolean returns tue / false based on if we need to move forward or not.
   */
  private static Boolean checkLastOpenedDatePopulation(
    Case newCase,
    Case oldCase,
    List<String> statusToCheck
  ) {
    if (
      (oldCase != null &&
      statusToCheck.contains(newCase.Status) &&
      !statusToCheck.contains(oldCase.Status)) ||
      (oldCase == null && statusToCheck.contains(newCase.Status))
    ) {
      return true;
    }
    return false;
  }
  /**
   * @description  updateCaseReportingField here we update all the Case Reporting Field Records.
   * @param recordsToProcess List of Cases for processing
   * @param oldRecordMap The old case record map from the trigger
   * @param caseIdToFieldMap Case ID to Case Reporting Field Map
   * @return returns the updated List<Case_Reporting_Field__c> records.
   */
  @TestVisible
  private static List<Case_Reporting_Field__c> updateCaseReportingField(
    List<Case> recordsToProcess,
    Map<Id, Case> oldRecordMap,
    Map<Id, Case_Reporting_Field__c> caseIdToFieldMap
  ) {
    Case oldCase;
    Case_Reporting_Field__c crf;
    for (Case cse : recordsToProcess) {
      oldCase = oldRecordMap.get(cse.Id) != null
        ? (Case) oldRecordMap.get(cse.Id)
        : null;
      crf = caseIdToFieldMap.get(cse.Id);
      if (checkLastOpenedDatePopulation(cse, oldCase, OpenCaseStatusRG271)) {
        crf.Case_Last_Opened_RG271__c = DateTime.now();
      }
      if (checkLastOpenedDatePopulation(cse, oldCase, OpenCaseStatus)) {
        crf.Case_Last_Opened__c = DateTime.now();
      }
      if (oldCase == null) {
        continue;
      }
      if (
        !openCaseStatusRG271.contains(cse.Status) &&
        openCaseStatusRG271.contains(oldCase.Status)
      ) {
        crf.IDR_Response_Time_RG271_MS__c += calculateOpenTime(
          crf.Case_Last_Opened_RG271__c
        );
        crf.Case_Last_Opened_RG271__c = null;
      }
      if (
        !openCaseStatus.contains(cse.Status) &&
        openCaseStatus.contains(oldCase.Status)
      ) {
        crf.Total_Open_Time_MS__c += calculateOpenTime(crf.Case_Last_Opened__c);
        crf.Case_Last_Opened__c = null;
      }
      caseIdToFieldMap.put(cse.Id, crf);
    }
    return caseIdToFieldMap.values();
  }
  /**
   * @description  getReportingFieldForCases method is used query and get the map of reporting fields, and generate new reporting field records if they are not present in the database.
   * @param newRecords Last Opened Date in Date Time format
   * @return Map<ID, Case_Reporting_Field__c> includes the new & queried records of Reporting Field.
   */
  @TestVisible
  private static Map<ID, Case_Reporting_Field__c> getReportingFieldForCases(
    List<Case> newRecords
  ) {
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = new Map<ID, Case_Reporting_Field__c>();
    List<Case_Reporting_Field__c> fields = [
      SELECT
        ID,
        Name,
        Case__c,
        Case_Last_Opened__c,
        Case_Last_Opened_RG271__c,
        Total_Open_Time_MS__c,
        IDR_Response_Time_RG271_MS__c
      FROM Case_Reporting_Field__c
      WHERE Case__c IN :newRecords
    ];
    for (Case_Reporting_Field__c crf : fields) {
      caseIdToFieldMap.put(crf.Case__c, crf);
    }
    for (Case cse : newRecords) {
      if (!caseIdToFieldMap.containsKey(cse.Id)) {
        caseIdToFieldMap.put(cse.Id, initializeReportingField(cse));
      }
    }
    return caseIdToFieldMap;
  }

  /**
   * @description  initializeReportingField method initialize a new reporting field record.
   * @param cse Case Record
   * @return Case_Reporting_Field__c returns a new initialized record of Case_Reporting_Field__c
   */
  private static Case_Reporting_Field__c initializeReportingField(Case cse) {
    Case_Reporting_Field__c crf = new Case_Reporting_Field__c();
    crf.Case__c = cse.Id;
    crf.IDR_Response_Time_RG271_MS__c = 0;
    crf.Total_Open_Time_MS__c = 0;
    return crf;
  }
}
