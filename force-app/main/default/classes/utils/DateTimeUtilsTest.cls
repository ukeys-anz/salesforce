/**
 * @description Test class for {@link DateTimeUtils}
 * @author Lance Shi
 * @since April 2020
 * @group Utils
 */
@isTest
public with sharing class DateTimeUtilsTest {
  @isTest
  static void testTimeInHours() {
    Decimal hours = DateTimeUtils.calculateHoursBetween(
      1182139200000L,
      1182230855000L
    );
    System.assertEquals(25, hours.intValue(), 'Matching Hours');
    System.assertEquals(
      27,
      ((hours - hours.intValue()) * SFConstants.MIN_IN_HOUR).intValue(),
      'Matching Minutes'
    );
  }

  @isTest
  static void testTimeInHoursWithBusinessHours() {
    BusinessHours bhs = [
      SELECT id
      FROM BusinessHours
      WHERE Name = 'ANZx Case Business Hours'
    ];
    DateTime date1 = DateTime.newInstance(2020, 4, 3, 9, 8, 16);
    // Include weekends Saturday and Sunday and test its not included in hours
    DateTime date2 = DateTime.newInstance(2020, 4, 6, 10, 18, 16);
    Decimal hours = DateTimeUtils.calculateHoursBetween(
      date1,
      date2,
      (String) bhs.Id
    );
    System.assertEquals(9, hours.intValue(), 'Matching Hours');
    System.assertEquals(
      10,
      ((hours - hours.intValue()) * SFConstants.MIN_IN_HOUR).intValue(),
      'Matching Minutes'
    );
  }

  @isTest
  static void testGetLocalTime() {
    // Test converting to Australia/Sydney time (GMT+10:00)
    DateTime dt1 = DateTime.newInstanceGmt(2021, 10, 15, 20, 52, 0); // DST starts
    String result1 = DateTimeUtils.getLocalTime(
      dt1,
      'Australia/Sydney',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2021-10-16 07:52:00.000 +1100',
      result1,
      'Converted dates match.'
    );
    DateTime dt2 = DateTime.newInstanceGmt(2020, 4, 7, 3, 15, 0); // DST ends
    String result2 = DateTimeUtils.getLocalTime(
      dt2,
      'Australia/Sydney',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2020-04-07 13:15:00.000 +1000',
      result2,
      'Converted dates match.'
    );
    // Test converting to Australia/Adelaide time (GMT+09:30)
    DateTime dt3 = DateTime.newInstanceGmt(2017, 10, 4, 4, 37, 0); // DST starts
    String result3 = DateTimeUtils.getLocalTime(
      dt3,
      'Australia/Adelaide',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2017-10-04 15:07:00.000 +1030',
      result3,
      'Converted dates match.'
    );
    DateTime dt4 = DateTime.newInstanceGmt(2015, 4, 6, 18, 43, 0); // DST ends
    String result4 = DateTimeUtils.getLocalTime(
      dt4,
      'Australia/Adelaide',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2015-04-07 04:13:00.000 +0930',
      result4,
      'Converted dates match.'
    );
    // Test converting to Australia/Perth time (GMT+08:00)
    DateTime dt5 = DateTime.newInstanceGmt(2021, 7, 22, 16, 21, 0); // No DST required
    String result5 = DateTimeUtils.getLocalTime(
      dt5,
      'Australia/Perth',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2021-07-23 00:21:00.000 +0800',
      result5,
      'Converted dates match.'
    );
    // Test converting to America/Los_Angeles time (GMT-07:00)
    DateTime dt6 = DateTime.newInstanceGmt(2019, 3, 16, 4, 17, 0); // DST starts
    String result6 = DateTimeUtils.getLocalTime(
      dt6,
      'America/Los_Angeles',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2019-03-15 21:17:00.000 -0700',
      result6,
      'Converted dates match.'
    );
    DateTime dt7 = DateTime.newInstanceGmt(2018, 11, 9, 22, 15, 0); // DST ends
    String result7 = DateTimeUtils.getLocalTime(
      dt7,
      'America/Los_Angeles',
      'yyyy-MM-dd HH:mm:ss.SSS Z'
    );
    System.assertEquals(
      '2018-11-09 14:15:00.000 -0800',
      result7,
      'Converted dates match.'
    );
  }

  @isTest
  static void testGetUTCTimeFromString() {
    // Test case 1
    String startDate1 = '2021-08-03 00:00:00';
    System.assertEquals(
      '2021-08-02T14:00:00.000Z',
      DateTimeUtils.getUTCTimeFromString(startDate1),
      'UTC Times match.'
    );
    String endDate1 = '2021-08-12 23:59:59';
    System.assertEquals(
      '2021-08-12T13:59:59.000Z',
      DateTimeUtils.getUTCTimeFromString(endDate1),
      'UTC Times match.'
    );
    // Test case 2
    String startDate2 = '2018-07-03 00:00:00';
    System.assertEquals(
      '2018-07-02T14:00:00.000Z',
      DateTimeUtils.getUTCTimeFromString(startDate2),
      'UTC Times match.'
    );
    String endDate2 = '2018-07-12 23:59:59';
    System.assertEquals(
      '2018-07-12T13:59:59.000Z',
      DateTimeUtils.getUTCTimeFromString(endDate2),
      'UTC Times match.'
    );
  }
}
