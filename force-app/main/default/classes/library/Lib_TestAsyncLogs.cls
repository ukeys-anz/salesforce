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
    // GIVEN a process throws an application log.
    lib_SystemLog sfLog = new lib_SystemLog();
    sfLog.addMessage(
      '101',
      'something really serious failed',
      lib_systemLog.Severity.ERROR
    );

    Test.startTest();

    // WHEN it is published via Platform Events
    sfLog.publishEvent();
    Test.getEventBus().deliver();
    List<Application_Log__c> applicationLogs = [
      SELECT Id, Process_Name__c, Function_Name__c
      FROM Application_Log__c
    ];
    // THEN application log record(s) should be created
    System.assert(applicationLogs.size() > 0);
    System.assertEquals(
      'Lib_TestAsyncLogs',
      applicationLogs[0].Process_Name__c
    );
    System.assertEquals(
      'testApplicationLoggingEvent',
      applicationLogs[0].Function_Name__c
    );

    Test.stopTest();
  }
}
