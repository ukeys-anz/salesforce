/**
 *
 * @author David Dawson
 * @since 11/2020
 * @description CaseHistoryObject allows the modelling of the status changes from CaseHistory into when the case changed to that status, when the status ended and the time difference it has remained in this status
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class CaseHistoryObject {
  public String status;
  public DateTime startDateTime;
  public DateTime endDateTime;
  public Id businessHoursId;
  public Decimal duration;

  /**
   *
   * @description The CaseHistoryObject is initialised by settings all of the values in the object constructor
   * @param status The status of the case during this time period
   * @param startDateTime The DateTime of when the case became this status
   * @param endDateTime The DateTime of when the case is no longer this status (or NOW if it is the current status to allow calculation)
   * @param businessHoursId The business hours are required to do the time calculation, it should be passed through from the case record
   */
  public CaseHistoryObject(
    String status,
    DateTime startDateTime,
    DateTime endDateTime,
    Id businessHoursId
  ) {
    this.status = status;
    this.startDateTime = startDateTime;
    this.endDateTime = endDateTime;
    this.businessHoursId = businessHoursId;

    duration = DateTimeUtils.calculateHoursBetween(
      startDateTime,
      endDateTime,
      businessHoursId
    );
  }
}
