/**
 * @author Zhiren Jason Guan
 * @since 20/12/2023
 * @description Test class for Account record processing functionalities
 */

@IsTest
private class AccountOCVSyncProcessorTest {
  @IsTest
  static void testBehavior() {
    // Test data set 1
    List<Account> testAccounts = new List<Account>();
    Map<Id, Account> testAccountMap = new Map<Id, Account>();
    // Test data set 2
    List<Account> testAccounts2 = new List<Account>();
    Map<Id, Account> testAccountMap2 = new Map<Id, Account>();
    // Test data set 3
    List<Account> testAccounts3 = new List<Account>();
    Map<Id, Account> testAccountMap3 = new Map<Id, Account>();
    // Test data set 4
    List<Account> testAccounts4 = new List<Account>();
    Map<Id, Account> testAccountMap4 = new Map<Id, Account>();
    // Test data set 5
    List<Account> testAccounts5 = new List<Account>();
    Map<Id, Account> testAccountMap5 = new Map<Id, Account>();

    // Setup bulk of 10 mocked data
    for (Integer i = 0; i < 10; i++) {
      // Setup positive test account with Sync Status = null
      Account testAccount = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OCV_Event_Version__c = i + 2
      );
      testAccounts.add(testAccount);
      Account oldAccount = testAccount.clone(true);
      oldAccount.OCV_Event_Version__c = i + 1;
      testAccountMap.put(oldAccount.Id, oldAccount);
      // Setup positive test account with Sync Status = Other (Other does not exist as a valid picklist value, only 'Blocked' or 'Broker Org')
      // Note: This invalid 'Other' test scenario is created in order to address the code review feedback and still achieve 100% coverage
      Account testAccount2 = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = 'Other'
      );
      testAccounts2.add(testAccount2);
      Account oldAccount2 = testAccount2.clone(true);
      oldAccount2.OCV_Event_Version__c = i + 1;
      testAccountMap2.put(oldAccount2.Id, oldAccount2);

      // Setup negative test account with OCV Event Version Unchanged
      Account testAccount3 = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OCV_Event_Version__c = i + 1
      );
      testAccounts3.add(testAccount3);
      Account oldAccount3 = testAccount3.clone(true);
      testAccountMap3.put(oldAccount3.Id, oldAccount3);
      // Setup negative test account with Sync Status = Broker Org
      Account testAccount4 = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
      );
      testAccounts4.add(testAccount4);
      Account oldAccount4 = testAccount4.clone(true);
      oldAccount4.OCV_Event_Version__c = i + 1;
      testAccountMap4.put(oldAccount4.Id, oldAccount4);
      // Setup negative test account with Sync Status = Blocked
      Account testAccount5 = new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OCV_Event_Version__c = i + 2,
        Sync_Status__c = AccountOCVSyncProcessor.SYNC_STATUS_BLOCKED
      );
      testAccounts5.add(testAccount5);
      Account oldAccount5 = testAccount5.clone(true);
      oldAccount5.OCV_Event_Version__c = i + 1;
      testAccountMap5.put(oldAccount5.Id, oldAccount5);
    }

    Test.startTest();
    // Positive
    AccountOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testAccounts,
      testAccountMap
    );
    AccountOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testAccounts2,
      testAccountMap2
    );
    // Negative
    AccountOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testAccounts3,
      testAccountMap3
    );
    AccountOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testAccounts4,
      testAccountMap4
    );
    AccountOCVSyncProcessor.updateRecordsForOCVVersionChanged(
      testAccounts5,
      testAccountMap5
    );
    Test.stopTest();

    // Assert Positive: Broker Org added
    for (Account resultAcc : testAccounts) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Positive: Broker Org added
    for (Account resultAcc : testAccounts2) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Account resultAcc : testAccounts3) {
      Assert.areEqual(
        false,
        resultAcc.Sync_Status__c ==
        AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Account resultAcc : testAccounts4) {
      Assert.areEqual(
        true,
        resultAcc.Sync_Status__c.contains(
          AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
    // Assert Negative: Sync_Status__c unchanged
    for (Account resultAcc : testAccounts5) {
      Assert.areEqual(
        false,
        resultAcc.Sync_Status__c.contains(
          AccountOCVSyncProcessor.SYNC_STATUS_BROKER_ORG
        )
      );
    }
  }
}
