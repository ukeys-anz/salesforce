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
   * @return Datetime final date after adding days to startDate
   */
  public static Datetime addBusinessDays(
    Id businessHrs,
    Datetime startDate,
    Integer daysToAdd
  ) {
    Datetime newDatetime = startDate;
    for (Integer i = 1; i <= daysToAdd; i++) {
      newDatetime = newDatetime.addDays(1);
      if (!BusinessHours.isWithin(businessHrs, newDatetime)) {
        newDatetime = BusinessHours.nextStartDate(BusinessHrs, newDatetime);
      }
    }

    string ausDate = newDatetime.format(
      'yyyy-MM-dd HH:mm:ss',
      'Australia/Sydney'
    ); // Format the date time Australian time zone.
    Datetime returnValue = date.valueOf(ausDate);
    return returnValue;
  }

  /**
   * @description Substract business days from a date
   * @param businessHrs Business Hours Id to consider working hours and public holidays
   * @param startDate start date in DateTime
   * @param daysToSubstract number of business days to be substracted
   * @return Datetime final date after substracting days from startDate
   */
  public static Datetime subtractBusinessDays(
    Id businessHrs,
    Datetime startDate,
    Integer daysToSubtract
  ) {
    Datetime newDatetime = startDate;
    for (Integer i = 1; i <= daysToSubstract; i++) {
      newDatetime = getPreviousBusinessDay(
        businessHrs,
        newDatetime.addDays(-1)
      );
    }

    string ausDate = newDatetime.format(
      'yyyy-MM-dd HH:mm:ss',
      'Australia/Sydney'
    ); // Format the date time Australian time zone.
    Datetime returnValue = date.valueOf(ausDate);
    return returnValue;
  }

  /**
   * @description Recursive function to get previous working day
   * If date passed to this function is on a working day, this will return same date
   * If date passed to this function is not on a working day, this will return previous working day
   * *********************
   * For Example, if day passed to this function is Monday, this will return Monday
   * but if day passed to the function is Sunday, then this will return Friday
   * *********************
   * @param businessHrsId BusinessHours Id
   * @param startDate Datetime to operate on
   * @return `Datetime`
   */
  private static Datetime getPreviousBusinessDay(
    Id businessHrsId,
    Datetime startDate
  ) {
    //Check if new date is within business days
    if (!BusinessHours.isWithin(businessHrsId, startDate)) {
      //New date is not within business days, recursively call same function to get previous date by subtracting 1 day
      startDate = startDate.addDays(-1);
      return getPreviousBusinessDay(businessHrsId, startDate);
    } else {
      //New date is within business days, return this date
      return startDate;
    }
  }

  /**
   *@description Calculate local time based on user time zone.
   * @param utcDateTime UTC Datetime to be converted to local time
   * @param timezone the timezone used to convert Datetime
   * @param format the desired format for the converted Datetime
   * @return Datetime the local date time based on user's timezone
   */
  public static String getLocalTime(
    DateTime utcDateTime,
    String timezone,
    String format
  ) {
    if (
      utcDateTime != null &&
      String.isNotBlank(timezone) &&
      String.isNotBlank(format)
    ) {
      return utcDateTime.format(format, timezone);
    }
    return null;
  }

  /**
   *@description Calculate UTC time
   * @param localDateTimeString Local Datetime string to be converted to UTC Datetime
   * @return String Datetime String in the GMT time zone so we can use in param URL construction.
   */
  public static String getUTCTimeFromString(String localDateTimeString) {
    if (localDateTimeString != null) {
      return DateTime.valueOf(localDateTimeString)
        .formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
    }
    return null;
  }
}
