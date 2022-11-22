/**
 * @description       : Test class for LWC Logger class
 * @author            : Prakash B
 * @group             : Logging
 * @last modified on  : 11-15-2022
 **/
@isTest
private class LWCLoggerTest {
  @isTest
  static void testSuccesfulLogEntryCreation() {
    User currentUser = new User(
      FirstName = UserInfo.getFirstName(),
      Id = UserInfo.getUserId(),
      ProfileId = UserInfo.getProfileId()
    );
    ComponentLogEntry componentLogEntry = new ComponentLogEntry();
    componentLogEntry.loggingLevel = LoggingLevel.ERROR.name();
    componentLogEntry.message = 'Test Log Entry Creation';
    componentLogEntry.recordId = currentUser.Id;
    componentLogEntry.record = currentUser;
    componentLogEntry.timestamp = System.now().addDays(-1 / 24);

    Test.startTest();
    LWCLogger.saveComponentLogEntries(
      new List<ComponentLogEntry>{ componentLogEntry },
      null
    );
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
        LogMessage__c,
        Origin__c,
        RecordObjectName__c,
        RecordId__c,
        LoggingLevel__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      componentLogEntry.loggingLevel,
      logEntry.LoggingLevel__c,
      'Logging level should match'
    );
    System.assertEquals(
      componentLogEntry.message,
      logEntry.LogMessage__c,
      'Log Message should be updated'
    );
    System.assertEquals(
      componentLogEntry.recordId,
      logEntry.RecordId__c,
      'Record Id should be updated'
    );
    System.assertEquals(
      Schema.SObjectType.User.getName(),
      logEntry.RecordObjectName__c,
      'Object name should be updated'
    );
  }

  @isTest
  static void testLogEntrywithJSError() {
    User currentUser = new User(
      FirstName = UserInfo.getFirstName(),
      Id = UserInfo.getUserId(),
      ProfileId = UserInfo.getProfileId()
    );
    ComponentError mockComponentError = new ComponentError();
    mockComponentError.message = 'Java Script Error';
    mockComponentError.stack = 'Stack \nTrace \nString';
    mockComponentError.type = 'JavaScript.ReferenceError';

    ComponentLogEntry componentLogEntry = new ComponentLogEntry();
    componentLogEntry.error = mockComponentError;
    componentLogEntry.loggingLevel = LoggingLevel.ERROR.name();
    componentLogEntry.message = 'Log JS Error';
    componentLogEntry.recordId = currentUser.Id;
    componentLogEntry.record = currentUser;
    componentLogEntry.timestamp = System.now().addDays(-1 / 24);

    Test.startTest();
    LWCLogger.saveComponentLogEntries(
      new List<ComponentLogEntry>{ componentLogEntry },
      null
    );
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
        LogMessage__c,
        LoggingLevel__c,
        RecordObjectName__c,
        RecordId__c,
        ExceptionMessage__c,
        ExceptionType__c,
        StackTrace__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      componentLogEntry.loggingLevel,
      logEntry.LoggingLevel__c,
      'Logging level should match'
    );
    System.assertEquals(
      componentLogEntry.message,
      logEntry.LogMessage__c,
      'Log Message should be updated'
    );
    System.assertEquals(
      componentLogEntry.error.message,
      logEntry.ExceptionMessage__c,
      'Exception Message should be updated'
    );
    System.assertEquals(
      componentLogEntry.error.type,
      logEntry.ExceptionType__c,
      'Exception Type should be updated'
    );
  }

  @isTest
  static void testLogEntryApexError() {
    User currentUser = new User(
      FirstName = UserInfo.getFirstName(),
      Id = UserInfo.getUserId(),
      ProfileId = UserInfo.getProfileId()
    );
    Exception mockApexException = new DmlException('Too many DML statements');
    ComponentError mockComponentError = new ComponentError();
    mockComponentError.message = mockApexException.getMessage();
    mockComponentError.stack = mockApexException.getStackTraceString();
    mockComponentError.type = mockApexException.getTypeName();

    ComponentLogEntry componentLogEntry = new ComponentLogEntry();
    componentLogEntry.error = mockComponentError;
    componentLogEntry.loggingLevel = LoggingLevel.ERROR.name();
    componentLogEntry.message = 'Apex Error';
    componentLogEntry.recordId = currentUser.Id;
    componentLogEntry.record = currentUser;
    componentLogEntry.timestamp = System.now().addDays(-1 / 24);

    Test.startTest();
    LWCLogger.saveComponentLogEntries(
      new List<ComponentLogEntry>{ componentLogEntry },
      null
    );
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
        LogMessage__c,
        LoggingLevel__c,
        RecordObjectName__c,
        RecordId__c,
        ExceptionMessage__c,
        ExceptionType__c,
        StackTrace__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      componentLogEntry.loggingLevel,
      logEntry.LoggingLevel__c,
      'Logging level should match'
    );
    System.assertEquals(
      componentLogEntry.message,
      logEntry.LogMessage__c,
      'Log Message should be updated'
    );
    System.assertEquals(
      componentLogEntry.error.message,
      logEntry.ExceptionMessage__c,
      'Exception Message should be updated'
    );
    System.assertEquals(
      componentLogEntry.error.type,
      logEntry.ExceptionType__c,
      'Exception Type should be updated'
    );
  }
}
