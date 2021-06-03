/**
 * @description Date time utils which contains untility functions for all the Date and Time related calculations
 * @author Pavan Kumar Ananta
 * @since April 2020
 * @group Utils
 */
public with sharing class DateTimeUtils {
  /**
   * @description Calculate the difference between start and endtime in mills
   * To get the hours use .intValue() and to get minutes substract and multiply by @link{SFConstants.MIN_IN_HOUR}
   * @param startTimeInMillis start time in millis
   * @param endTimeInMillis end time in millis
   * @return `Decimal` returns difference hours in decimal eg. 25.45 which is total hours in fractional units and this is same as 25 hours and 27 minutes
   */
  public static Decimal calculateHoursBetween(
    long startTimeInMillis,
    long endTimeInMillis
  ) {
    Decimal difference = endTimeInMillis - startTimeInMillis;
    Decimal differenceHours = difference / SFConstants.TIME_TO_HOUR;
    return differenceHours.setScale(4, RoundingMode.HALF_UP);
  }

  /**
   *@description Calculate the difference between start and endtime in mills
   * To get the hours use .intValue() and to get minutes substract and multiply by @link{SFConstants.MIN_IN_HOUR}
   * @param startTime start time in DateTime
   * @param endTime end Time in DateTime
   * @param businessHourId Business Hours Id to consider working hours and public holidays
   * @return `Decimal` returns difference hours in decimal eg. 25.45 and this is same as 25 hours and 27 minutes
   */
  public static Decimal calculateHoursBetween(
    Datetime startTime,
    Datetime endTime,
    String businessHourId
  ) {
    Decimal difference = BusinessHours.diff(businessHourId, startTime, endTime);
    Decimal differenceHours = difference / SFConstants.TIME_TO_HOUR;
    return differenceHours.setScale(4, RoundingMode.HALF_UP);
  }
  /**
   *@description Add business days to a date.
   *@param businessHrs Business Hours Id to consider working hours and public holidays
   * @param startDate start date in DateTime
   * @param daysToAdd number of business days to be added
   * @return datetime final date after adding days to startDate
   */
  public static datetime addBusinessDays(
    id businessHrs,
    datetime startDate,
    integer daysToAdd
  ) {
    datetime newDatetime = startDate;
    for (integer i = 1; i <= daysToAdd; i++) {
      newDatetime = newDatetime.addDays(1);
      if (!BusinessHours.isWithin(businessHrs, newDatetime)) {
        newDatetime = BusinessHours.nextStartDate(BusinessHrs, newDatetime);
      }
    }

    string ausDate = newDatetime.format(
      'yyyy-MM-dd HH:mm:ss',
      'Australia/Sydney'
    ); // Format the date time Australian time zone.
    datetime returnValue = date.valueOf(ausDate);
    return returnValue;
  }
}
