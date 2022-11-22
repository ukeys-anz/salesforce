/**
 * @author Prakash B
 * @since Oct 2022
 * @group Logging
 * @description Test class for the FlowCollectionLogEntry class
 */

@isTest
private class FlowCollectionLogEntryTest {
  static FlowCollectionLogEntry createFlowCollectionLogEntry() {
    FlowCollectionLogEntry flowCollectionEntry = new FlowCollectionLogEntry();
    flowCollectionEntry.flowName = 'Test Flow Logs';
    flowCollectionEntry.message = 'Test Log Entry Message';

    return flowCollectionEntry;
  }

  @isTest
  static void testSuccessfulLogEntryCreattionLoggingLevelMet() {
    User currentUser = new User(
      Id = UserInfo.getUserId(),
      FirstName = UserInfo.getFirstName(),
      LastName = UserInfo.getLastName(),
      Username = UserInfo.getUserName()
    );
    LoggingLevel userLoggingLevel = LoggingLevel.FINEST;
    LoggingLevel flowCollectionEntryLoggingLevel = LoggingLevel.DEBUG;
    System.assert(
      userLoggingLevel.ordinal() < flowCollectionEntryLoggingLevel.ordinal(),
      'User Logging level should be less than flow logging level'
    );

    FlowCollectionLogEntry flowCollectionEntry = createFlowCollectionLogEntry();
    flowCollectionEntry.records = new List<SObject>{ currentUser };

    Test.startTest();
    FlowCollectionLogEntry.addFlowCollectionEntries(
      new List<FlowCollectionLogEntry>{ flowCollectionEntry }
    );
    Logger.saveLog();
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
        RecordObjectName__c,
        ExceptionMessage__c,
        ExceptionType__c,
        LoggingLevel__c,
        LogMessage__c,
        Origin__c,
        ComponentName__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      'Flow',
      logEntry.Origin__c,
      'Origin should be marked as Flow'
    );
    System.assertEquals(
      flowCollectionEntry.message,
      logEntry.LogMessage__c,
      'Message should match'
    );
    System.assertEquals(
      flowCollectionEntry.flowName,
      logEntry.ComponentName__c,
      'Component name should match'
    );
    System.assertEquals(
      'User',
      logEntry.RecordObjectName__c,
      'Object should be updated as User'
    );
  }

  @isTest
  static void testSuccessfulLogEntryCreationwithFaultMessage() {
    FlowCollectionLogEntry flowCollectionEntry = createFlowCollectionLogEntry();
    flowCollectionEntry.faultMessage = 'Whoops, a Flow error has occurred.';

    Test.startTest();
    FlowCollectionLogEntry.addFlowCollectionEntries(
      new List<FlowCollectionLogEntry>{ flowCollectionEntry }
    );
    Logger.saveLog();
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
        RecordObjectName__c,
        ExceptionMessage__c,
        ExceptionType__c,
        LoggingLevel__c,
        LogMessage__c,
        Origin__c,
        ComponentName__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      flowCollectionEntry.faultMessage,
      logEntry.ExceptionMessage__c,
      'Exception message should match fault message'
    );
    System.assertEquals(
      'Flow.FaultError',
      logEntry.ExceptionType__c,
      'Exception type should match'
    );
    System.assertEquals(
      'Flow',
      logEntry.Origin__c,
      'Origin should be marked as Flow'
    );
    System.assertEquals(
      flowCollectionEntry.message,
      logEntry.LogMessage__c,
      'Message should match'
    );
  }
}
