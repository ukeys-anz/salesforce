@isTest
private class TestAccountTriggerHandler {
  @isTest
  static void testAccountWhitelist() {
    Faker faker = new Faker('AU');
    List<String> companyNames = faker.text.realWords(2);

    // GIVEN Account whitelisting is configured
    insert new Non_Prod_Settings__c(
      Enable_Account_Whitelisting__c = true,
      Account_Whitelist__c = '1234,5678'
    );

    // WHEN an Account is inserted that does not match the white list
    Account testAccount = new Account(
      Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
      Fabric_ID__c = '12345',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );

    // THEN the account insertion will fail
    try {
      insert testAccount;
      system.assert(
        false,
        'The testAccount should not have inserted due to not being whitelisted.'
      );
    } catch (exception e) {
      system.assert(
        true,
        'The testAccount should fail the above insertion attempt, making this assertion successfully.'
      );
    }

    // WHEN the Account's number is fixed to one that is whitelisted
    testAccount.Fabric_ID__c = '1234';

    // THEN the account insertion will succeed
    insert testAccount;
    system.assert(
      testAccount.ID != null,
      'The testAccount should have been given a Salesforce ID upon insertion.'
    );
  }

  @isTest
  static void testAccountDeletionPositiveFlow() {
    Faker faker = new Faker('AU');
    List<String> companyNames = faker.text.realWords(2);
    Case[] newCases = new List<Case>();

    // GIVEN Account with related case records
    Account testAccount = new Account(
      Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert testAccount;

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          AccountId = testAccount.Id,
          Type = 'Card',
          Additional_Type__c = 'App Support;Coaching'
        )
      );
    }
    insert newCases;

    Test.startTest();

    // WHEN an Account is updated with Deleted_In_OCV__c flag to true
    testAccount.Deleted_In_OCV__c = true;
    // Update Status to Inactive to avoid validation rule from firing to prevent a record being flagged for deletion while it is still active
    testAccount.FinServ__Status__c = 'Inactive';
    update testAccount;

    Test.stopTest();

    List<Account> accList = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
    List<Case> caseList = [
      SELECT Id
      FROM Case
      WHERE AccountId = :testAccount.Id
    ];

    // THEN the account and related case records will be deleted
    system.assertEquals(
      0,
      accList.size(),
      'Account deletion is not successful'
    );
    system.assertEquals(
      0,
      caseList.size(),
      'Related cases deletion is not sucessful'
    );
  }

  @isTest
  static void testAccountDeletionNegativeFlow() {
    Faker faker = new Faker('AU');
    List<String> companyNames = faker.text.realWords(2);
    Account[] newAccounts = new List<Account>();
    Case[] newCases = new List<Case>();

    // GIVEN list of Inactive Account records
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newAccounts.add(
        new Account(
          Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
          OCV_ID__c = faker.randomString(10),
          ANZx_Customer__c = true,
          FinServ__Status__c = 'Inactive'
        )
      );
    }
    insert newAccounts;

    // WHEN Deleted_In_OCV__c flag marked as true in bulk transaction
    newAccounts[0].Deleted_In_OCV__c = true;
    newAccounts[1].Deleted_In_OCV__c = true;
    List<Database.SaveResult> results = Database.Update(newAccounts, false);

    // THEN Record update will fail with custom error message
    system.assertEquals(
      'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported',
      results[0].errors[0].getMessage()
    );

    // GIVEN Account with related Financial Account
    Account testAccount = newAccounts[0];

    FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
      FinServ__PrimaryOwner__c = testAccount.Id
    );
    insert finAccount;

    Test.startTest();

    // WHEN an Account is updated with Deleted_In_OCV__c flag to true
    testAccount.Deleted_In_OCV__c = true;
    update testAccount;

    Test.stopTest();

    List<Application_Log__c> logList = [
      SELECT Id, Error_No__c
      FROM Application_Log__c
      WHERE Record_Id__c = :testAccount.Id
    ];

    // THEN the account deletion will fail and failure result will be added to application logs
    system.assertEquals('DELETE_FAILED', logList[0].Error_No__c);
  }
}
