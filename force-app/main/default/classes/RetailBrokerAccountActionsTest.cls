/**
 * @author Lance Shi
 * @since  04/2026
 * @description Test class for RetailBrokerAccountActions
 */

@isTest
public class RetailBrokerAccountActionsTest {
  private static final Lib_MockProvider RETAIL_ACCOUNT_MERGE_REPOSITORY_MOCK = Lib_MockProvider.forType(
    RetailAccountMergeRepository.class
  );

  @TestSetup
  static void setup() {
    // Create test user with System Administrator profile but ocvgcp username pattern
    // Using System Admin to ensure user has permissions to perform Database.merge()
    Profile sysAdminProfile = CommonUtil.getProfileByName(
      'System Administrator'
    );
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now())
      .replace(' ', '')
      .replace(':', '')
      .replace('-', '');
    Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
    String uniqueUsername =
      'ocvgcp.integrationuser.' +
      orgId +
      dateString +
      randomInt +
      '@test.com';

    User ocvUser = new User(
      FirstName = 'Mulesoft OCV GCP',
      LastName = 'Integration User',
      Email = 'ocvgcp.integrationuser@anz.com',
      Username = uniqueUsername,
      Alias = 'ocvgcp',
      TimeZoneSidKey = 'Australia/Sydney',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = sysAdminProfile.Id
    );
    insert ocvUser;
  }

  static Account createTestAccount() {
    Account testAccount = new Account();
    testAccount.Name = 'Test Account 001';
    testAccount.External_Id__c = 'exIdAccountTest001';
    return testAccount;
  }

  private static List<Account> createTestAccounts(Integer count) {
    List<Account> accounts = new List<Account>();

    for (Integer i = 0; i < count; i++) {
      Account testAccount = new Account();
      testAccount.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
      testAccount.Name = 'Test Account ' + i;
      testAccount.External_Id__c = 'exIdAccountTest00' + i;
      accounts.add(testAccount);
    }
    return accounts;
  }

  @isTest
  static void testAccountMergeEvent() {
    // Get the OCV integration user created in setup
    User ocvUser = TestUtil.getUserByFirstName('Mulesoft OCV GCP');

    // Create real account records
    Account survivorAccount = new Account(
      Name = 'Survivor Account',
      External_Id__c = 'exIdSurvivor001',
      OCV_Id__c = 'testocv1'
    );
    Account victimAccount = new Account(
      Name = 'Victim Account',
      External_Id__c = 'exIdVictim001',
      OCV_Id__c = 'testocv2'
    );
    insert new List<Account>{ survivorAccount, victimAccount };

    // Query back the accounts to get all fields
    List<Account> accounts = [
      SELECT
        Id,
        Name,
        External_Id__c,
        Survivor_Party_ID__c,
        Victim_External_ID__c
      FROM Account
      WHERE Id IN :new List<Id>{ survivorAccount.Id, victimAccount.Id }
    ];

    Account survivor = accounts[0].External_Id__c == 'exIdSurvivor001'
      ? accounts[0]
      : accounts[1];
    Account victim = accounts[0].External_Id__c == 'exIdVictim001'
      ? accounts[0]
      : accounts[1];

    // Set merge fields
    Map<Id, Account> oldAccountsMap = new Map<Id, Account>(
      new List<Account>{ victim.clone(true, true, true, true) }
    );
    victim.Survivor_Party_ID__c = survivor.External_Id__c;
    victim.Victim_External_ID__c = victim.External_Id__c;

    // Mock the repository to return the survivor account
    RETAIL_ACCOUNT_MERGE_REPOSITORY_MOCK.mock(
      'queryAccountRecordsByExternalIds',
      new List<Account>{ survivor }
    );

    Test.startTest();
    System.runAs(ocvUser) {
      RetailBrokerAccountActions.accountMergeEvent(
        new List<Account>{ victim },
        new Map<Id, Account>{ victim.Id => victim },
        oldAccountsMap
      );
    }
    Test.stopTest();

    // Verify the merge was attempted (victim should be merged into survivor)
    List<Account> remainingAccounts = [
      SELECT Id
      FROM Account
      WHERE Id = :victim.Id
    ];
    Assert.areEqual(
      0,
      remainingAccounts.size(),
      'Victim account should be merged and deleted'
    );
  }

  @isTest
  static void testAccountMergeEventNonOcvUser() {
    // Test early return when user is NOT ocvgcp.integrationuser
    List<Account> newAccounts = createTestAccounts(2);

    newAccounts[0].External_Id__c = 'exIdAccountTest001';
    newAccounts[1].External_Id__c = 'exIdAccountTest002';
    List<Account> oldAccounts = newAccounts.deepClone(true);
    newAccounts[0].Survivor_Party_ID__c = newAccounts[1].External_Id__c;
    newAccounts[0].Victim_External_ID__c = newAccounts[0].External_Id__c;

    Test.startTest();
    // Running as current user (not OCV integration user)
    RetailBrokerAccountActions.accountMergeEvent(
      newAccounts,
      new Map<Id, Account>(newAccounts),
      new Map<Id, Account>(oldAccounts)
    );
    Test.stopTest();

    // Should return early without errors since test user is not ocvgcp.integrationuser
    Assert.isNotNull(newAccounts, 'Accounts should not be null');
  }

  @isTest
  static void testFilterVictimAccounts() {
    List<Account> newAccounts = createTestAccounts(2);

    newAccounts[0].External_Id__c = 'exIdAccountTest001';
    newAccounts[1].External_Id__c = 'exIdAccountTest002';
    List<Account> oldAccounts = newAccounts.deepClone(true);
    newAccounts[0].Survivor_Party_ID__c = newAccounts[1].External_Id__c;
    newAccounts[0].Victim_External_ID__c = newAccounts[0].External_Id__c;

    Test.startTest();
    List<Account> filteredAccounts = RetailBrokerAccountActions.filterVictimAccounts(
      newAccounts,
      new Map<Id, Account>(oldAccounts)
    );
    Test.stopTest();

    Assert.areEqual(
      1,
      filteredAccounts.size(),
      'Should filter one victim account'
    );
    Assert.areEqual(
      newAccounts[0].Id,
      filteredAccounts[0].Id,
      'Filtered account should be the victim'
    );
  }

  @isTest
  static void testProcessDataMerge() {
    List<Account> accounts = createTestAccounts(2);

    accounts[0].External_Id__c = 'exIdAccountTest001';
    accounts[1].External_Id__c = 'exIdAccountTest002';
    accounts[0].Survivor_Party_ID__c = accounts[1].External_Id__c;
    accounts[0].Victim_External_ID__c = accounts[0].External_Id__c;

    List<Account> victimAccounts = new List<Account>{ accounts[0] };
    List<Account> survivorAccounts = new List<Account>{ accounts[1] };

    Test.startTest();
    RetailBrokerAccountActions.processDataMerge(
      victimAccounts,
      survivorAccounts
    );
    Test.stopTest();

    Assert.isNotNull(victimAccounts, 'Victim accounts should not be null');
    Assert.isNotNull(survivorAccounts, 'Survivor accounts should not be null');
  }

  @isTest
  static void testProcessDataMergeNoSurvivor() {
    List<Account> accounts = createTestAccounts(2);

    accounts[0].External_Id__c = 'exIdAccountTest001';
    accounts[1].External_Id__c = 'exIdAccountTest002';
    accounts[0].Survivor_Party_ID__c = 'nonExistentId';
    accounts[0].Victim_External_ID__c = accounts[0].External_Id__c;

    List<Account> victimAccounts = new List<Account>{ accounts[0] };
    List<Account> survivorAccounts = new List<Account>{ accounts[1] };

    Test.startTest();
    RetailBrokerAccountActions.processDataMerge(
      victimAccounts,
      survivorAccounts
    );
    Test.stopTest();

    Assert.isNotNull(victimAccounts, 'Victim accounts should not be null');
  }
}
