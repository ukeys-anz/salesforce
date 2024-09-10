@isTest
private class AccountTriggerHandlerTest {
  private final static Faker TESTFAKER = new Faker('AU');

  @TestSetup
  static void makeData() {
    Lead l = new Lead();
    l.Firstname = 'John';
    l.Lastname = 'Something';
    l.Email = 'john.something@gmail.com';
    l.MobilePhone = '0401123123';
    l.RecordTypeId = GetHelpConstants.LEAD_ANZX_RT_ID;

    insert l;

    CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
      PersonaId__c = 'dsfsadfasdf',
      OCVId__c = '4324234234',
      SecurityMobile__c = '0401123123'
    );
    insert cob;

    Case kycqa = new Case(
      CustomerOnboardingApplication__c = cob.Id,
      RecordTypeId = RTCase.kycQa,
      Type = 'KYC QA Sample',
      OCV_Id__c = '4324234234',
      PersonaId__c = '123456789'
    );
    insert kycqa;

    User ocvIntegrationUser = CCRMTestDataFactory.createOCVIntegrationUser();
    System.runAs(ocvIntegrationUser) {
      // Add Logging Setting
      LoggingSettings__c userCustomSetting = new LoggingSettings__c(
        DefaultSaveMethod__c = 'EVENT_BUS',
        DefaultLoggingLevel__c = 'DEBUG',
        SecureLogEnabled__c = true,
        SetupOwnerId = ocvIntegrationUser.Id
      );
      insert userCustomSetting;
    }
  }

  @isTest
  static void testEntitlementUpdate() {
    Account testAccount = new Account(
      Name = 'Test Account',
      OCV_ID__c = TESTFAKER.randomString(10),
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
    // GIVEN an account with matching firstname, mobile and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Doe',
      OCV_ID__c = TESTFAKER.randomString(10),
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
    // GIVEN an account with matching lastname, mobile and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
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
    // GIVEN an account with matching firstname, lastname and mobile with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
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
    // GIVEN an account with matching firstname, lastname and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'John',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
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
    // GIVEN an account with non-matching firstname, lastname and email with an existing lead
    Account testAccount = new Account(
      FirstName = 'Jane',
      LastName = 'Doe',
      OCV_ID__c = TESTFAKER.randomString(10),
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

    Account testAccount = new Account(
      FirstName = firstName,
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
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

  @isTest
  static void testInsertAccountWithoutBankruptField() {
    Account acc = new Account(
      Name = 'Test Account',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = false
    );

    Test.startTest();
    insert acc;
    Test.stopTest();

    System.assert(!acc.BankruptCheckBox__c, 'Bankrupt flag should be false');
  }

  @isTest
  static void testInsertAccountWithBankruptField() {
    Account acc = new Account(
      Name = 'Test Account',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = false,
      Bankrupt_Date__c = Date.today()
    );

    Test.startTest();
    insert acc;
    Test.stopTest();

    acc = [
      SELECT BankruptCheckBox__c, Name
      FROM Account
      WHERE Name = 'Test Account'
    ];
    System.assert(acc.BankruptCheckBox__c, 'Bankrupt flag should be true');
  }

  @isTest
  static void testUpdateAccountWithNullBankruptField() {
    Account acc = new Account(
      Name = 'Test Account',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = false,
      Bankrupt_Date__c = Date.today()
    );

    Test.startTest();
    insert acc;

    acc.Bankrupt_Date__c = null;
    update acc;
    Test.stopTest();

    acc = [
      SELECT BankruptCheckBox__c, Name
      FROM Account
      WHERE Name = 'Test Account'
    ];
    System.assert(!acc.BankruptCheckBox__c, 'Bankrupt flag should be false');
  }

  @isTest
  static void testUpdateAccountWithBankruptField() {
    Account acc = new Account(
      Name = 'Test Account',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = false
    );

    Test.startTest();
    insert acc;

    acc.Bankrupt_Date__c = Date.today();
    update acc;
    Test.stopTest();

    acc = [
      SELECT BankruptCheckBox__c, Name
      FROM Account
      WHERE Name = 'Test Account'
    ];
    System.assert(acc.BankruptCheckBox__c, 'Bankrupt flag should be true');
  }

  @IsTest
  static void testWasAnxCustomer() {
    Account acc = new Account();
    List<Account> accounts = new List<Account>{ acc };

    AccountCommonActions.populateFieldsValue(accounts);
    Assert.isFalse(
      acc.Was_ANZx_Customer__c,
      'Was_ANZx_Customer__c should be false when customer isn\t ANZx'
    );

    acc.ANZx_Customer__c = true;
    AccountCommonActions.populateFieldsValue(accounts);
    Assert.isTrue(
      acc.Was_ANZx_Customer__c,
      'Was_ANZx_Customer__c should be true when customer is ANZx'
    );

    acc.ANZx_Customer__c = false;
    AccountCommonActions.populateFieldsValue(accounts);
    Assert.isTrue(
      acc.Was_ANZx_Customer__c,
      'Was_ANZx_Customer__c should still be true when customer used to be (but no longer) ANZx'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountByOCVId() {
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = '4324234234',
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
    ];

    // Sharing Case record manually to avoid deployment issues
    List<Case> newCases = [SELECT Id FROM Case];
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = ocvIntegrationUser.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT Id FROM Case WHERE AccountId = :testAccount.Id].size(),
      'Link the KYC QA Case with the relevant Customer using the OCV ID'
    );

    List<LogEntry__c> logEntryList = Database.query(
      'SELECT ID, Log__c, LogMessage__c FROM LogEntry__c WHERE LogMessage__c LIKE \'%' +
        AccountCommonActions.CUSTOMER_LINKED_TO_KYC_QA_SUCCESS +
        '%\''
    );

    Assert.areEqual(
      1,
      logEntryList.size(),
      'Log Entry record should be created for successfull Account link to KYC QA'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountMobileNumbersAlreadyMatch() {
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
    ];

    // Sharing Case record manually to avoid deployment issues
    List<Case> newCases = [SELECT Id FROM Case];
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = ocvIntegrationUser.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT Id FROM Case WHERE AccountId = :testAccount.Id].size(),
      'Link the KYC QA Case with the relevant Customer using the Mobile Number'
    );

    List<LogEntry__c> logEntryList = Database.query(
      'SELECT ID, Log__c, LogMessage__c FROM LogEntry__c WHERE LogMessage__c LIKE \'%' +
        AccountCommonActions.CUSTOMER_LINKED_TO_KYC_QA_SUCCESS +
        '%\''
    );

    Assert.areEqual(
      1,
      logEntryList.size(),
      'Log Entry record should be created for successfull Account link to KYC QA'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountMobileNumbersRequireSanitising() {
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '040 112-3123'
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
    ];

    // Sharing Case record manually to avoid deployment issues
    List<Case> newCases = [SELECT Id FROM Case];
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = ocvIntegrationUser.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    Assert.areEqual(
      1,
      [SELECT Id FROM Case WHERE AccountId = :testAccount.Id].size(),
      'Link the KYC QA Case with the relevant Customer using the Mobile Number'
    );

    List<LogEntry__c> logEntryList = Database.query(
      'SELECT ID, Log__c, LogMessage__c FROM LogEntry__c WHERE LogMessage__c LIKE \'%' +
        AccountCommonActions.CUSTOMER_LINKED_TO_KYC_QA_SUCCESS +
        '%\''
    );

    Assert.areEqual(
      1,
      logEntryList.size(),
      'Log Entry record should be created for successfull Account link to KYC QA'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountNoCustomerLinked() {
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = TESTFAKER.randomString(10)
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
    ];

    // Sharing Case record manually to avoid deployment issues
    List<Case> newCases = [SELECT Id FROM Case];
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = ocvIntegrationUser.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    Assert.areEqual(
      0,
      [SELECT Id FROM Case WHERE AccountId = :testAccount.Id].size(),
      'KYC QA Case created with no customer linked to it when OCV ID/Mobile Number Comparison is not a match'
    );

    List<LogEntry__c> logEntryList = Database.query(
      'SELECT ID, Log__c, LogMessage__c FROM LogEntry__c WHERE LogMessage__c LIKE \'%' +
        AccountCommonActions.CUSTOMER_LINKED_TO_KYC_QA_SUCCESS +
        '%\''
    );

    Assert.areEqual(
      0,
      logEntryList.size(),
      'Log Entry record should\'nt be created since no Account was linked'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountError() {
    Account testAccount = new Account(
      FirstName = 'Bruce',
      LastName = 'Something',
      OCV_ID__c = TESTFAKER.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      PersonEmail = 'john.something@gmail.com',
      PersonMobilePhone = '0401123123'
    );

    Test.startTest();
    User ocvIntegrationUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserOCV'
    ];

    // Sharing Case record manually to avoid deployment issues
    List<Case> newCases = [SELECT Id FROM Case];
    CaseShare cs = new CaseShare();
    cs.CaseId = newCases[0].id;
    cs.UserOrGroupId = ocvIntegrationUser.Id;
    cs.CaseAccessLevel = 'Edit';
    insert cs;

    AccountCommonActions.forceDMLError = true; // Simulate a DML error

    System.runAs(ocvIntegrationUser) {
      insert testAccount;
    }
    Test.stopTest();

    List<LogEntry__c> logEntryList = Database.query(
      'SELECT ID, Log__c, LogMessage__c FROM LogEntry__c WHERE LogMessage__c LIKE \'%' +
        AccountCommonActions.CUSTOMER_LINKED_TO_KYC_QA_ERROR +
        '%\''
    );

    Assert.areEqual(
      1,
      logEntryList.size(),
      'Log Entry record should be created for an error on attempt to link Account to KYC QA'
    );
  }
}
