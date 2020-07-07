/**
 * @description Date time utils which contains untility functions for all the Date and Time related calculations
 * @author Pavan Kumar Ananta
 * @since April 2020
 */
public without sharing class DateTimeUtils {
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
    return differenceHours.setScale(2, RoundingMode.HALF_UP);
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
    return differenceHours.setScale(2, RoundingMode.HALF_UP);
  }
}
