/**
 * @author David Dawson
 * @date April 2020
 * @description Test class for {@link Lib_TestAsync}
 * @group Library
 */
@isTest
public class Lib_TestAsyncLogs {
  @isTest
  static void testApplicationLoggingEvent() {
    BigObjectHelper bigObjectHelper = (BigObjectHelper) Lib_MockService.createMock(
      BigObjectHelper.class,
      new Map<String, Object>{ 'insertBigObject' => true }
    );

    Lib_ApplicationLoggingEvents.bigObjectHelper = bigObjectHelper;
    // GIVEN a process throws an application log.
    lib_SystemLog sfLog = new lib_SystemLog(
      'ApplicationLogging_Event_Test',
      'testApplicationLogging_Event()'
    );
    sfLog.addMessage(
      '101',
      'something really serious failed',
      lib_systemLog.Severity.ERROR
    );

    Test.startTest();

    System.assertNotEquals(
      0,
      sfLog.logList.size(),
      'Log list size should be as expected.'
    );

    // WHEN it is published via Platform Events
    sfLog.publishEvent();

    Test.stopTest();
    System.assertEquals(
      0,
      sfLog.logList.size(),
      'Log list size should be as expected.'
    );
  }
}
