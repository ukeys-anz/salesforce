/**
 * @author Arpit
 * @since July 2023
 * @description This Class provides Google specific type models
 */
@SuppressWarnings(
  'PMD.FieldNamingConventions,PMD.FormalParameterNamingConventions'
)
public with sharing class GoogleType {
  /**
   * @description Represents a whole or partial calendar date, such as a birthday
   * https://github.com/googleapis/googleapis/blob/master/google/type/date.proto
   */
  public class GoogleDate {
    @AuraEnabled
    public Integer year;
    @AuraEnabled
    public Integer month;
    @AuraEnabled
    public Integer day;
    /**
     * @description Constructor to set the Google Date
     * @param year Year of the date. Must be from 1 to 9999.
     * @param month Month of a year. Must be from 1 to 12,
     * @param day Day of a month. Must be from 1 to 31 and valid for the year and month
     */
    public GoogleDate(Integer year, Integer month, Integer day) {
      this.year = year;
      this.month = month;
      this.day = day;
    }
    /**
     * @description converts Google Date into Salesforce Date value
     * @return `Date` format as stored in salesforce.
     */
    public Date value() {
      if (this.year != null && this.month != null && this.day != null) {
        return Date.newInstance(this.year, this.month, this.day);
      } else {
        return null;
      }
    }
  }

  /**
   * @description Represents a whole or partial time of day
   * https://github.com/googleapis/googleapis/blob/master/google/type/timeofday.proto
   */
  public class TimeOfDay {
    @AuraEnabled
    public Integer hours;
    @AuraEnabled
    public Integer minutes;
    @AuraEnabled
    public Integer seconds;
    @AuraEnabled
    public Integer nanos;
    /**
     * @description Constructor to set the Google Time of day
     * @param hours hours of the day. Must be from 0 to 23.
     * @param minutes minutes of the day. Must be from 0 to 59.
     * @param seconds seconds of the day. Must be from 0 to 59.
     * @param nanos fractions of the seconds. Must be from 0 to 999,999,999
     */
    public TimeOfDay(
      Integer hours,
      Integer minutes,
      Integer seconds,
      Integer nanos
    ) {
      this.hours = hours;
      this.minutes = minutes;
      this.seconds = seconds;
      this.nanos = nanos;
    }
    /**
     * @description converts Fabric Date into Salesforce Date value
     * @return `Time` format as stored in salesforce.
     */
    public Time value() {
      if (
        this.hours != null &&
        this.minutes != null &&
        this.seconds != null &&
        this.nanos != null
      ) {
        return Time.newInstance(
          this.hours,
          this.minutes,
          this.seconds,
          this.nanos
        );
      } else {
        return null;
      }
    }
  }
}
