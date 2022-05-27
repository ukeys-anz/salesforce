/**
 *
 * @author David Dawson
 * @since 11/2020
 * @description CaseDurationObject allows the modelling of a case, broken down into status changes and totalling case duration
 */
public with sharing class CaseDurationObject {
  public List<CaseHistoryObject> history;
  public Case record;
  @AuraEnabled
  public DurationTime caseDuration;

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
   * @description If the user has access to the relevant objects, retrieve the case record from the system or throw an error otherwise
   * @param recordId The Case record ID
   */
  private void retrieveCaseRecord(Id recordId) {
    if (
      !Schema.sObjectType.Case.fields.CaseNumber.isAccessible() ||
      !Schema.sObjectType.CaseHistory.fields.CaseId.isAccessible()
    ) {
      Lib_SystemLog.createSingleLog(
        IDRCaseActions.class.getName(),
        'Constructor',
        null,
        'To calculate the case duration, access to both the Case and CaseHistory objects is required.',
        Lib_systemLog.Severity.ERROR
      );
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
    for (CaseHistory historyRecord : caseHistory) {
      history.add(
        new CaseHistoryObject(
          (String) historyRecord.NewValue,
          historyRecord.CreatedDate,
          lastDateTime,
          record.BusinessHoursId
        )
      );
      lastDateTime = historyRecord.CreatedDate;
    }
    history.add(
      new CaseHistoryObject(
        !caseHistory.isEmpty()
          ? (String) caseHistory[caseHistory.size() - 1].OldValue
          : record.Status,
        record.CreatedDate,
        lastDateTime,
        record.BusinessHoursId
      )
    );
  }

  /**
    @description Loop through the history entries and determine the total case duration based on business hours and statuses that do not contribute to the total
    */
  @testVisible
  private void calculateCaseDuration() {
    Decimal totalHours = 0;
    for (CaseHistoryObject entry : history) {
      if (!SFConstants.TIMER_PAUSE_STATUSES.contains(entry.status)) {
        totalHours = totalHours + entry.duration;
      }
    }
    caseDuration = new DurationTime(totalHours);
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
