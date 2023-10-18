/**
 * @author Arpit
 * @since July 2023
 * @description Test Class for GoogleType class
 */
@isTest
public with sharing class GoogleTypeTest {
  @isTest
  static void testGoogleDate() {
    Date today = System.today();
    Integer year = today.year();
    Integer month = today.month();
    Integer day = today.day();
    GoogleType.GoogleDate d1 = new GoogleType.GoogleDate(year, month, day);

    Assert.areEqual(d1.year, year);
    Assert.areEqual(d1.month, month);
    Assert.areEqual(d1.day, day);
    Assert.areEqual(d1.value(), today);
  }

  @isTest
  static void testTimeOfDay() {
    Time today = System.now().time();
    Integer hours = today.hour();
    Integer minutes = today.minute();
    Integer seconds = today.second();
    Integer nanos = today.millisecond();

    GoogleType.TimeOfDay d1 = new GoogleType.TimeOfDay(
      hours,
      minutes,
      seconds,
      nanos
    );

    Assert.areEqual(d1.hours, hours);
    Assert.areEqual(d1.minutes, minutes);
    Assert.areEqual(d1.seconds, seconds);
    Assert.areEqual(d1.nanos, nanos);
    Assert.areEqual(d1.value(), today);
  }
}
