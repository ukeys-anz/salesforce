@isTest
private class AccountTriggerHandlerTest {
  // ABT-25697 - Disable Trigger for Delete Event for Beta
  // @isTest
  // static void testAccountDeletionPositiveFlow() {
  //   Faker faker = new Faker('AU');
  //   List<String> companyNames = faker.text.realWords(2);
  //   Case[] newCases = new List<Case>();

  //   // GIVEN Account with related case records
  //   Account testAccount = new Account(
  //     Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
  //     OCV_ID__c = faker.randomString(10),
  //     ANZx_Customer__c = true
  //   );
  //   insert testAccount;

  //   for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
  //     newCases.add(
  //       new Case(
  //         RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
  //         AccountId = testAccount.Id,
  //         Type = 'Card',
  //         Additional_Type__c = 'App Support;Coaching'
  //       )
  //     );
  //   }
  //   insert newCases;

  //   Test.startTest();

  //   // WHEN an Account is updated with Deleted_In_OCV__c flag to true
  //   testAccount.Deleted_In_OCV__c = true;
  //   // Update Status to Inactive to avoid validation rule from firing to prevent a record being flagged for deletion while it is still active
  //   testAccount.FinServ__Status__c = 'Inactive';
  //   update testAccount;

  //   Test.stopTest();

  //   List<Account> accList = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
  //   List<Case> caseList = [
  //     SELECT Id
  //     FROM Case
  //     WHERE AccountId = :testAccount.Id
  //   ];

  //   // THEN the account and related case records will be deleted
  //   system.assertEquals(
  //     0,
  //     accList.size(),
  //     'Account deletion is not successful'
  //   );
  //   system.assertEquals(
  //     0,
  //     caseList.size(),
  //     'Related cases deletion is not sucessful'
  //   );
  // }

  // ABT-25697 - Disable Trigger for Delete Event for Beta
  // @isTest
  // static void testAccountDeletionNegativeFlow() {
  //   Faker faker = new Faker('AU');
  //   List<String> companyNames = faker.text.realWords(2);
  //   Account[] newAccounts = new List<Account>();
  //   Case[] newCases = new List<Case>();

  //   // GIVEN list of Inactive Account records
  //   for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
  //     newAccounts.add(
  //       new Account(
  //         Name = companyNames[0].capitalize() + companyNames[1].capitalize(),
  //         OCV_ID__c = faker.randomString(10),
  //         ANZx_Customer__c = true,
  //         FinServ__Status__c = 'Inactive'
  //       )
  //     );
  //   }
  //   insert newAccounts;

  //   // WHEN Deleted_In_OCV__c flag marked as true in bulk transaction
  //   newAccounts[0].Deleted_In_OCV__c = true;
  //   newAccounts[1].Deleted_In_OCV__c = true;
  //   List<Database.SaveResult> results = Database.Update(newAccounts, false);

  //   // THEN Record update will fail with custom error message
  //   system.assertEquals(
  //     'having multiple records with the Deleted_In_OCV__C flag set in a single transaction is not supported',
  //     results[0].errors[0].getMessage()
  //   );

  //   // GIVEN Account with related Financial Account
  //   Account testAccount = newAccounts[0];

  //   FinServ__FinancialAccount__c finAccount = new FinServ__FinancialAccount__c(
  //     FinServ__PrimaryOwner__c = testAccount.Id,
  //     Account_Key__c = '342490981',
  //     Primary_Owner_Start_Date__c = Date.valueOf('2021-02-11')
  //   );
  //   insert finAccount;

  //   Test.startTest();

  //   // WHEN an Account is updated with Deleted_In_OCV__c flag to true
  //   testAccount.Deleted_In_OCV__c = true;
  //   update testAccount;

  //   Test.stopTest();

  //   List<Application_Log__c> logList = [
  //     SELECT Id, Error_No__c
  //     FROM Application_Log__c
  //     WHERE Record_Id__c = :testAccount.Id
  //   ];

  //   // THEN the account deletion will fail and failure result will be added to application logs
  //   system.assertEquals('DELETE_FAILED', logList[0].Error_No__c);
  // }

  @TestSetup
  static void makeData() {
    Lead l = new Lead();
    l.Firstname = 'John';
    l.Lastname = 'Something';
    l.Email = 'john.something@gmail.com';
    l.MobilePhone = '0401123123';
    l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;

    insert l;
  }

  // @isTest
  // static void testEntitlementUpdate() {
  //   User ocvIntegrationUser = [
  //     SELECT Id
  //     FROM User
  //     WHERE FirstName = 'OCV Integration'
  //   ];

  //   Faker faker = new Faker('AU');
  //   System.runAs(ocvIntegrationUser) {
  //     Account testAccount = new Account(
  //       Name = 'Test Account',
  //       OCV_ID__c = faker.randomString(10),
  //       ANZx_Customer__c = false
  //     );
  //     insert testAccount;
  //     Test.startTest();

