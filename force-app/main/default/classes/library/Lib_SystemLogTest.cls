/**
 *
 * @author Jasmine Nguyen
 * @since 05/2021
 * @description Test class for {@link Lib_SystemLog}
 * @group Library
 */
@isTest
public with sharing class Lib_SystemLogTest {
  @isTest
  private static void testCreateSingleLog() {
    // WHEN createSingleLog() is called
    Test.startTest();
    Lib_SystemLog.createSingleLog(
      '001',
      'Error Description 001',
      Lib_SystemLog.Severity.ERROR
    );
    Test.stopTest();
    Application_Log__c log = [
      SELECT
        Id,
        Process_Name__c,
        Function_Name__c,
        Error_Description__c,
        Error_No__c
      FROM Application_Log__c
      LIMIT 1
    ];
    // THEN an application log record is created with the correct process name, function name, error number and error description
    System.assertEquals('001', log.Error_No__c, 'Error number does not match.');
    System.assertEquals(
      'Error Description 001',
      log.Error_Description__c,
      'Error description does not match.'
    );
    System.assertEquals(
      'Lib_SystemLogTest',
      log.Process_Name__c,
      'Process name does not match.'
    );
    System.assertEquals(
      'testCreateSingleLog',
      log.Function_Name__c,
      'Function name does not match.'
    );
  }

  @isTest
  private static void testCreateSingleLogAsync() {
    // WHEN createSingleLogAsync() is called
    Test.startTest();
    Lib_SystemLog.createSingleLogAsync(
      '002',
      'Error Description 002',
      Lib_SystemLog.Severity.ERROR
    );
    Test.stopTest();
    Application_Log__c log = [
      SELECT
        Id,
        Process_Name__c,
        Function_Name__c,
        Error_Description__c,
        Error_No__c
      FROM Application_Log__c
      LIMIT 1
    ];
    // THEN an application log record is created with the correct process name, function name, error number and error description
    System.assertEquals('002', log.Error_No__c, 'Error number does not match.');
    System.assertEquals(
      'Error Description 002',
      log.Error_Description__c,
      'Error description does not match.'
    );
    System.assertEquals(
      'Lib_SystemLogTest',
      log.Process_Name__c,
      'Process name does not match.'
    );
    System.assertEquals(
      'testCreateSingleLogAsync',
      log.Function_Name__c,
      'Function name does not match.'
    );
  }

  @isTest
  private static void testLogAPIError() {
    // WHEN logAPIError() is called
    Test.startTest();
    Lib_SystemLog.logAPIError(
      'Error Description 003',
      '003',
      '003',
      'Fake Request',
      'Fake Response'
    );
    Test.stopTest();
    Application_Log__c log = [
      SELECT
        Id,
        Process_Name__c,
        Function_Name__c,
        Error_Description__c,
        Error_No__c
      FROM Application_Log__c
      LIMIT 1
    ];
    // THEN an application log record is created with the correct process name, function name, error number and error description
    System.assertEquals('003', log.Error_No__c, 'Error number does not match.');
    System.assertEquals(
      'Error Description 003',
      log.Error_Description__c,
      'Error description does not match.'
    );
    System.assertEquals(
      'Lib_SystemLogTest',
      log.Process_Name__c,
      'Process name does not match.'
    );
    System.assertEquals(
      'testLogAPIError',
      log.Function_Name__c,
      'Function name does not match.'
    );
  }
}
