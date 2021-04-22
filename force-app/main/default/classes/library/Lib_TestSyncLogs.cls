/**
 * @author David Dawson
 * @date April 2020
 * @description Test class for {@link Lib_TestSync}
 * @group Library
 */
@isTest
public class Lib_TestSyncLogs {
  @isTest
  static void testSingleLog() {
    Test.startTest();

    // GIVEN a single log record is created
    // WHEN the log is inserted
    lib_SystemLog.createSingleLog(
      'Process',
      'Function',
      '1111',
      'Desc',
      lib_SystemLog.Severity.ERROR
    );

    Test.stopTest();

    // THEN an application log record should be created
    List<Application_Log__c> appLog = [SELECT Id FROM Application_Log__c];
    System.assertEquals(1, appLog.size(), 'Matches the log record size');
  }

  @isTest
  static void testLogAPIError() {
    Test.startTest();

    // GIVEN a single api log record is created
    // WHEN the log is inserted
    lib_SystemLog.logAPIError(
      'SomeProcess',
      'SomeMethod',
      'Failed',
      '200',
      '0000',
      'Request body',
      'Response body'
    );

    Test.stopTest();

    // THEN an application log record should be created
    List<Application_Log__c> appLog = [
      SELECT Id, Request_Body__c
      FROM Application_Log__c
    ];
    System.assertEquals(1, appLog.size(), 'Matches the log record size');
    System.assert(
      applog[0].Request_Body__c.length() > 0,
      'Request body has content'
    );
  }

  @isTest
  static void testMultipleLogs() {
    // GIVEN multiple log records are created
    lib_SystemLog log = new lib_SystemLog('Test Process', 'getSomething');

    Test.startTest();

    // WHEN the logs are inserted
    log.addMessage('100', 'An error occurred', lib_SystemLog.Severity.ERROR);
    log.addMessageWithRequestResponse(
      '200',
      'Some Info',
      lib_SystemLog.Severity.INFO,
      'Request Body',
      'Response Body'
    );
    log.addObjectMessage(
      'Account',
      '00000',
      '300',
      'An error occurred',
      lib_SystemLog.Severity.FATAL
    );

    log.insertLog();

    Test.stopTest();

    // THEN an application log record should be created for each log recorded
    List<Application_Log__c> appLog = [SELECT Id FROM Application_Log__c];
    System.assertEquals(3, appLog.size(), 'Matches the log record size');
  }

  @isTest
  static void testDatabaseSaveResultError() {
    // GIVEN a programmatic database insert fails
    Contact c = new Contact();
    lib_SystemLog log = new lib_SystemLog('Contacts', 'saveContact');

    Test.startTest();

    // WHEN the event is captured in a log and inserted
    String errorCode = log.getLogErrorCode();

    Database.SaveResult sr = Database.insert(c, false);
    if (!sr.isSuccess()) {
      log.addDatabaseSaveResult(
        'Contact',
        new List<Database.SaveResult>{ sr },
        new List<Contact>{ c }
      );
    }

    log.insertLog();
    System.debug(LoggingLevel.DEBUG, log.Log[0]);
    errorCode = log.getLogErrorCode();

    Test.stopTest();

    // THEN an application log record should be created
    List<Application_Log__c> appLog = [SELECT Id FROM Application_Log__c];
    System.assertEquals(1, appLog.size(), 'Matches the log record size');
  }
}
