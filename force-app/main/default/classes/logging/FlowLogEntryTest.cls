/**
 * @author Prakash B
 * @since Oct 2022
 * @group Logging
 * @description Test class for the FlowLogEntry class
 */
@isTest
private class FlowLogEntryTest {
  static FlowLogEntry createFlowLogEntry() {
    FlowLogEntry flowEntry = new FlowLogEntry();
    flowEntry.flowName = 'Test Flow Logs';
    flowEntry.message = 'Test Log Entry Message';

    return flowEntry;
  }

  @isTest
  static void testSuccessfulLogEntryCreationOnLoggingLevel() {
    LoggingLevel userLoggingLevel = LoggingLevel.FINEST;
    LoggingLevel flowEntryLoggingLevel = LoggingLevel.DEBUG;
    System.assert(
      userLoggingLevel.ordinal() < flowEntryLoggingLevel.ordinal(),
      'User Logging level should be less than flow logging level'
    );

    FlowLogEntry flowEntry = createFlowLogEntry();
    Test.startTest();
    FlowLogEntry.addFlowEntries(new List<FlowLogEntry>{ flowEntry });
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT LogMessage__c, Origin__c, ComponentName__c
      FROM LogEntry__c
      LIMIT 1
    ];
    System.assertEquals(
      'Flow',
      logEntry.Origin__c,
      'Origin should be marked as Flow'
    );
    System.assertEquals(
      flowEntry.message,
      logEntry.LogMessage__c,
      'Message should match'
    );
    System.assertEquals(
      flowEntry.flowName,
      logEntry.ComponentName__c,
      'Component name should match'
    );
  }

  @isTest
  static void testLogEntrywithFaultMessage() {
    LoggingLevel expectedEntryLoggingLevel = LoggingLevel.ERROR;
    FlowLogEntry flowEntry = createFlowLogEntry();
    flowEntry.faultMessage = 'Whoops, a Flow error has occurred.';

    Test.startTest();
    FlowLogEntry.addFlowEntries(new List<FlowLogEntry>{ flowEntry });
    Test.stopTest();

    LogEntry__c logEntry = [
      SELECT
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
      flowEntry.faultMessage,
      logEntry.ExceptionMessage__c,
      'Fault message should be updated in Exception message'
    );
    System.assertEquals(
      'Flow.FaultError',
      logEntry.ExceptionType__c,
      'Exception Type should match'
    );
    System.assertEquals(
      expectedEntryLoggingLevel.name(),
      logEntry.LoggingLevel__c,
      'LoggingLevels should match'
    );
    System.assertEquals(
      flowEntry.message,
      logEntry.LogMessage__c,
      'Message should get updated'
    );
  }
}
