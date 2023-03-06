/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Account Action Test is the test class for CCRM Account Actions Class.
 */
@isTest
private class CCRMAccountActionsTest {
  static Faker faker = new Faker('AU');

  @testSetup
  static void setup() {
    User ccrmAdmin = CCRMTestDataFactory.createAdminUser();
    CCRMTestDataFactory.createCCRMBaseUser();
    CCRMTestDataFactory.createTwilioIntegrationUser();

    System.runAs(ccrmAdmin) {
      Set<String> setOfEmployeeId = new Set<String>{ '30456789', '10456790' };
      CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);
    }
    System.runAs(ccrmAdmin) {
      Map<String, String> values = new Map<String, String>{
        'L7601' => '30456789',
        'L7602' => '30456790'
      };
      CCRMTestDataFactory.createControllingPosts(values);
    }
  }

  @isTest
  static void testRevertAccountChanges() {
    Faker faker = new Faker('AU');
    Account testAccount;
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();

      //GIVEN When a new account in created
      testAccount = new Account(
        FirstName = 'John',
        LastName = 'Doe',
        OCV_ID__c = faker.randomString(10),
        AR_C_Customer__c = true
      );
      insert testAccount;

      //WHEN the account is updated by a Banker user
      testAccount.FirstName = 'Steve';
      testAccount.LastName = 'Rogers';
      update testAccount;
      Test.stopTest();
    }
    //THEN the changes are reverted to its old value
    testAccount = [
      SELECT Id, FirstName, LastName
      FROM Account
      WHERE id = :testAccount.id
    ];
    System.assertEquals(
      'John',
      testAccount.FirstName,
      'FirstName is not reverted to old value'
    );
    System.assertEquals(
      'Doe',
      testAccount.LastName,
      'LastName is not reverted to old value'
    );
  }

  @isTest
  static void testCreateAccount() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //Given when banker creates a new Account
      //When CPID is set to a valid CPID
      //Then CPID Link will not be null, it is a hyperlink string
      Account acc = new Account(
        Name = 'Test ANZx Account',
        OCV_ID__c = 'TESTOCVID4321',
        AR_C_Customer__c = true,
        CPID__c = 'L7601'
      );
      insert acc;

      acc = [SELECT Id, CPID_Link__c FROM Account WHERE id = :acc.id];

      System.assertNotEquals(acc.CPID_Link__c, null, acc.CPID_Link__c);
      Test.stopTest();
    }
  }

  @isTest
  static void testCreateAccountWithNoCPID() {
    //Given when banker creates a new Account
    //When CPID is set to a invalid CPID
    //Then CPID Link will be null
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      Account acc1 = new Account(
        Name = 'Test ANZx Account',
        OCV_ID__c = 'TESTOCVID4321',
        AR_C_Customer__c = true,
        CPID__c = 'L7603'
      );
      insert acc1;
      acc1 = [SELECT Id, CPID_Link__c FROM Account WHERE id = :acc1.id];

      System.assertEquals(acc1.CPID_Link__c, 'L7603', 'CPID is plain text');
      Test.stopTest();
    }
  }

  @isTest
  static void testSetControllingPostForANZPlusAccount() {
    Faker faker = new Faker('AU');
    User twilioUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IntegrationUserTwilio'
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ];

    Account testAccount = new Account(
      Name = 'Test ANZx Account',
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );
    insert testAccount;

    System.runAs(twilioUser) {
      Test.startTest();
      //Given when Twilio Integration user updates the ANZx Account
      //When CPID is not populated
      testAccount.Name = 'Test ANZx Account Update';
      update testAccount;
      //Then Controlling post will not be set and CPID Link will be null
      testAccount = [
        SELECT Id, CPID_Link__c
        FROM Account
        WHERE id = :testAccount.id
      ];
      System.assertEquals(
        testAccount.CPID_Link__c,
        null,
        'CPID should be null'
      );
      Test.stopTest();
    }
  }

  @isTest
  private static void testConvertLeadDuringAccountInsert() {
    Faker faker = new Faker('AU');
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Lead l = new Lead();
      l.Firstname = 'John';
      l.Lastname = 'Something';
      l.Company = 'Test Company';
      l.Email = 'john.something@gmail.com';
      l.RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID;
      l.CAPCIS_ID__c = '123456789';
      l.LeadSource = 'ANZ.com';
      l.MobilePhone = '+61412345678';
      l.Skip_Validations__c = 'ConvertLead';
      insert l;
    }
    // GIVEN an account with matching capcis ID
    Account testAccount = new Account(
      Name = 'Test Company',
      OCV_ID__c = faker.randomString(10),
      AR_C_Customer__c = true,
      RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID,
      Source_System_Name__c = System.Label.CCRM_Source_System_Name,
      Source_System_ID__c = '123456789',
      FinServ__Status__c = 'Active'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      insert testAccount;
    }
    Test.stopTest();

    // THEN the existing lead is converted into this account
    Lead le = [
      SELECT Id, Status
      FROM Lead
      WHERE Firstname = 'John' AND Lastname = 'Something'
      LIMIT 1
    ];
    System.assertEquals(
      'Converted',
      le.Status,
      'Lead should have been converted.'
    );
  }

  @IsTest
  static void testTrackProspectAccountChanges() {
    Account acc;
    //GIVEN a prospect account
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      acc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getCCRMBaseUser().Id
      );
    }
    //WHEN the account is updated by banker
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      acc.Name = acc.Name + ' updated ';
      acc.ABN__c = '51 824 753 556';
      acc.ACN__c = '007 499 989';
      acc.ARBN__c = '123 456 789';
      update acc;
    }
    Test.stopTest();

    //THEN a Customer_Profile_Updates__c record is created accordingly to track the changes
    System.assertEquals(
      2,
      [
        SELECT COUNT()
        FROM Customer_Profile_Updates__c
        WHERE Customer_Name__c = :acc.Id
      ],
      '2 Customer_Profile_Updates__c record should be created when prospect account name and tax details are updated'
    );
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Customer_Profile_Updates__c
        WHERE
          Customer_Name__c = :acc.Id
          AND TriggeredFrom__c = 'Account.TaxDetails'
      ],
      'Customer_Profile_Updates__c with TriggeredFrom__c = "Account.TaxDetails" should be created when prospect ABN/ACN/ARBN are updated'
    );
  }
}