  //     testAccount.ANZx_Customer__c = true;
  //     update testAccount;

  //     Test.stopTest();

  //     Account testAcc = [SELECT Id FROM Account WHERE Name = 'Test Account'];
  //     Integer entitlementCount = [
  //       SELECT COUNT()
  //       FROM Entitlement
  //       WHERE AccountId = :testAcc.Id AND Name = 'Basic Subscription'
  //     ];

  //     System.assertEquals(1, entitlementCount);
  //   }
  // }

  @isTest
  private static void testFirstNameMobileEmailMatch() {
    Faker faker = new Faker('AU');
    // GIVEN an account with matching firstname, mobile and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Doe',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN the existing lead is converted into this account
    Lead l = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];
    System.assertEquals(
      'Converted',
      l.Status,
      'Lead should have been converted.'
    );

    // AND account details are not affected by the lead conversion
    Account acc = [
      SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone
      FROM Account LIMIT1
    ];
    assertAccountDetailsMatch(testAccount, acc);
  }

  @isTest
  private static void testLastNameMobileEmailMatch() {
    Faker faker = new Faker('AU');
    // GIVEN an account with matching lastname, mobile and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN the existing lead is converted into this account
    Lead l = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];
    System.assertEquals(
      'Converted',
      l.Status,
      'Lead should have been converted.'
    );

    // AND account details are not affected by the lead conversion
    Account acc = [
      SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone
      FROM Account LIMIT1
    ];
    assertAccountDetailsMatch(testAccount, acc);
  }

  @isTest
  private static void testFirstNameLastNameMobileMatch() {
    Faker faker = new Faker('AU');
    // GIVEN an account with matching firstname, lastname and mobile with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Something',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN the existing lead is converted into this account
    Lead l = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];
    System.assertEquals(
      'Converted',
      l.Status,
      'Lead should have been converted.'
    );

    // AND account details are not affected by the lead conversion
    Account acc = [
      SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone
      FROM Account LIMIT1
    ];
    assertAccountDetailsMatch(testAccount, acc);
  }

  @isTest
  private static void testFirstNameLastNameEmailMatch() {
    Faker faker = new Faker('AU');
    // GIVEN an account with matching firstname, lastname and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Something',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN the existing lead is converted into this account
    Lead l = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];
    System.assertEquals(
      'Converted',
      l.Status,
      'Lead should have been converted.'
    );

    // AND account details are not affected by the lead conversion
    Account acc = [
      SELECT Id, FirstName, LastName, PersonEmail, PersonMobilePhone
      FROM Account LIMIT1
    ];
    assertAccountDetailsMatch(testAccount, acc);
  }

  @isTest
  private static void testAccountNotMatch() {
    Faker faker = new Faker('AU');
    // GIVEN an account with non-matching firstname, lastname and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'Jane',
      LastName = 'Doe',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'jane.doe@gmail.com',
      PersonMobilePhone = '0401999999'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    Lead l = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];

    // THEN the existing lead should NOT be converted to this account
    System.assertEquals(
      'New',
      l.Status,
      'Lead should NOT have been converted.'
    );
  }

  private static void assertAccountDetailsMatch(
    Account testAccount,
    Account acc
  ) {
    System.assertEquals(
      testAccount.FirstName,
      acc.FirstName,
      'FirstName should match.'
    );
    System.assertEquals(
      testAccount.LastName,
      acc.LastName,
      'LastName should match.'
    );
    System.assertEquals(
      testAccount.PersonEmail,
      acc.PersonEmail,
      'Email should match.'
    );
    System.assertEquals(
      testAccount.PersonMobilePhone,
      acc.PersonMobilePhone,
      'Mobile phone should match.'
    );
  }

  @isTest
  private static void testConvertMultipleMatchingLeads() {
    List<Lead> leadsToCleanup = [SELECT Id FROM Lead];
    delete leadsToCleanup;

    // GIVEN 3 existing leads with same firsname, mobile and email with an account that will be inserted
    String email = 'jane.doe@gmail.com';
    String mobile = '0401123321';
    String firstName = 'Jane';
    List<Lead> matchingLeads = new List<Lead>();
    for (Integer i = 0; i < 3; i++) {
      Lead l = new Lead();
      l.FirstName = firstName;
      l.LastName = 'User' + i;
      l.MobilePhone = mobile;
      l.Email = email;
      l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;
      matchingLeads.add(l);
    }

    insert matchingLeads;

    Faker faker = new Faker('AU');
    Account testAccount = new Account(
      FirstName = firstName,
      LastName = 'Something',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonMobilePhone = mobile,
      PersonEmail = email
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN all 3 existing leads should be converted into this account
    List<Lead> convertedLeads = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = :firstName AND Email = :email AND isConverted = TRUE
    ];
    System.assertEquals(
      3,
      convertedLeads.size(),
      'All leads should have been converted'
    );
  }
}
