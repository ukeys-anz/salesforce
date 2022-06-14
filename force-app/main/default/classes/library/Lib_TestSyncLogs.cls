/**
 * @author David Dawson
 * @date April 2020
 * @description Test class for {@link Lib_TestSync}
 * @group Library
 */
@isTest
public class Lib_TestSyncLogs {
  static void setup() {
    BigObjectHelper bigObjectHelper = (BigObjectHelper) Lib_MockService.createMock(
      BigObjectHelper.class,
      new Map<String, Object>{ 'insertBigObject' => true }
    );

    Lib_SystemLog.bigObjectHelper = bigObjectHelper;
  }

  @isTest
  static void testSingleLog() {
    setup();
    Test.startTest();

    // GIVEN a single log record is created
    // WHEN the log is inserted
    Boolean result = Lib_SystemLog.createSingleLog(
      'Process',
      'Function',
      '1111',
      'Desc',
      Lib_SystemLog.Severity.ERROR
    );

    Test.stopTest();
    System.assertEquals(
      true,
      result,
      'The createSingleLog method should return true.'
    );
  }

  @isTest
  static void testLogAPIError() {
    setup();
    Test.startTest();

    // GIVEN a single api log record is created
    // WHEN the log is inserted
    Boolean result = Lib_SystemLog.logAPIError(
      'SomeProcess',
      'SomeMethod',
      'Failed',
      '200',
      'Request body',
      'Response body',
      'RequestEndpoint',
      HTTP_METHOD.HTTP_GET.name(),
      500
    );
    Test.stopTest();
    System.assertEquals(
      true,
      result,
      'The logAPIError method should return true.'
    );
  }

  @isTest
  static void testMultipleLogs() {
    setup();
    // GIVEN multiple log records are created
    Lib_SystemLog log = new Lib_SystemLog('Test Process', 'getSomething');

    Test.startTest();

    // WHEN the logs are inserted
    log.addMessage('100', 'An error occurred', Lib_SystemLog.Severity.ERROR);
    log.addMessageWithRequestResponse(
      '200',
      'Some Info',
      Lib_SystemLog.Severity.INFO,
      'https//:endpoint',
      HTTP_METHOD.HTTP_GET.name(),
      200,
      'Request Body',
      'Response Body'
    );
    log.addObjectMessage(
      'Account',
      '00000',
      '300',
      'An error occurred',
      Lib_SystemLog.Severity.FATAL
    );

    System.assertNotEquals(
      0,
      log.logList.size(),
      'Log list size should be as expected.'
    );

    log.insertLog();

    Test.stopTest();

    System.assertEquals(
      0,
      log.logList.size(),
      'Log list size should be as expected.'
    );
  }

  @isTest
  static void testDatabaseSaveResultError() {
    setup();
    // GIVEN a programmatic database insert fails
    Contact c = new Contact();
    Lib_SystemLog log = new Lib_SystemLog('Contacts', 'saveContact');

    Test.startTest();

    // WHEN the event is captured in a log and inserted

    Database.SaveResult sr = Database.insert(c, false);
    if (!sr.isSuccess()) {
      log.addDatabaseSaveResult(
        'Contact',
        new List<Database.SaveResult>{ sr },
        new List<Contact>{ c }
      );
    }

    System.assertNotEquals(
      0,
      log.logList.size(),
      'Log list size should be as expected.'
    );

    log.insertLog();

    Test.stopTest();

    System.assertEquals(
      0,
      log.logList.size(),
      'Log list size should be as expected.'
    );
  }
}
