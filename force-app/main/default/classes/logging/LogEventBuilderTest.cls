/**
 * @author Jasmine Nguyen
 * @since June 2022
 * @description Test class for {@link LogEventBuilder}
 */

@SuppressWarnings(
  'PMD.AvoidHardcodingId'
) // PMD.AvoidHardcodingId - The hardcoded Id is used for deserialisation so will not caused issue when deployed to another environment. Cannot use random string as Apex requires a correctly formatted Id.
@isTest
public with sharing class LogEventBuilderTest {
  private static final String MOCK_STD_DATABASE_RESULT_WITH_ERROR = '{"success":false,"id":"0012N00000ABCDEQA5","errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}]}';
  private static final String MOCK_STD_DATABASE_RESULT_WITHOUT_ERROR = '{"id":"5002N00000E5ndCQAR","success":true,"errors":[]}';

  private static final String MOCK_MERGE_DATABASE_RESULT_WITH_ERROR = '{"updatedRelatedIds":null,"success":false,"mergedRecordIds":null,"id":"0012N00000ABCDEQA5","errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}]}';
  private static final String MOCK_MERGE_DATABASE_RESULT_WITHOUT_ERROR = '{"errors":null,"id":"5002N00000E5ndCQAR","mergedRecordIds":["5002N00000E5ndCQAR"],"success":true,"updatedRelatedIds":[]}';

  private static final String MOCK_UPSERT_DATABASE_RESULT_WITH_ERROR = '{"success":false,"id":"0012N00000ABCDEQA5","errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}],"created":false}';
  private static final String MOCK_UPSERT_DATABASE_RESULT_WITHOUT_ERROR = '{"id":"5002N00000E5ndCQAR","success":true,"errors":[],"created":true}';

  private static final String MOCK_UNDELETE_DATABASE_RESULT_WITHOUT_ERROR = '{"id":"5002N00000E5ndCQAR","success":true}';

  private static final String MOCK_CASE = '{"Id":"5002N00000E5ndCQAR","RecordTypeId":"0122N000003T83iQAC"}';

  @isTest
  static void testLogEventBuilderShouldSave() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.FINE, true);
    LogEvent__e logEvent = builder.getLogEvent();

    // Assert transaction details
    System.assertEquals(
      LogEventBuilder.API_VERSION,
      logEvent.APIVersion__c,
      'API version should match'
    );
    System.assertEquals(
      LogEventBuilderHelper.CACHED_ORGANIZATION_ENVIRONMENT_TYPE,
      logEvent.EnvironmentType__c,
      'Environment type should match'
    );
    System.assertEquals(
      LogEventBuilderHelper.CACHED_ORGANIZATION.InstanceName,
      logEvent.InstanceName__c,
      'Instance name should match'
    );
    System.assertEquals(
      LoggingLevel.FINE.name(),
      logEvent.LoggingLevel__c,
      'Logging level should match'
    );
    System.assertEquals('Apex', logEvent.Origin__c, 'Origin should match');
    System.assertNotEquals(
      null,
      logEvent.StartTime__c,
      'Start time should not be null'
    );
    System.assertEquals(
      'Synchronous Apex',
      logEvent.TransactionContext__c,
      'Transaction context should match'
    );
    System.assertEquals(
      'LogEventBuilder',
      logEvent.ApexClassName__c,
      'Apex class name should match'
    );
    System.assertEquals(
      '<init>',
      logEvent.ApexMethodName__c,
      'Apex method name should match'
    );
    System.assertNotEquals(
      null,
      logEvent.SpanId__c,
      'Span Id should not be null'
    );

    // Assert governor limits
    System.assertEquals(
      0,
      logEvent.UsedCallouts__c,
      'Used callouts should be 0'
    );
    System.assertNotEquals(
      0,
      logEvent.UsedCPUTime__c,
      'Used CPU Time should not be 0'
    );
    System.assertEquals(
      0,
      logEvent.UsedDMLStatements__c,
      'Used DML statements should be 0'
    );
    System.assertEquals(
      0,
      logEvent.UsedFutureCalls__c,
      'Used future calls should be 0'
    );
    System.assertNotEquals(
      0,
      logEvent.UsedHeapSize__c,
      'Used heap size should not be 0'
    );
    System.assertEquals(
      0,
      logEvent.UsedQueueableJobs__c,
      'Used queueable jobs should be 0'
    );
    System.assertNotEquals(
      0,
      logEvent.UsedSOQLQueries__c,
      'Used SOQL queries should not be 0'
    );

    // Assert user details
    System.assertEquals(
      LogEventBuilderHelper.CACHED_USER.Profile.Name,
      logEvent.UserProfile__c,
      'User profile should match'
    );
    System.assertEquals(
      LogEventBuilderHelper.CACHED_USER.UserRole.Name,
      logEvent.UserRole__c,
      'User role should match'
    );
  }

  @isTest
  static void testLogEventBuilderShouldNotSave() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, false);
    System.assertEquals(
      null,
      builder.getLogEvent(),
      'Log event should be null'
    );
  }

  @isTest
  static void testSetMessage() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setMessage('This is a test message');

    System.assertEquals(
      'This is a test message',
      builder.getLogEvent().LogMessage__c,
      'Log massage should match'
    );
  }

  @isTest
  static void testExceptionDetails() {
    DMLException dmlException = new DMLException('Test DML exception');
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.ERROR, true);
    builder.setExceptionDetails(dmlException);

    System.assertEquals(
      'Test DML exception',
      builder.getLogEvent().ExceptionMessage__c,
      'Exception message should match'
    );
    System.assertEquals(
      dmlException.getTypeName(),
      builder.getLogEvent().ExceptionType__c,
      'Exception type should match'
    );
  }

  @isTest
  static void testExceptionDetailsNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.ERROR, true);
    LogEvent__e eventBeforeSettingException = builder.getLogEvent();
    DmlException dmlException;
    builder.setExceptionDetails(dmlException);

    System.assertEquals(
      eventBeforeSettingException,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetDatabaseSaveResultWithoutError() {
    Case testCase = getMockCase();
    Database.SaveResult sr = TestUtil.getMockSaveResult(
      MOCK_STD_DATABASE_RESULT_WITHOUT_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(sr);

    System.assertEquals(
      testCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assert(
      String.isBlank(builder.getLogEvent().DatabaseResult__c),
      'Database Result should be empty as there was no error'
    );
  }

  @isTest
  static void testSetDatabaseSaveResultWithError() {
    Database.SaveResult sr = TestUtil.getMockSaveResult(
      MOCK_STD_DATABASE_RESULT_WITH_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(sr);

    System.assertEquals(
      '0012N00000ABCDEQA5',
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    // The result is returned as a list so adding the square brackets so the string can be identical for comparison purpose
    // Also delete whitespaces as pretty JSON are difficult to compare
    System.assertEquals(
      '[' +
      MOCK_STD_DATABASE_RESULT_WITH_ERROR +
      ']',
      builder.getLogEvent().DatabaseResult__c.deleteWhitespace(),
      'Database Result should match the serialised save result'
    );
  }

  @isTest
  static void testSetDatabaseSaveResultNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingDbResult = builder.getLogEvent();
    List<Database.SaveResult> saveResult;
    builder.setDatabaseResult(saveResult);

    System.assertEquals(
      eventBeforeSettingDbResult,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetDatabaseDeleteResultWithoutError() {
    Case testCase = getMockCase();
    Database.DeleteResult dr = TestUtil.getMockDeleteResult(
      MOCK_STD_DATABASE_RESULT_WITHOUT_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(dr);

    System.assertEquals(
      testCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assert(
      String.isBlank(builder.getLogEvent().DatabaseResult__c),
      'Database Result should be empty as there was no error'
    );
  }

  @isTest
  static void testSetDatabaseDeleteResultWithError() {
    Database.DeleteResult dr = TestUtil.getMockDeleteResult(
      MOCK_STD_DATABASE_RESULT_WITH_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(dr);

    // The result is returned as a list so adding the square brackets so the string can be identical for comparison purpose
    // Also delete whitespaces as pretty JSON are difficult to compare
    System.assertEquals(
      '[' +
      MOCK_STD_DATABASE_RESULT_WITH_ERROR +
      ']',
      builder.getLogEvent().DatabaseResult__c.deleteWhitespace(),
      'Database Result should match the serialised save result'
    );
  }

  @isTest
  static void testSetDatabaseDeleteResultNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingDbResult = builder.getLogEvent();
    List<Database.DeleteResult> deleteResult;
    builder.setDatabaseResult(deleteResult);

    System.assertEquals(
      eventBeforeSettingDbResult,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetDatabaseMergeResultWithoutError() {
    Case mergedCase = getMockCase();
    Database.MergeResult mr = TestUtil.getMockMergeResult(
      MOCK_MERGE_DATABASE_RESULT_WITHOUT_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(mr);

    System.assertEquals(
      mergedCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assert(
      String.isBlank(builder.getLogEvent().DatabaseResult__c),
      'Database Result should be empty as there was no error'
    );
  }

  @isTest
  static void testSetDatabaseMergeResultWithError() {
    Database.MergeResult mr = TestUtil.getMockMergeResult(
      MOCK_MERGE_DATABASE_RESULT_WITH_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(mr);

    // The result is returned as a list so adding the square brackets so the string can be identical for comparison purpose
    // Also delete whitespaces as pretty JSON are difficult to compare
    System.assertEquals(
      '[' +
      MOCK_MERGE_DATABASE_RESULT_WITH_ERROR +
      ']',
      builder.getLogEvent().DatabaseResult__c.deleteWhitespace(),
      'Database Result should match the serialised save result'
    );
  }

  @isTest
  static void testSetDatabaseMergeResultNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingDbResult = builder.getLogEvent();
    List<Database.MergeResult> mergeResult;
    builder.setDatabaseResult(mergeResult);

    System.assertEquals(
      eventBeforeSettingDbResult,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetDatabaseUpsertResultWithoutError() {
    Case upsertedCase = getMockCase();
    Database.UpsertResult ur = TestUtil.getMockUpsertResult(
      MOCK_UPSERT_DATABASE_RESULT_WITHOUT_ERROR
    );
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(ur);

    System.assertEquals(
      upsertedCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assert(
      String.isBlank(builder.getLogEvent().DatabaseResult__c),
      'Database Result should be empty as there was no error'
    );
  }

  @isTest
  static void testSetDatabaseUpsertResultWithError() {
    Database.UpsertResult ur = TestUtil.getMockUpsertResult(
      MOCK_UPSERT_DATABASE_RESULT_WITH_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(ur);

    // The result is returned as a list so adding the square brackets so the string can be identical for comparison purpose
    // Also delete whitespaces as pretty JSON are difficult to compare
    System.assertEquals(
      '[' +
      MOCK_UPSERT_DATABASE_RESULT_WITH_ERROR +
      ']',
      builder.getLogEvent().DatabaseResult__c.deleteWhitespace(),
      'Database Result should match the serialised save result'
    );
  }

  @isTest
  static void testSetDatabaseUpsertResultNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingDbResult = builder.getLogEvent();
    List<Database.UpsertResult> upsertResult;
    builder.setDatabaseResult(upsertResult);

    System.assertEquals(
      eventBeforeSettingDbResult,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetDatabaseUndeleteResultWithoutError() {
    Case deletedCase = getMockCase();
    Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
      MOCK_UNDELETE_DATABASE_RESULT_WITHOUT_ERROR
    );
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(ur);

    System.assertEquals(
      deletedCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assert(
      String.isBlank(builder.getLogEvent().DatabaseResult__c),
      'Database Result should be empty as there was no error'
    );
  }

  @isTest
  static void testSetDatabaseUndeleteResultWithError() {
    Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
      MOCK_STD_DATABASE_RESULT_WITH_ERROR
    );

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setDatabaseResult(ur);

    // The result is returned as a list so adding the square brackets so the string can be identical for comparison purpose
    // Also delete whitespaces as pretty JSON are difficult to compare
    System.assertEquals(
      '[' +
      MOCK_STD_DATABASE_RESULT_WITH_ERROR +
      ']',
      builder.getLogEvent().DatabaseResult__c.deleteWhitespace(),
      'Database Result should match the serialised save result'
    );
  }

  @isTest
  static void testSetDatabaseUndeleteResultNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingDbResult = builder.getLogEvent();
    List<Database.UndeleteResult> undeleteResult;
    builder.setDatabaseResult(undeleteResult);

    System.assertEquals(
      eventBeforeSettingDbResult,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetRecordBySobjectId() {
    Case testCase = getMockCase();
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setRecord(testCase.Id);

    System.assertEquals(
      testCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assertEquals(
      'Case',
      builder.getLogEvent().RecordObjectName__c,
      'Record object name should match'
    );
  }

  @isTest
  static void testSetRecordBySingleSobject() {
    Case testCase = getMockCase();

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setRecord(testCase);

    System.assertEquals(
      testCase.Id,
      builder.getLogEvent().RecordId__c,
      'Record Id should match'
    );
    System.assertEquals(
      'Case',
      builder.getLogEvent().RecordObjectName__c,
      'Record object name should match'
    );
  }

  @isTest
  static void testSetRecordByListOfConcreteSobject() {
    Lead l1 = new Lead(LastName = 'Smith');
    Lead l2 = new Lead(LastName = 'James');
    List<Lead> leadList = new List<Lead>{ l1, l2 };

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setRecord(leadList);

    System.assertEquals(
      'Lead',
      builder.getLogEvent().RecordObjectName__c,
      'Record object name should match'
    );
  }

  @isTest
  static void testSetRecordByListOfConcreteSobjectNull() {
    List<Lead> leadList;

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    LogEvent__e eventBeforeSettingRecord = builder.getLogEvent();
    builder.setRecord(leadList);

    System.assertEquals(
      eventBeforeSettingRecord,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testSetRecordByListOfGenericSobject() {
    Lead l1 = new Lead(LastName = 'Smith');
    Lead l2 = new Lead(LastName = 'James');
    List<SObject> leadList = new List<SObject>{ l1, l2 };

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setRecord(leadList);

    System.assertEquals(
      'Lead',
      builder.getLogEvent().RecordObjectName__c,
      'Record object name should match'
    );
  }

  @isTest
  static void testParseStackTrace() {
    DmlException dmlException = new DmlException();

    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.ERROR, true);
    builder.getLogEvent().ApexClassName__c = null;
    builder.getLogEvent().StackTrace__c = null;
    builder.parseStackTrace(dmlException.getStackTraceString());

    String expectedOrigin = dmlException.getStackTraceString()
      .split('\n')
      .get(0)
      .substringBefore(':')
      .substringAfter('Class.');
    String expectedClassname = expectedOrigin.substringBefore('.');
    String expectedMethod = expectedOrigin.substringAfter('.');
    String expectedStackTrace = dmlException.getStackTraceString();

    System.assertEquals(
      expectedClassname,
      builder.getLogEvent().ApexClassName__c,
      'Class name should match'
    );
    System.assertEquals(
      expectedMethod,
      builder.getLogEvent().ApexMethodName__c,
      'Method name should match'
    );
    System.assertNotEquals(
      null,
      builder.getLogEvent().StackTrace__c,
      'Stacktrace should not be null'
    );
    System.assertEquals(
      expectedStackTrace,
      builder.getLogEvent().StackTrace__c,
      'Stacktrace should match'
    );
  }

  @isTest
  static void testParseStackTraceNull() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.ERROR, true);
    LogEvent__e eventBeforeSettingStacktrace = builder.getLogEvent();
    String stackTrace;
    builder.parseStackTrace(stackTrace);

    System.assertEquals(
      eventBeforeSettingStacktrace,
      builder.getLogEvent(),
      'Log event should be the same'
    );
  }

  @isTest
  static void testShouldSave() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.FINE, true);
    System.assertEquals(
      true,
      builder.shouldSave(),
      'Should save should be true'
    );
  }

  @isTest
  static void testGetTransactionContextBatch() {
    LogEventBuilderHelper.mockBatch = true;
    System.assertEquals(
      'Batch',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testGetTransactionContextFuture() {
    LogEventBuilderHelper.mockFuture = true;
    System.assertEquals(
      'Future',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testGetTransactionContextQueueable() {
    LogEventBuilderHelper.mockQueueable = true;
    System.assertEquals(
      'Queueable',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testGetTransactionContextSchedulable() {
    LogEventBuilderHelper.mockSchedulable = true;
    System.assertEquals(
      'Schedulable',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testGetTransactionContextTrigger() {
    LogEventBuilderHelper.mockTrigger = true;
    System.assertEquals(
      'Trigger',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testGetTransactionContextSyncApex() {
    System.assertEquals(
      'Synchronous Apex',
      LogEventBuilderHelper.getTransactionContext(),
      'Transaction context should match'
    );
  }

  @isTest
  static void testSetPayload() {
    LoggingSettings__c usrSettings = new LoggingSettings__c(
      SecureLogEnabled__c = true
    );
    LoggingSettingsController.setUserSettings(usrSettings);
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setPayload('Test payload with sensitive data');
    System.assertEquals(
      'Test payload with sensitive data',
      builder.getLogEvent().Payload__c,
      'Payload should match'
    );
  }

  @isTest
  static void testSetComponentAndBroswerName() {
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setComponentName('TransactionHistory');
    builder.setBrowserName('Chrome');
    System.assertEquals(
      'TransactionHistory',
      builder.getLogEvent().ComponentName__c,
      'Component name should match'
    );
    System.assertEquals(
      'Chrome',
      builder.getLogEvent().BrowserName__c,
      'Browser name should match'
    );
  }

  @isTest
  static void testSetSpanId() {
    String uniqueSpanId = UniqueIdUtil.generateSpanId();
    LogEventBuilder builder = new LogEventBuilder(LoggingLevel.DEBUG, true);
    builder.setSpanId(uniqueSpanId);
    System.assertEquals(
      uniqueSpanId,
      builder.getLogEvent().SpanId__c,
      'Span Id should match'
    );
  }

  private static Case getMockCase() {
    return (Case) JSON.deserialize(MOCK_CASE, Case.class);
  }
}
