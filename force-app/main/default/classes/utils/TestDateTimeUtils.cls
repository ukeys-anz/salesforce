@isTest
public with sharing class TestDateTimeUtils {
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
      WHERE Name = 'Case Business Hours'
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
}
