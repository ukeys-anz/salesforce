/**
 *
 * @author Jasmine Nguyen
 * @since March 2024
 * @description Test class for {@link Lib_TriggerHandler}
 * @group Library
 */
@isTest
public with sharing class Lib_TriggerHandlerTest {
  @TestSetup
  private static void makeData() {
    LoggingSettings__c loggingSetting = new LoggingSettings__c(
      DefaultLoggingLevel__c = 'DEBUG',
      SetupOwnerId = UserInfo.getUserId()
    );
    insert loggingSetting;
  }

  private class Lib_TriggerHandlerImpl extends Lib_TriggerHandler {
    private Lib_TriggerHandlerImpl() {
      super();
    }

    public override Boolean isValidRecord(SObject record) {
      Account account = (Account) record;
      if (account.ANZx_Customer__c == true) {
        return true;
      }
      return false;
    }
  }

  /**
   * @description This is to cover virtual isValidRecord in Lib_TriggerHandler
   * since somehow it is not covered in testIsValidRecordPositive and testIsValidRecordNegative
   */
  @isTest
  static void testIsValidRecordDefault() {
    Account account = getAllRecords(true)[0];
    Lib_TriggerHandler handler = new Lib_TriggerHandler();
    Assert.areEqual(
      true,
      handler.isValidRecord(account),
      'Should return true by default'
    );
  }

  @isTest
  static void testIsValidRecordPositive() {
    Lib_TriggerHandlerImpl impl = new Lib_TriggerHandlerImpl();
    impl.allRecords = getAllRecords(true);
    impl.context = TriggerOperation.BEFORE_UPDATE;
    Assert.areEqual(
      2,
      impl.records.size(),
      'There should be 2 relevant records'
    );
    Assert.areEqual(2, impl.newMap.size(), 'NewMap should contain 2 records');
    Assert.areEqual('Account', impl.objectName, 'ObjectName should be Account');
    Assert.areEqual(
      'Account-BEFORE_UPDATE',
      impl.objectEventName,
      'ObjectEventName should be Account-BEFORE_UPDATE'
    );
    Assert.areEqual(
      Schema.SObjectType.Account.getRecordTypeInfosByName(),
      impl.objectRecordTypes,
      'Object recored types should not be null'
    );
  }

  @isTest
  static void testIsValidRecordNegative() {
    Lib_TriggerHandlerImpl impl = new Lib_TriggerHandlerImpl();
    impl.allRecords = getAllRecords(false);
    Assert.areEqual(
      0,
      impl.records.size(),
      'There should be 0 relevant record'
    );
    Assert.areEqual(0, impl.newMap.size(), 'NewMap should contain 0 record');
  }

  @isTest
  static void testAddToLoopCountExceeded() {
    LoggerHelper.transactionSaveMethod = Logger.SaveMethod.IMMEDIATE;

    Lib_TriggerHandler.recursionLogged = true;
    Lib_TriggerHandler handler = new Lib_TriggerHandler();
    handler.allRecords = getAllRecords(true);
    handler.context = TriggerOperation.BEFORE_UPDATE;
    handler.addToLoopCount(4); // Runs once to cover code that initialises loopCountMap

    // Mocking the current count to be 4, also need to pass in a value for max (4) otherwise 10 will be used as default
    Lib_TriggerHandler.LoopCount mockLoopCount = new Lib_TriggerHandler.LoopCount(
      4
    );
    mockLoopCount.Count = 4;
    Lib_TriggerHandler.loopCountMap.put('Account-BEFORE_UPDATE', mockLoopCount);

    Test.startTest();
    handler.addToLoopCount(4); // Has to pass in a max value since addToLoopCount() requires a parameter
    Test.stopTest();
    List<LogEntry__c> triggerRecursionLogs = [
      SELECT Id, LogMessage__c
      FROM LogEntry__c
      WHERE LoggingLevel__c = 'INFO'
    ];
    Assert.areEqual(
      1,
      triggerRecursionLogs.size(),
      'Log should have been created'
    );
    Assert.areEqual(
      '{"Account-BEFORE_UPDATE":{"max":4,"count":5}}; Reason for logging: Trigger handler exceeds max loop count',
      triggerRecursionLogs[0].LogMessage__c,
      'Log message should match'
    );
  }

  @isTest
  static void testAddToLoopCounNotExceeded() {
    Lib_TriggerHandler.loopCountMap.put(
      'Account-BEFORE_UPDATE',
      new Lib_TriggerHandler.LoopCount()
    ); // Default count is 1
    Lib_TriggerHandler.recursionLogged = true;

    Lib_TriggerHandler handler = new Lib_TriggerHandler();
    handler.allRecords = getAllRecords(true);
    handler.context = TriggerOperation.BEFORE_UPDATE;

    Test.startTest();
    handler.addToLoopCount(3);
    Test.stopTest();
    List<LogEntry__c> triggerRecursionLogs = [
      SELECT Id, LogMessage__c
      FROM LogEntry__c
      WHERE LoggingLevel__c = 'INFO'
    ];
    Assert.areEqual(
      0,
      triggerRecursionLogs.size(),
      'Log should not have been created'
    );
  }

  private static List<Account> getAllRecords(Boolean isANZxCustomer) {
    Account irrelevantAccount = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      ANZx_Customer__c = isANZxCustomer,
      Name = 'Irrelevant Account',
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );
    Account relevantAccount = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Relevant Account',
      ANZx_Customer__c = isANZxCustomer
    );
    return new List<Account>{ irrelevantAccount, relevantAccount };
  }
}
