/**
 * @author Jasmine Nguyen
 * @since July 2022
 * @group Logging
 * @description  Test class for {@link LoggerHelper}
 */
@isTest
public with sharing class LoggerHelperTest {
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
        DefaultSaveMethod__c = String.valueOf(Logger.SaveMethod.QUEUEABLE),
        DefaultLoggingLevel__c = 'DEBUG',
        SecureLogEnabled__c = false,
        SetupOwnerId = engineerUser.Id
      );
      insert userCustomSetting;
    }
  }

  @isTest
  static void testTransactionSaveMethod() {
    System.runAs(getEngineer()) {
      System.assertEquals(
        Logger.SaveMethod.QUEUEABLE,
        LoggerHelper.transactionSaveMethod,
        'Transaction save method should match'
      );
    }
  }

  @isTest
  static void testUserLoggingLevel() {
    System.runAs(getEngineer()) {
      System.assertEquals(
        LoggingLevel.DEBUG,
        LoggerHelper.userLoggingLevel,
        'User logging level should match'
      );
    }
  }

  @isTest
  static void testGetLoggingLevel() {
    System.assertEquals(
      LoggingLevel.ERROR,
      LoggerHelper.getLoggingLevel('Error'),
      'Logging level should match'
    );
    System.assertEquals(
      LoggingLevel.DEBUG,
      LoggerHelper.getLoggingLevel('Debug'),
      'Logging level should match'
    );
    System.assertEquals(
      LoggingLevel.INFO,
      LoggerHelper.getLoggingLevel('Info'),
      'Logging level should match'
    );
    System.assertEquals(
      LoggingLevel.ERROR,
      LoggerHelper.getLoggingLevel(''),
      'Logging level should mgetatch'
    );
  }

  @isTest
  static void testNewErrorEntry() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = LoggerHelper.newEntry(LoggingLevel.ERROR);
      System.assertNotEquals(
        null,
        builder.getLogEvent(),
        'Log event should not be null'
      );
      System.assertEquals(
        'ERROR',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
    }
  }

  @isTest
  static void testNewInfoEntry() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = LoggerHelper.newEntry(LoggingLevel.INFO);
      System.assertNotEquals(
        null,
        builder.getLogEvent(),
        'Log event should not be null'
      );
      System.assertEquals(
        'INFO',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
    }
  }

  @isTest
  static void testNewDebugEntry() {
    System.runAs(getEngineer()) {
      LogEventBuilder builder = LoggerHelper.newEntry(LoggingLevel.DEBUG);
      System.assertNotEquals(
        null,
        builder.getLogEvent(),
        'Log event should not be null'
      );
      System.assertEquals(
        'DEBUG',
        builder.getLogEvent().LoggingLevel__c,
        'Logging level should match'
      );
    }
  }

  @isTest
  static void testGetBufferSize() {
    System.runAs(getEngineer()) {
      LoggerHelper.newEntry(LoggingLevel.DEBUG);
      LoggerHelper.newEntry(LoggingLevel.ERROR);
      System.assertEquals(
        2,
        LoggerHelper.getBufferSize(),
        'Buffer size should match'
      );
    }
  }

  @isTest
  static void testFlushBuffer() {
    System.runAs(getEngineer()) {
      LoggerHelper.newEntry(LoggingLevel.DEBUG);
      LoggerHelper.newEntry(LoggingLevel.ERROR);
      System.assertEquals(
        2,
        LoggerHelper.getBufferSize(),
        'Buffer size should match'
      );
      LoggerHelper.flushBuffer();
      System.assertEquals(
        0,
        LoggerHelper.getBufferSize(),
        'Buffer size should match'
      );
    }
  }

  @isTest
  static void testSaveLogEventBus() {
    System.runAs(getEngineer()) {
      LoggerHelper.newEntry(LoggingLevel.DEBUG);
      LoggerHelper.newEntry(LoggingLevel.ERROR);
      LoggerHelper.saveLog(Logger.SaveMethod.EVENT_BUS);

      System.assertEquals(
        0,
        LoggerHelper.getBufferSize(),
        'Log buffer should have been flushed'
      );

      // TO DO: Validating that log and log entries are created
      // To be done when AR-14093 - LogEventTriggerHandler class is completed
    }
  }

  @isTest
  static void testSaveLogQueueable() {
    System.runAs(getEngineer()) {
      LoggerHelper.newEntry(LoggingLevel.DEBUG);
      LoggerHelper.newEntry(LoggingLevel.ERROR);
      LoggerHelper.saveLog(Logger.SaveMethod.QUEUEABLE);

      System.assertEquals(
        0,
        LoggerHelper.getBufferSize(),
        'Log buffer should have been flushed'
      );
    }
  }

  @isTest
  static void testHasError() {
    System.runAs(getEngineer()) {
      LoggerHelper.newEntry(LoggingLevel.DEBUG);
      LoggerHelper.newEntry(LoggingLevel.ERROR);

      System.assert(
        LoggerHelper.hasError(),
        'hasError should return true because there is an error'
      );
    }
  }

  /**
   * @description Returns the engineer user
   * @return The engineer user
   */
  private static User getEngineer() {
    return [SELECT Id FROM User WHERE Firstname = 'Engineer_Test' LIMIT 1];
  }
}
