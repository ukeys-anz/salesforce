/**
 *
 * @author David Dawson
 * @since 11/2020
 * @description CaseDurationObject allows the modelling of a case, broken down into status changes and totalling case duration
 */
public with sharing class CaseDurationObject {
  public List<CaseHistoryObject> history;
  public Case record;
  public Map<Id, Case> oldCaseIdToRecordMap;
  public Map<Id, List<CaseHistoryObject>> caseIdToHistory;
  @AuraEnabled
  public DurationTime caseDuration;
  public Map<Id, CaseDurationObject.DurationTime> caseIdToDurationMap;

  /**
   *
   * @description The CaseDurationObject constructor requires the recordId to initialise
   * @param recordId The Case record ID
   */
  public CaseDurationObject(Id recordId) {
    retrieveCaseRecord(recordId);

    history = new List<CaseHistoryObject>();

    buildHistoryEntries();

    calculateCaseDuration();
  }

  /**
   *
   * @description The CaseDurationObject constructor requires the List<Case> to initialise
   * @param records The Case records
   * @param oldMap old version of cases
   */
  public CaseDurationObject(List<Case> records, Map<Id, Case> oldMap) {
    caseIdToHistory = new Map<Id, List<CaseHistoryObject>>();
    caseIdToDurationMap = new Map<Id, CaseDurationObject.DurationTime>();
    oldCaseIdToRecordMap = oldMap;
    Set<Id> caseIds = ListUtil.getIds(records, Case.Id);
    buildHistoryEntries(caseIds);
    calculateCaseDurationForEachCase();
  }

  /**
   * @description If the user has access to the relevant objects, retrieve the case record from the system or throw an error otherwise
   * @param recordId The Case record ID
   */
  private void retrieveCaseRecord(Id recordId) {
    if (
      !Schema.sObjectType.Case.fields.CaseNumber.isAccessible() ||
      !Schema.sObjectType.CaseHistory.fields.CaseId.isAccessible()
    ) {
      Logger.error(
        'To calculate the case duration, access to both the Case and CaseHistory objects is required.'
      );
      Logger.saveLog();
      new CaseDurationCalculationException(
        'To calculate the case duration, access to both the Case and CaseHistory objects is required.'
      );
    }
    record = [
      SELECT
        Id,
        CaseNumber,
        CreatedDate,
        LastModifiedDate,
        BusinessHoursId,
        Status
      FROM Case
      WHERE Id = :recordId
      LIMIT 1
    ];
  }

  /**
    @description Query the CaseHistory table and construct a collection of entries on each status change
    */
  private void buildHistoryEntries() {
    DateTime lastDateTime = system.NOW();
    List<CaseHistory> caseHistory = new List<CaseHistory>(
      [
        SELECT Id, NewValue, OldValue, CaseId, CreatedDate
        FROM CaseHistory
        WHERE CaseId = :record.Id AND Field = 'Status'
        ORDER BY CreatedDate DESC
      ]
    );
    history.addAll(fetchCaseHistoryForCase(caseHistory, lastDateTime, record));
  }

  /**
    @description get case history and construct a collection of entries on each status change
    * @param caseHistory the list of case history 
    * @param lastDateTime last date time
    * @param record The Case record 
    * @return `lstCaseHistoryObj` list of case history object
    */
  private List<CaseHistoryObject> fetchCaseHistoryForCase(
    List<CaseHistory> caseHistory,
    DateTime lastDateTime,
    Case record
  ) {
    List<CaseHistoryObject> lstCaseHistoryObj = new List<CaseHistoryObject>();
    for (CaseHistory historyRecord : caseHistory) {
      lstCaseHistoryObj.add(
        new CaseHistoryObject(
          (String) historyRecord.NewValue,
          historyRecord.CreatedDate,
          lastDateTime,
          record.BusinessHoursId
        )
      );
      lastDateTime = historyRecord.CreatedDate;
    }
    lstCaseHistoryObj.add(
      new CaseHistoryObject(
        !caseHistory.isEmpty()
          ? (String) caseHistory[caseHistory.size() - 1].OldValue
          : record.Status,
        record.CreatedDate,
        lastDateTime,
        record.BusinessHoursId
      )
    );
    return lstCaseHistoryObj;
  }

  /**
    @description Query the CaseHistory table and construct a collection of entries on each status change
    * @param caseIds The set of case records
    */
  private void buildHistoryEntries(Set<Id> caseIds) {
    DateTime lastDateTime = system.NOW();
    Map<Id, List<CaseHistory>> caseIdToCaseHistory = new Map<Id, List<CaseHistory>>();

    List<CaseHistory> caseHistory = new List<CaseHistory>(
      [
        SELECT Id, NewValue, OldValue, CaseId, CreatedDate
        FROM CaseHistory
        WHERE CaseId IN :caseIds AND Field = 'Status'
        ORDER BY CreatedDate DESC
      ]
    );

    for (CaseHistory history : caseHistory) {
      if (!caseIdToCaseHistory.containsKey(history.CaseId)) {
        caseIdToCaseHistory.put(history.CaseId, new List<CaseHistory>());
      }
      caseIdToCaseHistory.get(history.CaseId).add(history);
    }

    for (Id caseId : caseIdToCaseHistory.keySet()) {
      List<CaseHistory> caseHistoryForEachHistory = caseIdToCaseHistory.get(
        caseId
      );
      List<CaseHistoryObject> lstCaseHistoryObject = fetchCaseHistoryForCase(
        caseHistoryForEachHistory,
        lastDateTime,
        oldCaseIdToRecordMap.get(caseId)
      );
      caseIdToHistory.put(caseId, lstCaseHistoryObject);
    }

    if (caseHistory.isEmpty()) {
      for (Id caseRecordId : caseIds) {
        List<CaseHistoryObject> caseHistoryObjectList = fetchCaseHistoryForCase(
          new List<CaseHistory>(),
          lastDateTime,
          oldCaseIdToRecordMap.get(caseRecordId)
        );
        caseIdToHistory.put(caseRecordId, caseHistoryObjectList);
      }
    }
  }

  /**
    @description Get total case duration based on business hours and statuses that do not contribute to the total
    */
  @testVisible
  private void calculateCaseDuration() {
    Decimal totalHours = getTotalHours(history);
    caseDuration = new DurationTime(totalHours);
  }

  /**
    @description Loop through the history entries and determine the total case duration based on business hours and statuses that do not contribute to the total
    * @param caseHistories List of case history object
    * @return `totalHours` total hours
    */
  private static Decimal getTotalHours(List<CaseHistoryObject> caseHistories) {
    Decimal totalHours = 0;
    for (CaseHistoryObject entry : caseHistories) {
      if (!SFConstants.TIMER_PAUSE_STATUSES.contains(entry.status)) {
        totalHours = totalHours + entry.duration;
      }
    }
    return totalHours;
  }

  /**
    @description Loop through the history entries and determine the total case duration based on business hours and statuses that do not contribute to the total
    */
  @testVisible
  private void calculateCaseDurationForEachCase() {
    for (Id caseId : caseIdToHistory.keySet()) {
      Decimal totalHours = getTotalHours(caseIdToHistory.get(caseId));
      caseIdToDurationMap.put(caseId, new DurationTime(totalHours));
    }
  }

  /**
@description wrapper class of the duration time
*/
  public class DurationTime {
    @AuraEnabled
    public long hours;
    @AuraEnabled
    public long minutes;
    public Decimal dHours;
    /**
     *
     * @description The DurationTime constructor requires the time in hours in decimal format to initialise
     * @param decimalHours The decimal form of the time between two datetimes
     */
    public DurationTime(Decimal decimalHours) {
      dHours = decimalHours;
      hours = decimalHours.longValue();
      minutes = ((decimalHours - hours) * SFConstants.MIN_IN_HOUR).longValue();
    }
  }

  /**
@description extend the Exception class to allow errors to be thrown if the user does not have access
*/
  private class CaseDurationCalculationException extends Exception {
  }
}
