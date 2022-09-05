/**
 * @author Jasmine Nguyen
 * @since July 2022
 * @group Logging
 * @description  Test class for {@link Logger}
 */
@SuppressWarnings(
  'PMD.AvoidHardcodingId, PMD.CyclomaticComplexity'
) // PMD.AvoidHardcodingId - The hardcoded Id is used for deserialisation so will not caused issue when deployed to another environment. Cannot use random string as Apex requires a correctly formatted Id.
@isTest
public with sharing class LoggerTest {
  private static final String MOCK_STD_DATABASE_RESULT = '{"id":"0012N00000ABCDEQA5","success":false,"errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}]}';

  private static final String MOCK_MERGE_DATABASE_RESULT = '{"errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}],"id":"0012N00000ABCDEQA5","mergedRecordIds":null,"success":false,"updatedRelatedIds":null}';

  private static final String MOCK_UPSERT_DATABASE_RESULT = '{"id":"0012N00000ABCDEQA5","success":false,"errors":[{"statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","message":"Testerrormessage","fields":[]}],"created":false}';

  private static final String MOCK_CASE = '{"Id":"5002N00000E5ndCQAR","RecordTypeId":"0122N000003T83iQAC"}';
  @TestSetup
  static void makeData() {
    // Create custom setting at user level
    Profile engineerProfile = CommonUtil.getProfileByName(
      'Minimum Access - Salesforce'
    );
    UserRole engineerRole = CommonUtil.getUserRoleByDevName('Engineer_Test');

    // Create global approver user
    User engineerUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'Engineer_Test',
        'ProfileId' => engineerProfile.Id,
        'UserRoleId' => engineerRole.Id
      }
    );
    insert engineerUser;

    System.runAs(engineerUser) {
      LoggingSettings__c userCustomSetting = new LoggingSettings__c(
        DefaultSaveMethod__c = 'QUEUEABLE',
        DefaultLoggingLevel__c = 'DEBUG',
        SecureLogEnabled__c = false,
        SetupOwnerId = engineerUser.Id
      );
      insert userCustomSetting;
    }
  }

  // ERROR log level tests
  @isTest
  static void testErrorDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.error('Error message', dr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.error('Error message', mr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.error('Error message', sr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.error('Error message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.error('Error message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorListDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>{
        dr
      };
      LogEventBuilder builder = Logger.error('Error message', deleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorListMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      List<Database.MergeResult> mergeResults = new List<Database.MergeResult>{
        mr
      };
      LogEventBuilder builder = Logger.error('Error message', mergeResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorListSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
        sr
      };
      LogEventBuilder builder = Logger.error('Error message', saveResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorListUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.UndeleteResult> undeleteResults = new List<Database.UndeleteResult>{
        ur
      };
      LogEventBuilder builder = Logger.error('Error message', undeleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorListUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>{
        ur
      };
      LogEventBuilder builder = Logger.error('Error message', upsertResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testErrorException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.error('Error message', dmlException);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
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
  }

  @isTest
  static void testErrorRecordIdWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.error(
        'Error message',
        '0012N00000ABCDEQA5',
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testErrorRecordId() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.error(
        'Error message',
        '0012N00000ABCDEQA5'
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testErrorRecord() {
    System.runAs(getEngineer()) {
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.error('Error message', mockCase);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testErrorRecordWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.error(
        'Error message',
        mockCase,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testErrorRecords() {
    System.runAs(getEngineer()) {
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.error('Error message', leadList);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
    }
  }

  @isTest
  static void testErrorRecordsWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.error(
        'Error message',
        leadList,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
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
  }

  @isTest
  static void testErrorMessage() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.error('Error message');

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Error message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  // INFO log level tests
  @isTest
  static void testInfoDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.info('Info message', dr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.info('Info message', mr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.info('Info message', sr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.info('Info message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.info('Info message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoListDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>{
        dr
      };
      LogEventBuilder builder = Logger.info('Info message', deleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoListMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      List<Database.MergeResult> mergeResults = new List<Database.MergeResult>{
        mr
      };
      LogEventBuilder builder = Logger.info('Info message', mergeResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoListSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
        sr
      };
      LogEventBuilder builder = Logger.info('Info message', saveResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoListUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.UndeleteResult> undeleteResults = new List<Database.UndeleteResult>{
        ur
      };
      LogEventBuilder builder = Logger.info('Info message', undeleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoListUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      List<Database.UpsertResult> upsertResults = new List<Database.UpsertResult>{
        ur
      };
      LogEventBuilder builder = Logger.info('Info message', upsertResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testInfoException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.info('Info message', dmlException);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
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
  }

  @isTest
  static void testInfoRecordIdWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.info(
        'Info message',
        '0012N00000ABCDEQA5',
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testInfoRecordId() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.info(
        'Info message',
        '0012N00000ABCDEQA5'
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testInfoRecord() {
    System.runAs(getEngineer()) {
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.info('Info message', mockCase);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testInfoRecordWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.info(
        'Info message',
        mockCase,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testInfoRecords() {
    System.runAs(getEngineer()) {
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.info('Info message', leadList);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
    }
  }

  @isTest
  static void testInfoRecordsWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.info(
        'Info message',
        leadList,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
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
  }

  @isTest
  static void testInfoMessage() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.info('Info message');

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Info message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  // DEBUG log level tests
  @isTest
  static void testDebugDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', dr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', mr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', sr);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugListDeleteResult() {
    System.runAs(getEngineer()) {
      Database.DeleteResult dr = TestUtil.getMockDeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>{
        dr
      };
      LogEventBuilder builder = Logger.debug('Debug message', deleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugListMergeResult() {
    System.runAs(getEngineer()) {
      Database.MergeResult mr = TestUtil.getMockMergeResult(
        MOCK_MERGE_DATABASE_RESULT
      );
      List<Database.MergeResult> mergeResults = new List<Database.MergeResult>{
        mr
      };
      LogEventBuilder builder = Logger.debug('Debug message', mergeResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugListSaveResult() {
    System.runAs(getEngineer()) {
      Database.SaveResult sr = TestUtil.getMockSaveResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.SaveResult> saveResults = new List<Database.SaveResult>{
        sr
      };
      LogEventBuilder builder = Logger.debug('Debug message', saveResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugListUndeleteResult() {
    System.runAs(getEngineer()) {
      Database.UndeleteResult ur = TestUtil.getMockUndeleteResult(
        MOCK_STD_DATABASE_RESULT
      );
      List<Database.UndeleteResult> undeleteResults = new List<Database.UndeleteResult>{
        ur
      };
      LogEventBuilder builder = Logger.debug('Debug message', undeleteResults);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugListUpsertResult() {
    System.runAs(getEngineer()) {
      Database.UpsertResult ur = TestUtil.getMockUpsertResult(
        MOCK_UPSERT_DATABASE_RESULT
      );
      LogEventBuilder builder = Logger.debug('Debug message', ur);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  static void testDebugException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.debug('Debug message', dmlException);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
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
  }

  @isTest
  static void testDebugRecordIdWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      LogEventBuilder builder = Logger.debug(
        'Debug message',
        '0012N00000ABCDEQA5',
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testDebugRecordId() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.debug(
        'Debug message',
        '0012N00000ABCDEQA5'
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        '0012N00000ABCDEQA5',
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testDebugRecord() {
    System.runAs(getEngineer()) {
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.debug('Debug message', mockCase);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
    }
  }

  @isTest
  static void testDebugRecordWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Case mockCase = getMockCase();
      LogEventBuilder builder = Logger.debug(
        'Debug message',
        mockCase,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        mockCase.Id,
        builder.getLogEvent().RecordId__c,
        'Record Id should match'
      );
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
  }

  @isTest
  static void testDebugRecords() {
    System.runAs(getEngineer()) {
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.debug('Debug message', leadList);

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
    }
  }

  @isTest
  static void testDebugRecordsWithException() {
    System.runAs(getEngineer()) {
      DMLException dmlException = new DMLException('Test DML exception');
      Lead l1 = new Lead(LastName = 'Smith');
      Lead l2 = new Lead(LastName = 'James');
      List<Lead> leadList = new List<Lead>{ l1, l2 };
      LogEventBuilder builder = Logger.debug(
        'Debug message',
        leadList,
        dmlException
      );

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
      System.assertEquals(
        JSON.serializePretty(leadList),
        builder.getLogEvent().RecordsJson__c,
        'Record Json should match'
      );
      System.assertEquals(
        'Lead',
        builder.getLogEvent().RecordObjectName__c,
        'Record object name should match'
      );
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
  }

  @isTest
  static void testDebugMessage() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = Logger.debug('Debug message');

      System.assertEquals(
        1,
        LoggerHelper.LOG_ENTRIES_BUFFER.size(),
        'Log entry should have been added to log entries buffer'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
      System.assertEquals(
        'Debug message',
        builder.getLogEvent().LogMessage__c,
        'Log message should match'
      );
    }
  }

  @isTest
  @SuppressWarnings(
    'PMD.ApexUnitTestClassShouldHaveAsserts'
  ) // saveLog() is already tested in {@link LoggerHelperTest}
  static void testSaveLogWithoutParam() {
    System.runAs(getEngineer()) {
      Logger.debug('Debug message');
      Logger.saveLog();
    }
  }

  @isTest
  @SuppressWarnings(
    'PMD.ApexUnitTestClassShouldHaveAsserts'
  ) // saveLog() is already tested in {@link LoggerHelperTest}
  static void testSaveLogWithParam() {
    System.runAs(getEngineer()) {
      Logger.debug('Debug message');
      Logger.saveLog(Logger.SaveMethod.EVENT_BUS);
    }
  }

  /**
   * @description Returns the mock case
   * @return The mock case
   */
  private static Case getMockCase() {
    return (Case) JSON.deserialize(MOCK_CASE, Case.class);
  }

  /**
   * @description Returns the engineer user
   * @return The engineer user
   */
  private static User getEngineer() {
    return [SELECT Id FROM User WHERE Firstname = 'Engineer_Test' LIMIT 1];
  }
}
