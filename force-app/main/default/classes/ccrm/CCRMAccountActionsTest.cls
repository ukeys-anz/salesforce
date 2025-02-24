/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Account Action Test is the test class for CCRM Account Actions Class.
 */
@isTest
private class CCRMAccountActionsTest {
  @testSetup
  static void setup() {
    User ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
    CCRMTestDataFactory.createTwilioIntegrationUser();
    Account acc;
    Account prospectAcc;
    System.runAs(CCRMTestDataFactory.getOcvIntegrationUser()) {
      //GIVEN a active account
      acc = CCRMTestDataFactory.createBusinessAccountWithOwner(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );

      prospectAcc = CCRMTestDataFactory.createProspectBusinessAccount(
        CCRMTestDataFactory.getOcvIntegrationUser().Id
      );
    }

    CCRMTestDataFactory.createAccountShare(acc.Id, ccrmBaseUser.Id);
    CCRMTestDataFactory.createAccountShare(prospectAcc.Id, ccrmBaseUser.Id);

    Set<String> setOfEmployeeId = new Set<String>{ '30456789', '10456790' };
    CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);

    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
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
        ANZx_Customer__c = false
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
        ANZx_Customer__c = false,
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
        ANZx_Customer__c = false,
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
      l.Registered_Company__c = 'Yes';
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
      ANZx_Customer__c = false,
      RecordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID,
      Source_System_Name__c = System.Label.CCRM_Source_System_Name,
      Source_System_ID__c = '123456789',
      FinServ__Status__c = 'Active'
    );

    Test.startTest();
    // WHEN this account is inserted by OCV Integration User
    System.runAs(CCRMTestDataFactory.getOCVIntegrationUser()) {
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
      CCRMConstants.STATUS_ASSIGNED,
      le.Status,
      'Lead should not convert from CCRM account creation.'
    );
  }

  @IsTest
  static void testTrackProspectAccountChanges() {
    //GIVEN a prospect account
    Account acc = [
      SELECT Id, Name, ABN__c, ACN__c, ARBN__c
      FROM Account
      WHERE
        FinServ__Status__c = 'Prospect'
        AND RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
        AND ABN__c = '50 110 219 460'
        AND Source_System_Name__c = 'CAP-CIS'
      LIMIT 1
    ];
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

  @IsTest
  static void testTrackActiveAccountChanges() {
    //GIVEN there's a active business account
    Account acc = [
      SELECT ID, Name, advertising_Indicator__c, disclosure_Indicator__c
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];

    //WHEN the account is updated by banker
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      acc.advertising_Indicator__c = 'Y';
      acc.disclosure_Indicator__c = 'N';
      update acc;

      Test.stopTest();
    }

    //THEN a Customer_Profile_Updates__c record is created accordingly to track the changes
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Customer_Profile_Updates__c
        WHERE Customer_Name__c = :acc.Id
      ],
      '1 Customer_Profile_Updates__c record should be created when advertising & disclosure indicator are updated'
    );
  }

  @isTest
  static void testValidateCustomerInformation() {
    Database.SaveResult result;
    //GIVEN A active account with ABN as  50 110 219 460
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Pty Ltd'];
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN the account is updated by a Banker user to change ABN with value greater than 11
      testAccount.ABN__c = '50 110 219 460 56';
      result = Database.update(testAccount, false);
      Test.stopTest();
    }

    //THEN an error should be added to the record for change in ABN
    // Verify
    System.assertEquals(
      2,
      result.getErrors().size(),
      'ABN should not be greater than 11 characters'
    );
  }

  @isTest
  static void testValidatelength() {
    //GIVEN A active account with ABN as  50 110 219 460
    String newValue = 'Business';
    String oldvalue = 'BA';
    String recordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID;
    String errorMessage = '';
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Test.startTest();
      //WHEN the account is updated by a Banker user to change ABN with value greater than 11
      //CCRMAccountActions acountActionsInstance = new CCRMAccountActions();
      CCRMAccountActions.AccountFieldValidation accValidationInstance = new CCRMAccountActions.AccountFieldValidation(
        'FinServ__CustomerType__c',
        System.Label.CCRM_CustomerTypeLengthCheck,
        2,
        false,
        new Set<String>{
          String.valueOf(CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID),
          String.valueOf(CCRMConstants.ACCOUNT_PERSON_RT_ID)
        }
      );
      errorMessage = accValidationInstance.validateLength(
        newValue,
        oldvalue,
        recordTypeId
      );
      Test.stopTest();
    }
    //THEN an error should be added to the record for change in ABN
    // Verify
    System.assertEquals(
      errorMessage,
      System.Label.CCRM_CustomerTypeLengthCheck,
      'Customer Type Length cannot be greater than 2 characters.'
    );
  }

  /**
   * @description test method for PreventEditShellProspect
   */
  @isTest
  static void testPreventEditShellProspect() {
    ID accountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Account> accList = new List<Account>();
    accList.add(
      new Account(
        Id = accountId1,
        recordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID,
        OCV_Event_Version__c = 0
      )
    );

    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      // Positive Scenario
      try {
        CCRMAccountActions.preventEditShellProspect(accList);
      } catch (Exception ex) {
        Boolean expectedExceptionThrown = ex.getMessage()
            .contains(Label.ML_ShellProspect_Update_ErrorMessage)
          ? true
          : false;
        system.assertEquals(
          true,
          expectedExceptionThrown,
          'preventEditShellProspect is not Preventing Shell Records to Update'
        );
      }
      // Negative Scenario
      try {
        accList[0].OCV_Event_Version__c = 1;
        CCRMAccountActions.preventEditShellProspect(accList);
      } catch (Exception ex) {
        Boolean expectedExceptionThrown = ex.getMessage()
            .contains(Label.ML_ShellProspect_Update_ErrorMessage)
          ? true
          : false;
        system.assertEquals(
          false,
          expectedExceptionThrown,
          'preventEditShellProspect is Preventing to update for Non-Shell Records'
        );
      }
    }
  }

  /**
   * @description test method for preventEditOcvId
   */
  @isTest
  static void testPreventEditOcvId() {
    ID accountId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> accMap = new Map<Id, Account>{
      accountId1 => (new Account(
        Id = accountId1,
        recordTypeId = CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID,
        OCV_ID__c = '1234'
      ))
    };
    List<Account> accList = accMap.values();
    accList[0].OCV_ID__c = 'test';

    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      // Positive Scenario
      try {
        CCRMAccountActions.preventEditOcvId(accList, accMap);
      } catch (Exception ex) {
        Boolean expectedExceptionThrown = ex.getMessage()
            .contains(Label.ML_OCV_ID_Update_ErrorMessage)
          ? true
          : false;
        system.assertEquals(
          true,
          expectedExceptionThrown,
          'PreventEditOcvId is not Preventing OCV Id'
        );
      }
      //Negative Scenario
      try {
        CCRMAccountActions.preventEditOcvId(accMap.values(), accMap);
      } catch (Exception ex) {
        Boolean expectedExceptionThrown = ex.getMessage()
            .contains(Label.ML_OCV_ID_Update_ErrorMessage)
          ? true
          : false;
        system.assertEquals(
          true,
          expectedExceptionThrown,
          'PreventEditOcvId thowing error when OCV id is not changed'
        );
      }
    }
  }

  /**
   * @description test method for preventEditOcvId
   */
  @isTest
  static void testBypassPreventEditRecords() {
    System.runAs(MLCRMTestDataFactory.getMLCRMBaseUser()) {
      system.assertEquals(
        false,
        CCRMAccountActions.bypassPreventEditRecords(),
        'ML user is able to bypass PreventEdit Check'
      );
    }
    User ocvIntegrationUser = MLCRMTestDataFactory.createMLCRMIntegrationUser(
      Label.CCRM_OCVIntegrationUsername + '.test123'
    );
    System.runAs(ocvIntegrationUser) {
      system.assertEquals(
        true,
        CCRMAccountActions.bypassPreventEditRecords(),
        'ML user is able to bypass PreventEdit Check'
      );
    }
  }
}
