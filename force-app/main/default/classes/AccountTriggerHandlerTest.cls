@isTest
private class AccountTriggerHandlerTest {
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

  @isTest
  static void testEntitlementUpdate() {
    Faker faker = new Faker('AU');

    Account testAccount = new Account(
      Name = 'Test Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = false
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'OCV Integration'
    ];
    System.runAs(ocvIntegrationUser) {
      insert testAccount;

      testAccount.ANZx_Customer__c = true;
      update testAccount;
    }
    Account testAcc = [SELECT Id FROM Account LIMIT 1];
    Integer entitlementCount = [
      SELECT COUNT()
      FROM Entitlement
      WHERE AccountId = :testAcc.Id AND Name = 'Basic Subscription'
    ];
    Test.stopTest();

    System.assertEquals(
      1,
      entitlementCount,
      'There should be just one entitlement.'
    );
  }

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
}
