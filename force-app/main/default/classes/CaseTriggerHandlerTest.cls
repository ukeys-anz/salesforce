// CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
@SuppressWarnings('PMD.CyclomaticComplexity')
@IsTest
private class CaseTriggerHandlerTest {
  public static Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
    Case.Type
  );

  private static final List<String> COB_CLOSED_STATUSES = new List<String>{
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();

  private static final String FAILED_RESON = 'Selfie fail - selfie image is not clear enough to match';

  private static final String EMPTY_FAILED_REASON = '';

  private static final List<String> COB_MATCHING_MOBILE_NUMBERS = new List<String>{
    '61412121212',
    '61413131313',
    '61415151515'
  };

  private static final List<String> CUSTOMER_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+61412121212',
    '+61413131313',
    '+61415151515'
  };

  private static final List<String> NOT_MATCHING_MOBILE_NUMBERS = new List<String>{
    '+61412121219',
    '+61413131319'
  };

  @TestSetup
  static void setup() {
    Faker faker = new Faker('AU');
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a FraudX User with 'FraudX Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      UserRole role = CommonUtil.getUserRoleByDevName('FraudX_Agent');
      User fraudXAgent = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'FraudXTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => role.Id
        }
      );
      insert fraudXAgent;

      // Assign related PSs
      List<String> fraudXPSs = new List<String>{
        'Case_Read_Write_Fraud_Agent',
        'Customer_Read_Only',
        'Case_Read_Write_Customer_Onboarding'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :fraudXPSs
      ];

      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(fraudXAgent.Id, ps.Id));
      }
      insert psaList;

      UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
      User coach = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'CoachTest',
          'ProfileId' => profile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coach;

      // Assign related PSs
      List<String> coachPSs = new List<String>{
        'Case_Read_Write_Get_Help',
        'Case_Read_Write_Dispute',
        'Customer_Read_Only',
        'Quality_Assessment_Read_Only',
        'Case_Read_Write_Non_Customer_Complaints'
      };
      List<PermissionSet> coachPsList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :coachPSs
      ];

      List<PermissionSetAssignment> coachPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : coachPsList) {
        coachPsaList.add(TestUtil.createPSAssignment(coach.Id, ps.Id));
      }
      insert coachPsaList;

      Account[] accnts = new List<Account>();
      for (Integer i = 0; i < 2; i++) {
        accnts.add(
          new Account(
            Name = 'TestAccount',
            Display_Name__c = 'TestAccount',
            OCV_ID__c = faker.randomString(10),
            ANZx_Customer__c = true,
            // Criteria based sharing rules cannot be tested in APEX unit tests.
            // Therefore, sharing the test Account record with user by assigning ownership.
            OwnerId = fraudXAgent.Id,
            External_Id__c = faker.randomString(10)
          )
        );
      }
      // Create a PersonAccount
      Account personAcc = new Account(
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
          .get('PersonAccount')
          .getRecordTypeId(),
        FirstName = faker.randomString(5),
        LastName = faker.randomString(5),
        OCV_ID__c = 'PERSONOCV879879',
        ANZx_Customer__c = true
      );
      accnts.add(personAcc);

      Account a = new Account(
        Name = 'Complaint Entitlement Account',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = false
      );
      accnts.add(a);

      Account fraudAcc = new Account(
        Name = 'Fraud Entitlement Account',
        OCV_ID__c = faker.randomString(10)
      );
      accnts.add(fraudAcc);
      insert accnts;

      // Create IDR L1 user
      Profile anzProfile = [
        SELECT Id
        FROM Profile
        WHERE Name = 'ANZ Standard User'
        LIMIT 1
      ];

      User idrUser = (User) FakerFactory.make(new FakerUserFactory());
      idrUser.FirstName = 'IDRL1';
      idrUser.ProfileId = anzProfile.Id;
      insert idrUser;

      // Assign related PSs
      List<String> idrPsets = new List<String>{
        'IDR_User',
        'IDR_User_Level_1'
      };
      List<PermissionSet> idrPsetList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :idrPsets
      ];

      List<PermissionSetAssignment> idrPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : idrPsetList) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = idrUser.Id,
          PermissionSetId = ps.Id
        );
        idrPsaList.add(psa);
      }
      insert idrPsaList;

      // Create an Integration User
      Profile profileIntegration = CommonUtil.getProfileByName(
        'Integration User'
      );
      UserRole roleAnz = CommonUtil.getUserRoleByDevName('ANZ');
      User integrationUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'IntegrationTest',
          'ProfileId' => profileIntegration.Id,
          'UserRoleId' => roleAnz.Id
        }
      );
      insert integrationUser;

      // Assign related PSs
      List<String> integrationPsets = new List<String>{
        'View_And_Edit_Tasks',
        'Case_Read_Write_Get_Help',
        'Case_Read_Write_Dispute',
        'Read_Only_Admin'
      };

      List<PermissionSet> integrationPsList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :integrationPsets
      ];

      List<PermissionSetAssignment> integrationPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : integrationPsList) {
        integrationPsaList.add(
          TestUtil.createPSAssignment(integrationUser.Id, ps.Id)
        );
      }
      insert integrationPsaList;

      makeCOBData();
    }
    insertTestAccountsForDisputeCases();
  }

  @IsTest
  static void testCaseNumberCopy() {
    // GIVEN cases are created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN CaseNumber is copied into CaseNumber__c
    Case c = [
      SELECT CaseNumber, CaseNumber__c
      FROM Case
      WHERE Id = :newCases[0].Id
    ];
    System.assertEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber__c should be equal to CaseNumber.'
    );
    newCases.get(0).CaseNumber__c = null;
    update newCases.get(0);
    System.assertEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber__c should be equal to CaseNumber.'
    );
  }

  @isTest
  static void testFraudCustomerProfileDefaultValue() {
    Account personAcc = [SELECT Id, Name FROM Account LIMIT 1];
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.FALSE_CUSTOMER_PROFILE_RT_ID,
      AccountId = personAcc.Id
    );
    Test.startTest();
    insert newCase;
    Case c = [
      SELECT Id, Fraud_Onboarding_Customer_Name__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertEquals(
      c.Fraud_Onboarding_Customer_Name__c,
      personAcc.Name,
      'By default, the Customer name on fraud customer profile should be the customer name'
    );
    Test.stopTest();
  }

  @isTest
  static void testFraudCustomerProfileNoUpdateForGenericValue() {
    // GIVEN: We have a Fraud Cusotmer Profile case with Fraud Generic customer
    Account fraudAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Fraud Entitlement Account'
      LIMIT 1
    ];
    Account personAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name != 'Fraud Entitlement Account'
      LIMIT 1
    ];
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.FALSE_CUSTOMER_PROFILE_RT_ID,
      AccountId = fraudAcc.Id
    );

    Test.startTest();
    insert newCase;

    // WHEN we update the account to be another not generic customer
    newCase.AccountId = personAcc.Id;
    update newCase;

    // THEN the Onboarding Customer Name should not be updated
    Case updatedCase = [
      SELECT Id, Fraud_Onboarding_Customer_Name__c, AccountId
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertNotEquals(
      updatedCase.Fraud_Onboarding_Customer_Name__c,
      newCase.Fraud_Onboarding_Customer_Name__c,
      'Onboarding Customer Name should not be updated.'
    );
    Test.stopTest();
  }

  @isTest
  static void testFraudCustomerProfileUpdateValue() {
    // GIVEN: We have a Fraud Cusotmer Profile case with not Fraud Generic customer
    List<Account> personAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name != 'Fraud Entitlement Account'
      LIMIT 2
    ];
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.FALSE_CUSTOMER_PROFILE_RT_ID,
      AccountId = personAcc[0].Id
    );

    Test.startTest();
    insert newCase;

    // WHEN we update the account to be another not generic customer
    newCase.AccountId = personAcc[1].Id;
    update newCase;

    // THEN the Onboarding Customer Name should be updated
    Case updatedCase = [
      SELECT Id, Fraud_Onboarding_Customer_Name__c, AccountId
      FROM Case
      WHERE Id = :newCase.Id
    ];

    System.assertEquals(
      updatedCase.Fraud_Onboarding_Customer_Name__c,
      personAcc[1].Name,
      'When we update a real customer, that should update the Onboarding Customer Name as well.'
    );
    Test.stopTest();
  }

  @IsTest
  static void testCaseNumberNoCopy() {
    // GIVEN cases which already have their case number copied
    Case[] casesWithCopiedCaseNumber = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesWithCopiedCaseNumber.add(
        new Case(
          CaseNumber__c = '123' + i,
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert casesWithCopiedCaseNumber;
    // THEN CaseNumber is not copied into CaseNumber__c
    Case c = [
      SELECT CaseNumber, CaseNumber__c
      FROM Case
      WHERE Id = :casesWithCopiedCaseNumber[0].Id
    ];
    System.assertNotEquals(
      c.CaseNumber,
      c.CaseNumber__c,
      'CaseNumber should not have been copied.'
    );
    System.assertEquals(
      '1230',
      c.CaseNumber__c,
      'CaseNumber__c should not have changed.'
    );
  }
  @IsTest
  static void testComplaintCardNumberMasking() {
    // GIVEN cases relate to a account/card/policy, description etc with numbers greater than 8 digits
    Case[] casesWithNumberText = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesWithNumberText.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test decription 1234-5678-9101-7632-3321 check mask',
          IDR_Complainant_Desired_Outcome__c = 'Test decription 1234-5678-9101-7632-3321 check mask',
          IDR_Description_of_Outcome__c = 'Test decription 1234-5678-9101-7632-3321 check mask',
          IDR_Systemic_Issue_Description__c = 'Test decription 1234-5678-9101-7632-3321 check mask',
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890'
        )
      );
    }

    // WHEN they are inserted
    insert casesWithNumberText;
    // THEN IDR_Account_Card_Policy_Number__c is masked along with description etc fields, showing only the last four digits
    Case c = [
      SELECT
        IDR_Account_Card_Policy_Number__c,
        Description,
        IDR_Complainant_Desired_Outcome__c,
        IDR_Description_of_Outcome__c,
        IDR_Reason_for_re_opening__c,
        IDR_Systemic_Issue_Description__c
      FROM Case
      WHERE Id = :casesWithNumberText[0].Id
    ];
    System.assertEquals(
      '*****1234',
      c.IDR_Account_Card_Policy_Number__c,
      'IDR_Account_Card_Policy_Number__c should be masked.'
    );
    System.assertEquals(
      'Test decription ****************3321 check mask',
      c.Description,
      'Description should be masked.'
    );
    System.assertEquals(
      'Test decription ****************3321 check mask',
      c.IDR_Complainant_Desired_Outcome__c,
      'IDR_Complainant_Desired_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ****************3321 check mask',
      c.IDR_Description_of_Outcome__c,
      'IDR_Description_of_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ****************3321 check mask',
      c.IDR_Systemic_Issue_Description__c,
      'IDR_Systemic_Issue_Description__c should be masked.'
    );
  }

  @IsTest
  static void testIsComplaintEscalatedInsert() {
    // GIVEN cases are created as escalated
    Case[] newCasesWithStatus = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCasesWithStatus.add(
        new Case(
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1',
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert newCasesWithStatus;
    // THEN check if IsEscalated is true
    Case c = [
      SELECT CaseNumber, IsEscalated
      FROM Case
      WHERE Id = :newCasesWithStatus[0].Id
    ];
    System.assert(c.IsEscalated, 'IsEscalated is true');
  }

  @IsTest
  static void testIsComplaintEscalatedUpdate() {
    // GIVEN cases are created as not escalated
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN check if IsEscalated is false
    Case c = [
      SELECT CaseNumber, IsEscalated
      FROM Case
      WHERE Id = :newCases[0].Id
    ];
    System.assert(!c.IsEscalated, 'IsEscalated is false');

    // GIVEN cases switch to escalated
    for (Integer i = 0; i < newCases.size(); i++) {
      newCases[i].Status = 'Escalated';
      newCases[i].IDR_Escalated_to__c = '1';
      newCases[i].IDR_Escalation_Reason__c = '1';
    }
    // WHEN they are updated
    update newCases;
    // THEN check if IsEscalated is true
    c = [SELECT CaseNumber, IsEscalated FROM Case WHERE Id = :newCases[0].Id];
    System.assert(c.IsEscalated, 'IsEscalated is true');
  }

  @IsTest
  static void testComplaintEscalationStatus() {
    // GIVEN cases are created as not escalated
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open',
          IDR_Escalated_to__c = '1'
        )
      );
    }
    insert newCases;

    // WHEN they are auto-escalated (kind of)
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].IsEscalated = true;
      newCases[i].OwnerId = IDRCaseActions.queue.Id;
    }
    update newCases;

    // THEN check escalation fields
    Case c = [
      SELECT Status, IDR_Escalated_to__c, IDR_Escalation_Reason__c
      FROM Case
      WHERE Id = :newCases[0].Id
    ];
    System.assertEquals(
      'Escalated',
      c.Status,
      'Status should have been updated to Escalated '
    );
    System.assertEquals(
      '1',
      c.IDR_Escalated_to__c,
      'Escalated To should have been updated to CRP '
    );
    System.assertEquals(
      IDRCaseActions.DAY_5_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation Reason should have been updated to DAY_5_ESCALATION_REASON '
    );
  }

  @isTest
  static void testDateWhenComplaintIsReopened() {
    // GIVEN cases are created as not re-openened
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Closed',
          IDR_Complaint_Outcome__c = '1',
          IDR_Description_of_Outcome__c = 'test'
        )
      );
    }
    // WHEN they are insterted
    insert newCases;
    // THEN check if re-openened date is null
    Case c = [
      SELECT CaseNumber, IDR_Date_Re_Opened__c
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(null, c.IDR_Date_Re_Opened__c, 'Date is null');

    // GIVEN cases are updated as re-openened
    for (Integer i = 0; i < newCases.size(); i++) {
      newCases[i].Status = 'Re-opened';
      newCases[i].IDR_Reason_for_re_opening__c = '1';
    }
    // WHEN they are updated
    update newCases;
    // THEN check if date is todays date
    c = [
      SELECT CaseNumber, IDR_Date_Re_Opened__c, IsEscalated
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(
      System.today(),
      c.IDR_Date_Re_Opened__c,
      'Date is current date'
    );
    System.assert(!c.IsEscalated, 'IsEscalated is false');
  }

  @istest
  static void testAnonymousComplaint() {
    // GIVEN cases are created and consent not obtained
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          IDR_NC_Is_Consent_Obtained__c = false,
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID
        )
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN check if names have been anonymised
    Case c = [
      SELECT
        CaseNumber,
        IDR_NC_First_Name__c,
        IDR_NC_Middle_Names__c,
        IDR_NC_Last_Name__c
      FROM Case
      WHERE id = :newCases[0].id
    ];
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_First_Name__c,
      'Name is anonymised'
    );
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_Middle_Names__c,
      'Name is anonymised'
    );
    System.assertEquals(
      Label.Anonymous_Complainant,
      c.IDR_NC_Last_Name__c,
      'Name is anonymised'
    );
  }

  @istest
  static void testComplaintAssignment() {
    // GIVEN complaints are created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    // WHEN they are inserted
    insert newCases;
    // THEN office field matches the case owner's
    User currentUser = [
      SELECT Id, Division
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    Case c = [SELECT IDR_Office__c FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      currentUser.Division,
      c.IDR_Office__c,
      'Office is current owner\'s division'
    );

    // GIVEN complaint is reassigned to another User
    Profile p = CommonUtil.getProfileByName('Standard User');
    User idrUser = new User(
      Alias = 'idruse',
      Email = 'idruser@anz.com',
      LastName = 'Testing',
      ProfileId = p.Id,
      UserName = 'idruser@anztest.com',
      LocaleSidKey = 'en_US',
      TimeZoneSidKey = 'GMT',
      LanguageLocaleKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      Division = 'IDR Test Office'
    );
    insert idrUser;
    c.OwnerId = idrUser.Id;
    // WHEN complaint is updated
    update c;
    // THEN Office has changed to new user's
    idrUser = [
      SELECT Division
      FROM User
      WHERE UserName = 'idruser@anztest.com'
    ];
    c = [SELECT IDR_Office__c FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      idrUser.Division,
      c.IDR_Office__c,
      'Office is new owner\'s division'
    );
  }

  @istest
  static void testIDRCaseDelete() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID)
      );
    }
    insert newCases;

    try {
      delete newCases;
      System.assert(false, 'Failed to protect against user deleting cases');
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('You cannot delete cases'),
        'Cases Cannot be deleted'
      );
    }
  }

  @isTest
  static void testParentCaseValidation() {
    List<Account> accList = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 2
    ];
    // create 2 parent cases
    List<Case> parentCaseList = new List<Case>();

    for (Integer i = 0; i < 2; i++) {
      parentCaseList.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = accList[0].Id
        )
      );
    }
    insert parentCaseList;

    Test.startTest();
    // create a child case
    Case childCase = new Case(
      ParentId = parentCaseList[0].Id,
      RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
      AccountId = accList[1].Id
    );
    insert childCase;
    Test.stopTest();

    // Update parent case to throw error
    try {
      parentCaseList[0].ParentId = parentCaseList[1].Id;
      parentCaseList[0].IDR_Additional_Correspondence_Reviewed__c = true;
      update parentCaseList;
      System.assert(
        false,
        'Failed to prevent against user adding parent case when it has already related to child cases'
      );
    } catch (DmlException e) {
      System.assertEquals(
        'You cannot add parent case. This case is associated with child cases',
        e.getDmlMessage(0),
        'Error message should be as expected.'
      );
    }
  }

  //Tests if Additional Types selected contain the selected value of Type
  @isTest
  static void testDuplicateAdditionalTypeValidation() {
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id,
          Type = 'Card',
          Additional_Type__c = 'App Support;Card;'
        )
      );
    }

    try {
      insert newCases;
      System.assert(
        false,
        'Failed to prevent user selecting duplicate values in additional type when the value exists in primary type'
      );
    } catch (DMLexception e) {
      System.assert(
        e.getMessage()
          .contains(
            'You cannot select a value in Additional Type that is already selected as the Primary Type.'
          ),
        e.getDmlMessage(0)
      );
    }
  }

  //Tests if more than 2 Additional Types have been selected
  @isTest
  static void testAdditionalTypesValidation() {
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id,
          Additional_Type__c = 'App Support;Card;Coaching'
        )
      );
    }

    try {
      insert newCases;
      System.assert(
        false,
        'Failed to prevent against user selecting two additional types'
      );
    } catch (DMLexception e) {
      System.assert(
        e.getMessage()
          .contains('You cannot select more than two Additional Types.'),
        e.getDmlMessage(0)
      );
    }
  }

  //Tests if the Case Subject is populated correctly based on case type and sub type.
  @isTest
  static void testPopulateCaseSubject() {
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          Type = 'Cards',
          Sub_Type__c = 'Damaged card',
          AccountId = acc.Id
        )
      );
    }

    insert newCases;

    newCases[0].Type = 'Cards';
    newCases[0].Sub_Type__c = 'Damaged card';
    update newCases;

    newCases = [SELECT Subject FROM Case WHERE id = :newCases[0].id];

    System.assertEquals(
      'Cards - Damaged card',
      newCases[0].Subject,
      'New case subject shoudl be as expected.'
    );
  }

  //Tests if the Case Subject is populated correctly when no sub types.
  @isTest
  static void testNoSubTypeCaseSubject() {
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          Type = 'Cards',
          Sub_Type__c = '',
          AccountId = acc.Id
        )
      );
    }

    insert newCases;

    newCases[0].Type = 'Cards';
    newCases[0].Sub_Type__c = '';
    update newCases;

    newCases = [SELECT Subject FROM Case WHERE id = :newCases[0].id];

    System.assertEquals(
      'Cards',
      newCases[0].Subject,
      'New case subject should be as expected.'
    );
  }
  //Tests if the Case Subject is populated correctly when adding two sub types.
  @isTest
  static void testMultipleSubTypeCaseSubject() {
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          Type = 'Cards',
          Sub_Type__c = 'Damaged card;Using card',
          AccountId = acc.Id
        )
      );
    }

    insert newCases;

    newCases[0].Type = 'Cards';
    newCases[0].Sub_Type__c = 'Damaged card;Using card';
    update newCases;

    newCases = [SELECT Subject FROM Case WHERE id = :newCases[0].id];

    System.assertEquals(
      'Cards - Damaged card - Using card',
      newCases[0].Subject,
      'New case subject should be as expected.'
    );
  }

  //Tests if the complaints entitlment logic in working as expected.
  @isTest
  static void testComplaintEntilement() {
    Account a = [
      SELECT Id
      FROM Account
      WHERE Name = 'Complaint Entitlement Account'
      LIMIT 1
    ];

    SlaProcess sla = CommonUtil.getSLAProcess(
      GetHelpConstants.COMPLAINTS_SLA_PROCESS_NAME
    );

    Entitlement et = new Entitlement(
      Name = 'Complaints Entitlement',
      AccountId = a.Id,
      StartDate = Date.valueof(System.now().addDays(-2)),
      SlaProcessId = sla?.Id
    );
    insert et;
    Case[] complaintCaselist = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      complaintCaselist.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test check entitlement',
          IDR_Complainant_Desired_Outcome__c = 'entitlement id populated',
          IDR_Description_of_Outcome__c = 'entitlement id populated',
          IDR_Systemic_Issue_Description__c = 'None',
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890'
        )
      );
    }
    insert complaintCaselist;
    case checkEntitlment = [
      SELECT Id, EntitlementId, Status, IDR_Milestone_Sla__c
      FROM Case
      WHERE Id = :complaintCaselist[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      et.Id,
      checkEntitlment.EntitlementId,
      'Complaint entitlement id should be as expected.'
    );
    System.assertEquals(
      'Normal',
      checkEntitlment.IDR_Milestone_Sla__c,
      'Complaint entitlement IDR_Milestone_Sla should be as expected.'
    );
    CheckRecursive.firstCall = false;

    checkEntitlment.Status = 'Under Investigation';
    checkEntitlment.IDR_Milestone_Sla__c = '2 business days';
    update checkEntitlment;
    case checkMilestone = [
      SELECT Id, EntitlementId, Status, IDR_Milestone_Sla__c
      FROM Case
      WHERE Id = :complaintCaselist[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      'Normal',
      checkMilestone.IDR_Milestone_Sla__c,
      'IDR_Milestone_Sla should be as expected.'
    );
  }

  @isTest
  static void testRollupRelatedBugOnDelete() {
    insert new Reported_Bug__c(Name = 'Test Bug');
    Id bugId = [SELECT Id FROM Reported_Bug__c WHERE Name = 'Test Bug' LIMIT 1]
    .Id;
    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          Related_Bug__c = bugId,
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = accountId
        )
      );
    }
    insert newCases;

    Case deleteCase = [SELECT Id, Related_Bug__c FROM Case LIMIT 1];

    Test.startTest();
    delete deleteCase;
    Test.stopTest();

    Decimal relatedCaseNumber = [
      SELECT Number_of_Related_Cases__c
      FROM Reported_Bug__c
      WHERE Name = 'Test Bug'
      LIMIT 1
    ]
    .Number_of_Related_Cases__c;
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size) - 1,
      relatedCaseNumber,
      'Incorrect reported bug rollup value'
    );
  }

  @isTest
  static void testRollupRelatedBugOnNoBug() {
    insert new Reported_Bug__c(Name = 'Test Bug');

    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = accountId
        )
      );
    }

    Test.startTest();
    insert newCases;
    Test.stopTest();

    Decimal relatedCaseNumber = [
      SELECT Number_of_Related_Cases__c
      FROM Reported_Bug__c
      WHERE Name = 'Test Bug'
      LIMIT 1
    ]
    .Number_of_Related_Cases__c;
    System.assertEquals(
      0,
      relatedCaseNumber,
      'Incorrect reported bug rollup value'
    );
  }

  //Tests if the Fraud Case Subject is populated correctly based on case record type and type.
  @isTest
  static void testPopulateFraudCaseSubject() {
    Faker faker = new Faker('AU');
    List<String> caseTypes = new List<String>{ 'Remote Access', 'Not a Scam' };

    // GIVEN FraudX Agent user has required acces
    // Query for API User
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // WHEN FraudX Agent user creates or updates a Fraud case
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = new List<Id>(CheckCaseRecordType.FRAUD_RT_IDS)[
            faker.randomIntegerBetween(1, 4)
          ],
          Type = faker.randomElement(caseTypes),
          AccountId = acc.Id
        )
      );
    }

    Test.startTest();
    System.runAs(usr) {
      insert newCases;
    }
    Test.stopTest();

    // THEN Case Subject should be autopopulated based on RecordType Name and Type

    // Verify subject on one of the inserted Cases
    Case sampleCase1 = [
      SELECT Id, Type, RecordType.Name, Subject
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleCase1.RecordType.Name +
      ' - ' +
      caseTypeLabelByValue.get(sampleCase1.Type),
      sampleCase1.Subject,
      'Failed to autopopulate Subject on Fraud cases as expected, while inserting'
    );

    // Validate UPDATE behaviour
    newCases[0].Type = 'Investment';
    update newCases[0];

    Case sampleCase2 = [
      SELECT Id, Type, RecordType.Name, Subject
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleCase2.RecordType.Name +
      ' - ' +
      sampleCase2.Type,
      sampleCase2.Subject,
      'Failed to autopopulate Subject on Fraud cases as expected, while updating'
    );
  }

  // Note: this test class only tests the create scenario, not the update scenario.
  // A separate test method was created for update scenario, insufficient permissions cause it to fail
  // Code is now consolidated in here, to only create caseList2 code is required
  @isTest
  static void testPSITaskCreation() {
    // GIVEN complaint cases which are possibly systemic issues
    Case[] caseList1 = new List<Case>();
    Case[] caseList2 = new List<Case>();
    User level1User = [SELECT Id FROM User WHERE FirstName = 'IDRL1'];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      caseList1.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Is_Common__c = 'Yes',
          IDR_Systemic_Issue_Description__c = 'Test Description',
          IDR_Systemic_Issue_Category__c = '1',
          Status = 'Closed',
          IDR_Complaint_Outcome__c = '1',
          IDR_Complaint_Remedy__c = '2',
          IDR_Non_Financial_Remedy__c = '5',
          IDR_Description_of_Outcome__c = 'Test',
          Priority = 'Medium'
        )
      );
    }
    test.startTest();
    System.runAs(level1User) {
      // WHEN they are inserted or updated by L1 User
      insert caseList1;
      // When they are Escalated then Resolved by L1 User
      insert caseList2;
    }
    for (Case updateCase : caseList2) {
      updateCase.Status = 'Closed';
      updateCase.IDR_Complaint_Outcome__c = '1';
      updateCase.IDR_Complaint_Remedy__c = '2';
      updateCase.IDR_Non_Financial_Remedy__c = '5';
      updateCase.IDR_Description_of_Outcome__c = 'Test';
    }
    System.runAs(level1User) {
      update caseList2;
    }
    test.stopTest();
    // THEN new tasks are created and assigned to PSI queue
    List<Task> psiTasks = [SELECT Id, Subject, OwnerId FROM Task];
    if (psiTasks != null && psiTasks.size() > 0) {
      System.assertEquals(
        IDRTaskActions.siQueue.Id,
        psiTasks[0].OwnerId,
        'The new task owner id should be as expected.'
      );
      System.assertEquals(
        IDRTaskActions.IDR_TASK_SUBJECT,
        psiTasks[0].Subject,
        'The new task subject should be as expected.'
      );
    }
  }

  //Tests if the Dispute Case Subject is populated correctly based on case record type and dispute reason
  @isTest
  static void testPopulateDisputeCaseSubject() {
    Case[] newCases = new List<Case>();
    String disputeReason = 'Don\'t recognise the transaction';
    Account acc = [SELECT Id FROM Account LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
          Type = '',
          Dispute_Reason__c = disputeReason,
          AccountId = acc.Id,
          Is_The_Card_Lost_Stolen__c = 'Lost',
          Has_The_Card_Been_Stopped__c = 'Yes',
          Description = 'Some description'
        )
      );
    }
    insert newCases;
    newCases = [SELECT Subject FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      'Card - ' + disputeReason,
      newCases[0].Subject,
      'New case subject should be as expected.'
    );
  }

  //Test to verify Subject auto-population when Case Type has a numerical value different from the label
  static void testNumericCaseTypeValue() {
    Faker faker = new Faker('AU');
    // GIVEN the selected Case Types has numerical values as API names
    List<String> caseTypes = new List<String>{ '10', '11' };

    // WHEN a user creates or updates a Fradx 'Scam' case
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.SCAM_RT_ID,
          Type = faker.randomElement(caseTypes),
          AccountId = acc.Id
        )
      );
    }
    Test.startTest();
    insert newCases;
    Test.stopTest();

    // THEN Case Subject should be autopopulated based on RecordType Name and Type Label

    // Verify subject on one of the inserted Cases
    Case sampleCase1 = [
      SELECT Id, Type, RecordType.Name, Subject
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleCase1.RecordType.Name +
      ' - ' +
      caseTypeLabelByValue.get(sampleCase1.Type),
      sampleCase1.Subject,
      'Failed to autopopulate Subject with Case Type label as expected, while inserting'
    );

    // Validate UPDATE behaviour
    newCases[0].Type = '12';
    update newCases[0];

    Case sampleCase2 = [
      SELECT Id, Type, RecordType.Name, Subject
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleCase2.RecordType.Name +
      ' - ' +
      caseTypeLabelByValue.get(sampleCase2.Type),
      sampleCase2.Subject,
      'Failed to autopopulate Subject with Case Type label as expected, while updating'
    );
  }

  //Tests if KYC QA Fraud Case Subject is populated correctly based on case type.
  @isTest
  static void testPopulateKYCQAFraudCaseSubject() {
    // GIVEN FraudX Agent user has required acces
    // Query for API User
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // WHEN FraudX Agent user creates or updates a Fraud case
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = new List<Id>(CheckCaseRecordType.FRAUD_RT_IDS)[4],
          Type = 'KYC QA Sample',
          AccountId = acc.Id
        )
      );
    }
    Test.startTest();
    System.runAs(usr) {
      insert newCases;
    }
    Test.stopTest();

    // THEN Case Subject should be autopopulated based on Type

    // Verify subject on one of the inserted Cases
    Case sampleCase1 = [
      SELECT Id, Type, RecordType.Name, Subject
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleCase1.Type,
      sampleCase1.Subject,
      'Failed to autopopulate Subject on KYC QA Fraud cases as expected, while inserting'
    );
  }

  //Tests duration hours field is populated during closure time
  @isTest
  static void testUpdateCaseDurationTime() {
    Case newCase = new Case();
    newCase.IDR_Customer_Number__c = '123456789012';
    insert newCase;

    newCase.Status = 'Closed';
    newCase.IDR_Complaint_Outcome__c = '1';
    newCase.IDR_Description_of_Outcome__c = 'test';
    newCase.IDR_Is_Common__c = 'No';

    update newCase;

    newCase = [
      SELECT Id, Case_Hour_Duration__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assert(
      newCase.Case_Hour_Duration__c >= 0,
      'New case duration time hour should be as expected.'
    );
  }

  @istest
  static void testBusinessHoursAssignment() {
    Case newCase = new Case();
    newCase.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    insert newCase;

    BusinessHours bhs = [
      SELECT Id
      FROM BusinessHours
      WHERE Name = 'Case Business Hours'
    ];

    Case c = [SELECT BusinessHoursId FROM Case WHERE id = :newCase.id];

    System.assertEquals(
      bhs.Id,
      c.BusinessHoursId,
      'New case bussinessHours id should be as expected.'
    );
  }

  @istest
  static void testIDRCaseDateRecievedUpdate() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Date_Received__c = system.now()
        )
      );
    }
    insert newCases;

    case testCase = [
      SELECT Id, BusinessHoursId
      FROM case
      WHERE id = :newCases[0].Id
    ];

    task idrTask = new task(
      whatId = testCase.Id,
      Subject = IDRConstants.TASK_SUBJECT_DAY5,
      RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
      Priority = 'Standard',
      ActivityDate = system.today()
    );
    insert idrTask;

    checkRecursive.firstCall = false;

    Test.startTest();
    case updateCase = new case(
      Id = testCase.Id,
      IDR_Date_Received__c = system.now().addDays(-1)
    );
    update updateCase;
    Test.stopTest();

    task checkTask = [SELECT ActivityDate FROM Task WHERE id = :idrTask.Id];

    system.assertNotEquals(
      idrTask.ActivityDate,
      checkTask.ActivityDate,
      'IDR case date should be updated.'
    );
  }

  //Tests if ANZ Plus Case ContactId is populated correctly based on Account.
  @isTest
  static void testContactLookupPopulation() {
    // GIVEN a Person Account record is available with relevant fields on it
    Account acc = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE OCV_ID__c = 'PERSONOCV879879'
      LIMIT 1
    ];

    // WHEN an ANZ Plus Case is created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id
        )
      );
    }

    Test.startTest();
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(newCases);
    Test.stopTest();

    // THEN Contact Name lookup should be auto-populated
    System.assertEquals(
      acc.PersonContactId,
      newCases[0].ContactId,
      'Failed to auto-populate Contact lookup on ANZ Plus cases while inserting'
    );
  }

  //test the workbasket assignment for Afca referred compalints on insert
  @istest
  static void testEDRWorkbasketAssignmentOnInsert() {
    Case[] newCases = new List<Case>();
    List<Group> queueList = [
      SELECT Id, DeveloperName
      FROM Group
      WHERE DeveloperName = 'EDR_Early_Resolution' AND Type = 'Queue'
    ];

    Test.startTest();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
          IDR_Customer_Number__c = '1234567890',
          Priority = 'Financial Hardship',
          Type = '9',
          IDR_Subsequent_Issue__c = '57',
          Status = 'Escalated',
          IDR_Escalation_Reason__c = '1'
        )
      );
    }
    insert newCases;
    for (Case c : [SELECT Id, OwnerId FROM Case WHERE id IN :newCases]) {
      System.assertEquals(
        c.OwnerId.getSobjectType(),
        Group.SObjectType,
        'Case OwnerId type should be as expected.'
      );
      System.assertEquals(
        queueList[0].Id,
        c.OwnerId,
        'New case OwnerId should be as expected.'
      );
    }

    Test.stopTest();
  }

  //test the workbasket assignment for Afca referred compalints on update
  @istest
  static void testEDRWorkbasketAssignmentOnUpdate() {
    Case[] newCases = new List<Case>();
    List<Group> queueList = [
      SELECT id, developername
      FROM group
      WHERE
        developername IN (
          'Specialised_EarlyRes_Responsible_Lending',
          'EDR_Early_Resolution'
        )
        AND Type = 'Queue'
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
          IDR_Customer_Number__c = '1234567890',
          Priority = 'Standard',
          Type = '5',
          IDR_Subsequent_Issue__c = '38'
        )
      );
    }
    newCases[1].IDR_Subsequent_Issue__c = '39';
    insert newCases;
    Test.startTest();
    newCases[0].Status = 'Escalated';
    newCases[0].IDR_Escalation_Reason__c = '1';

    update newCases[0];

    Case caseRec = [SELECT Id, OwnerId FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(
      Group.SobjectType,
      caseRec.OwnerId.getSobjectType(),
      'The workbasket assignment for AFCA referred complaints on update should have the same Sobject type.'
    );
    System.assertEquals(
      queueList[1].Id,
      caseRec.OwnerId,
      'The workbasket assignment for AFCA referred complaints on update should be EDR_Early_Resolution.'
    );

    newCases[1].Status = 'Escalated';
    newCases[1].IDR_Escalation_Reason__c = '1';
    update newCases[1];

    Case caseRec1 = [SELECT Id, OwnerId FROM Case WHERE id = :newCases[1].id];
    System.assertEquals(
      Group.SobjectType,
      caseRec1.OwnerId.getSobjectType(),
      'The workbasket assignment for AFCA referred complaints on update should have the same Sobject type.'
    );
    System.assertEquals(
      queueList[0].Id,
      caseRec1.OwnerId,
      'The workbasket assignment for AFCA referred complaints on update should be Specialised_EarlyRes_Responsible_Lending.'
    );

    Test.stopTest();
  }

  @isTest
  static void testCaseNotifiationAfterUpdate() {
    Case parentCase = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
      IDR_Customer_Number__c = '1234567890',
      Priority = 'Standard',
      Type = '5',
      IDR_Subsequent_Issue__c = '38'
    );
    insert parentCase;
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
          IDR_Customer_Number__c = '1234567890',
          Priority = 'Standard',
          Type = '5',
          IDR_Subsequent_Issue__c = '38'
        )
      );
    }
    Test.startTest();
    insert newCases;
    List<Case> caseList = [
      SELECT Id, Origin, CaseNumber, ParentId
      FROM Case
      WHERE Id != :parentCase.Id
    ];
    for (Case c : caseList) {
      c.ParentId = parentCase.Id;
    }
    CheckRecursive.firstCall = false;
    update caseList;
    Test.stopTest();
    System.assertEquals(
      parentCase.Id,
      [SELECT ParentId FROM Case WHERE Id != :parentCase.Id LIMIT 1]
      .ParentId,
      'Issue while updating parentId'
    );
  }

  //test IDRCollectionAction getStartCollectionMap method
  //This test method verifies if the returned startCollection map contains IDR Collection Number from Task record and its related caseId/whatId
  @isTest
  static void testGetStartCollectionMap() {
    //Create a customer complaint
    Case custCompCase = new Case(
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED,
      IDR_Customer_Number__c = '1234567890',
      Priority = 'Standard',
      Type = '5',
      IDR_Subsequent_Issue__c = '38',
      IDR_Collection_Number__c = '1234567890'
    );
    insert custCompCase;
    Set<String> collectionAcctsList = new Set<String>();
    collectionAcctsList.add(custCompCase.IDR_Collection_Number__c);
    List<Id> caseIds = new List<Id>();
    caseIds.add(custCompCase.Id);
    List<Task> taskList = new List<Task>();
    for (Integer i = 0; i < 2; i++) {
      Task t = new Task();
      t.WhatId = custCompCase.Id;
      t.IDR_Collection_Number__c = custCompCase.IDR_Collection_Number__c;
      t.RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID;
      t.Status = 'Open';
      t.Priority = 'High';
      t.ActivityDate = system.today();
      t.Subject =
        IDRTaskActions.STOP_COLLECTIONS_SUBJECT +
        '- Account with 3rd Party/Asset Finance';
      taskList.add(t);
    }
    insert taskList;
    Test.startTest();
    Map<String, Set<Id>> startCollecMap = IDRCollectionActions.getStartCollectionMap(
      collectionAcctsList,
      caseIds
    );
    Test.stopTest();
    System.assertEquals(
      startCollecMap.containsKey(custCompCase.IDR_Collection_Number__c),
      true,
      'Collection map must contain IDR Collection Number as key'
    );
    System.assertEquals(
      startCollecMap.get(custCompCase.IDR_Collection_Number__c),
      new Set<Id>{ custCompCase.Id },
      'Incorrect caseId/whatId mapping in starCollectionMap for :' +
      custCompCase.IDR_Collection_Number__c
    );
  }

  @isTest
  static void testIsAEMConvertedSuccess() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;
    System.assert(
      GetHelpCaseActionsHelper.isAEMConverted(oldRecord, newRecord),
      'This should be an AEM converted Case'
    );
    Test.stopTest();
  }

  @isTest
  static void testIsAEMConvertedFailure() {
    Faker faker = new Faker('AU');
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = GetHelpConstants.FRAUD_RT_ID;
    System.assert(
      !GetHelpCaseActionsHelper.isAEMConverted(oldRecord, newRecord),
      'This should not be an AEM converted Case'
    );
    Test.stopTest();
  }

  @isTest
  static void testEntitlementChangeUnauthToGeneralEnquiry() {
    // a case record is created with relevant entitlements
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    // GIVEN
    // We have one unauthenticated enquiry case
    Faker faker = new Faker('AU');
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.AccountId = acc.Id;
    caseRecord.Type = '11';
    insert caseRecord;

    // THEN
    // the same Entitlement record on Account should be linked on the Case
    Entitlement accountEntitlement = [
      SELECT Id
      FROM Entitlement
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];
    Test.startTest();
    // WHEN
    // the recordType is changed to new recordType
    caseRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;
    update caseRecord;

    System.assert(
      accountEntitlement.Id ==
      [SELECT EntitlementId FROM Case WHERE Id = :caseRecord.Id LIMIT 1]
      .EntitlementId,
      'Link Entitlement from Account on converted unauthenticated enquiry to general enquiry.'
    );
    Test.stopTest();
  }

  @isTest
  static void testEntitlementChangeUnauthToANZXComplaint() {
    // a case record is created with relevant entitlements
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    // GIVEN
    // We have one unauthenticated enquiry case
    Faker faker = new Faker('AU');
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.AccountId = acc.Id;
    caseRecord.Type = '11';
    insert caseRecord;

    Test.startTest();
    // Case caseRecord = prepareCaseForTestingEntitlement(GetHelpConstants.COMPLAINT_RT_ID);
    caseRecord.RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID;
    update caseRecord;

    //THEN
    //the entitlement on case should match complaint entitlement
    System.assert(
      IDRCaseActions.getEntitlement() ==
      [SELECT EntitlementId FROM Case WHERE Id = :caseRecord.Id LIMIT 1]
      .EntitlementId,
      'Link Entitlement from Account on converted unauthenticated enquiry to anz plus complaint.'
    );
    Test.stopTest();
  }

  @isTest
  static void testEntitlementChangeUnauthToNonCusotmerComplaint() {
    // a case record is created with relevant entitlements
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    // GIVEN
    // We have one unauthenticated enquiry case
    Faker faker = new Faker('AU');
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.AccountId = acc.Id;
    caseRecord.Type = '11';
    insert caseRecord;

    // THEN
    // the same Entitlement record on Account should be linked on the Case
    Entitlement accountEntitlement = [
      SELECT Id
      FROM Entitlement
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];

    Test.startTest();
    caseRecord.RecordTypeId = GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    update caseRecord;
    System.assert(
      IDRCaseActions.getEntitlement() ==
      [SELECT EntitlementId FROM Case WHERE Id = :caseRecord.Id LIMIT 1]
      .EntitlementId,
      'Link Entitlement from Account on converted unauthenticated enquiry to non-customer complaint.'
    );
    Test.stopTest();
  }

  @isTest
  static void testEntitlementOnDisputes() {
    // GIVEN
    // an ANZ Plus customer record is created with relevant entitlements
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];

    // WHEN
    // a new Dispute case is created against the same customer
    Test.startTest();

    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Description = 'Charged more than once for same purchase',
      Priority = 'High',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086'
    );
    insert disputeCase;

    Test.stopTest();

    // THEN
    // the same Entitlement record on Account should be linked on the Case
    Entitlement accountEntitlement = [
      SELECT Id
      FROM Entitlement
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];

    System.assertEquals(
      accountEntitlement.Id,
      [SELECT EntitlementId FROM Case WHERE Id = :disputeCase.Id LIMIT 1]
      .EntitlementId,
      'Failed to link Entitlement from Account on Dispute cases'
    );
  }

  @isTest
  static void testDisputesSwitchFromOpen() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];

    // GIVEN
    // a Dispute case is created against an ANZ Plus customer, and correct entitlement process is applied
    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      External_System__c = 'CARBe',
      External_Case_Id__c = 'ABC123',
      Origin = '1',
      Description = 'Charged more than once for same purchase',
      Priority = 'High',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086'
    );
    insert disputeCase;

    // WHEN
    // case status is being changed from 'Open' to something else
    Test.startTest();

    disputeCase.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    update disputeCase;

    Test.stopTest();

    // THEN
    // it should mark related "Resolution Time" milestone as Completed
    System.assert(
      [
        SELECT COUNT()
        FROM CaseMilestone
        WHERE
          CaseId = :disputeCase.Id
          AND MilestoneType.Name = :MilestoneHandler.RESOLUTION_TIME_MILESTONE
          AND IsCompleted = TRUE
      ] > 0,
      'Failed to mark Dispute milestone as completed, when status is changed from Open'
    );
  }

  @isTest
  static void testDisputesSwitchFromInvestigation() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];

    // GIVEN
    // an ANZ Plus Dispute case is in status 'Under Investigation'
    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      External_System__c = 'CARBe',
      External_Case_Id__c = 'ABC123',
      Origin = '1',
      Description = 'Charged more than once for same purchase',
      Priority = 'High',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086'
    );
    insert disputeCase;

    // Update to 'Under Investigation'
    disputeCase.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    update disputeCase;

    // WHEN
    // case status is being changed from 'Under Investigation' to 'Closed'
    Test.startTest();

    disputeCase.Status = 'Closed';
    update disputeCase;

    Test.stopTest();

    // THEN
    // it should mark related "Investigation Time" milestone as Completed
    System.assert(
      [
        SELECT COUNT()
        FROM CaseMilestone
        WHERE
          CaseId = :disputeCase.Id
          AND MilestoneType.Name = :MilestoneHandler.INVESTIGATION_TIME_MILESTONE
          AND IsCompleted = TRUE
      ] > 0,
      'Failed to mark Dispute milestone as completed, when status is changed from Under Investigation to Closed'
    );
  }

  @isTest
  static void testDisputePrioritySameDay() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];

    // GIVEN
    // a Direct Debit / Direct Entry dispute Case is being created
    List<Case> disputes = new List<Case>();
    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Description = 'Charged more than once for same purchase',
      Effective_Date__c = Date.valueof(System.today()),
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.getBusinessHours().Id
    );

    // WHEN
    // the Transaction Date (Effective Date) is the same date as the case creation date
    Test.startTest();

    disputes.add(disputeCase);

    GetHelpCaseActions.setPriority(disputes);

    Test.stopTest();

    // THEN
    // case Priority should be marked as 'High'
    System.assertEquals(
      'High',
      disputeCase.Priority,
      'Failed to set the Priority to High when Dispute case is created on the same day as the transaction'
    );
  }

  @isTest
  static void testDisputePriorityBeforeLastBusinessDay() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];

    // GIVEN
    // a Direct Debit / Direct Entry dispute Case is being created
    List<Case> disputes = new List<Case>();
    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.getBusinessHours().Id
    );

    // WHEN
    // the Transaction Date (Effective Date) is more than one business days ago
    Test.startTest();

    disputeCase.Effective_Date__c = Date.valueof(System.now().addDays(-5));
    disputes.add(disputeCase);

    GetHelpCaseActions.setPriority(disputes);

    Test.stopTest();

    // THEN
    // case Priority should remain as 'Medium'
    System.assertEquals(
      'Medium',
      disputeCase.Priority,
      'Priority should be left as Medium when Dispute case is created after more than one business days from transaction'
    );
  }

  @isTest
  static void testHandleSLANotifications() {
    Faker faker = new Faker('AU');
    // GIVEN
    // a case is created linked to an ANZ Plus customer
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID,
          Type = 'Cards',
          Sub_Type__c = 'Damaged card',
          AccountId = acc.Id
        )
      );
    }
    insert newCases;

    // WHEN
    // the SLA_Status__c field gets updated to 'Warning' or 'Breached'
    Boolean exceptionThrown = false;
    String errorMessage = '';
    Test.startTest();

    try {
      List<String> slaOptions = new List<String>{ 'Warning', 'Breached' };
      for (Case c : newCases) {
        c.SLA_Status__c = faker.randomElement(slaOptions);
      }
      update newCases;
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
      System.assert(false, 'Failed to update SLA notification');
    }

    Test.stopTest();

    // THEN
    // a custom notification should be triggered to Case owner
    // (currently APEX does not support an easy way to assert on custom notifications)
    System.assertEquals(
      false,
      exceptionThrown,
      'An exception should not have been thrown while triggering SLA notifications.|\n' +
      errorMessage
    );
  }

  @isTest
  static void testDisputeSLAReset() {
    // GIVEN
    // a dispute case has gone through mielstones and have reached a SLA Status (Warning/Breached)
    Account acc = [
      SELECT Id
      FROM Account
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.DIRECT_ENTRY_DISPUTE_RT_ID,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.getBusinessHours().Id,
      Description = 'sample issue description',
      External_System__c = 'CARBe',
      External_Case_ID__c = '45234234',
      Status = GetHelpConstants.OPEN_STATUS,
      SLA_Status__c = 'Warning'
    );
    insert disputeCase;

    // WHEN
    // the case Status is switched
    Test.startTest();
    disputeCase.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    update disputeCase;
    Test.stopTest();

    // THEN
    // the SLA_Status__c field should get reset to blank/none
    Case updatedCase = [
      SELECT SLA_Status__c
      FROM Case
      WHERE Id = :disputeCase.Id
      LIMIT 1
    ];
    System.assertEquals(
      null,
      updatedCase.SLA_Status__c,
      'Failed to reset SLA Status to blank when Dispute case Status is changed.'
    );
  }

  // Static values used for PEGA platform event test data and assertions
  private static string pegaDisputeReason = 'Duplicate Transaction';
  private static string pegaTransactionId = 'abc48-fasjd-342sdfsa-jlj';
  private static string pegaCaseNumber = 'abc123';
  private static string pegaCaseRecordTypeName = 'ATM';
  private static string pegaCaseDescription = ' ATM Dispute';
  private static string pegaCaseStatus = 'Open';

  //test the Quality Assessment record creation when ANZx case was not closed but moved to closed status
  @isTest
  static void testCreateNonCustomerComplaintANZx() {
    Case[] newCases = new List<Case>();

    User usr = TestUtil.getUserByFirstName('CoachTest');

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = GetHelpConstants.OPEN_STATUS
        )
      );
    }

    Test.startTest();

    System.runAs(usr) {
      insert newCases;
    }

    List<Case> newCaseRecords = [
      SELECT Id
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
        AND ANZx_Customer__c = TRUE
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newCaseRecords.size(),
      'Should have ' +
      Label.Test_Bulk_Size +
      ' new ANZx Non Customer Complaint records.'
    );

    Test.stopTest();
  }

  //Test OCV Id gets populated on ANZx Complaint cases
  @isTest
  static void testOCVPopulationOnANZxComplaint() {
    Account acc = [
      SELECT Id, PersonContactId, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c = 'PERSONOCV879879'
      LIMIT 1
    ];

    Case[] newCases = new List<Case>();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID,
          Status = GetHelpConstants.OPEN_STATUS,
          AccountId = acc.Id,
          ContactId = acc.PersonContactId
        )
      );
    }

    Test.startTest();

    insert newCases;

    List<Case> newCaseRecords = [
      SELECT Id
      FROM Case
      WHERE
        RecordTypeId = :GetHelpConstants.COMPLAINT_RT_ID
        AND OCV_Id__c = :acc.OCV_ID__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newCaseRecords.size(),
      'Should have ' +
      Label.Test_Bulk_Size +
      ' new ANZx Complaint records.'
    );

    Test.stopTest();
  }

  //Tests if the card number is deleted after an update occurs on the dispute
  @isTest
  static void testCardDisputeDeleteCardNumber() {
    Case[] newCases = new List<Case>();
    Account acc = [SELECT Id FROM Account LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
          Type = '',
          Dispute_Reason__c = 'Don\'t recognise the transaction',
          AccountId = acc.Id,
          Is_The_Card_Lost_Stolen__c = 'Lost',
          Has_The_Card_Been_Stopped__c = 'Yes',
          Description = 'Some description',
          Card_Token_Number__c = '4444444444444444'
        )
      );
    }
    insert newCases;
    for (Case c : newCases) {
      c.Status = 'Escalated';
      c.External_System__c = 'CARBe';
      c.External_Case_Id__c = 'ABC123';
    }
    update newCases;
    newCases = [
      SELECT Card_Token_Number__c
      FROM Case
      WHERE Card_Token_Number__c = '4444444444444444'
    ];
    System.assertEquals(
      0,
      newCases.size(),
      'Card token number should be deleted'
    );
  }

  //Tests change KYC QA Case to Closed and Sub Status to No Defect, and set related fields with predefined value
  @isTest
  static void testPopulateKYCQACasesClosedNoDefectDefaults() {
    // GIVEN login as FraudX Agent user
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // WHEN FraudX Agent user creates or updates a Fraud case
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
          Type = 'KYC QA Sample',
          AccountId = acc.Id
        )
      );
    }
    Test.startTest();
    System.runAs(usr) {
      insert newCases;
    }

    // Verify new record fields have no value
    Case sampleCase1 = [
      SELECT
        Id,
        Type,
        RecordType.Name,
        Fraud_Customer_Details__c,
        Fraud_Restraint_Status__c,
        Fraud_Defects_Rectified__c,
        Status,
        Sub_Status__c
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      null,
      sampleCase1.Fraud_Customer_Details__c,
      'KYC QA: KYC Information is a Match & Complete field should be null after inserting.'
    );
    System.assertEquals(
      null,
      sampleCase1.Fraud_Restraint_Status__c,
      'KYC QA: Restraint Status field should be null after inserting.'
    );
    System.assertEquals(
      null,
      sampleCase1.Fraud_Defects_Rectified__c,
      'KYC QA: Have All Defects Been Rectified field should be null after inserting.'
    );

    sampleCase1.Status = GetHelpConstants.CLOSED_STATUS;
    sampleCase1.Sub_Status__c = GetHelpConstants.CLOSED_SUB_STATUS_NO_DEFECT;
    update sampleCase1;

    Test.stopTest();

    Case closedSampleCase1 = [
      SELECT
        Id,
        Type,
        RecordType.Name,
        Fraud_Customer_Details__c,
        Fraud_Restraint_Status__c,
        Fraud_Defects_Rectified__c,
        Status
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      'Yes',
      closedSampleCase1.Fraud_Customer_Details__c,
      'KYC QA: KYC Information is a Match & Complete field should be Yes after closing Case as No Defect.'
    );
    System.assertEquals(
      'N/A',
      closedSampleCase1.Fraud_Restraint_Status__c,
      'KYC QA: Restraint Status field should be empty after closing Case as No Defect.'
    );
    System.assertEquals(
      'Not Applicable',
      closedSampleCase1.Fraud_Defects_Rectified__c,
      'KYC QA: Have All Defects Been Rectified field should be empty after closing Case as No Defect.'
    );
  }

  // Tests if the Non Customer Complaint Case Subject is populated correctly
  // based on case record type and issue and when created/updated by ANZx user only
  @isTest
  public static void testPopulateNonCustomerComplaintSubject() {
    User coachUser = TestUtil.getUserByFirstName('CoachTest');

    List<Case> casesToInsert = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesToInsert.add(
        new Case(
          RecordTypeId = GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = GetHelpConstants.OPEN_STATUS,
          Type = 'Cards'
        )
      );
    }
    Test.startTest();

    System.runAs(coachUser) {
      // Insert NCC cases as ANZx user
      insert casesToInsert;
    }
    Test.stopTest();
    Case newCase = [
      SELECT Id, Subject
      FROM Case
      WHERE Id = :casesToInsert[0].Id
    ];

    String expectedCaseSubjectString = 'Non-Customer Complaint - ' + 'Cards';

    System.assertEquals(
      expectedCaseSubjectString,
      newCase.Subject,
      'ANZx Non Customer Complaint Subject should be populated as expected'
    );
  }

  // Tests to ensure the CMOS Non Customer Complaint Case Subject is not auto-populated
  // As this subject auto-pop should apply to ANZx NCCs only
  @isTest
  public static void testNoAutoPopulateForCMOSNonCustomerComplaintSubject() {
    List<Case> casesToInsert = new List<Case>();
    Account acc = [SELECT Id FROM Account LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesToInsert.add(
        new Case(
          RecordTypeId = GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Type = '2',
          IDR_Subsequent_Issue__c = 'Fee or interest dispute',
          AccountId = acc.Id,
          Description = 'Some description',
          Origin = 'Phone',
          Priority = 'Standard',
          Subject = 'CMOS Specific Subject'
        )
      );
    }
    Test.startTest();

    insert casesToInsert;

    Test.stopTest();
    Case newCase = [
      SELECT Id, Subject
      FROM Case
      WHERE Id = :casesToInsert[0].Id
    ];

    String expectedCaseSubjectString = 'CMOS Specific Subject';

    System.assertEquals(
      expectedCaseSubjectString,
      newCase.Subject,
      'CMOS Non Customer Complaint Subject should not be auto-populated on insert or update'
    );
  }

  // Test Prevent Duplicate KYC QA Against a Customer (Account)
  @isTest
  public static void testValidateDuplicateKYCQACasePerAccount() {
    List<Account> accounts = [
      SELECT Id, Name
      FROM Account
      WHERE ANZx_Customer__c = TRUE
    ];
    Account customerAccount1 = accounts[0];

    Case kycqa1 = new Case(
      AccountId = customerAccount1.Id,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      Status = 'Open',
      Origin = 'Origination',
      Priority = 'Medium'
    );

    insert kycqa1;

    Case kycqa2 = new Case(
      AccountId = customerAccount1.Id,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      Status = 'Open',
      Origin = 'Origination',
      Priority = 'Medium'
    );

    Test.startTest();
    try {
      insert kycqa2;
      System.assert(false, 'Failed to detect existing KYC QA case');
    } catch (DmlException e) {
      System.assert(
        e.getMessage().contains(GetHelpCaseActions.DUPLICATE_KYCQA_ERROR),
        'Exception thrown, error message does not reflect duplicate KYC QA error'
      );
    }
    Test.stopTest();
  }

  @IsTest
  static void testATMDisputeCase() {
    String recordTypeDeveloperName = 'ATM_Dispute';
    List<Account> accountsList = [
      SELECT Id, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, Account> ocvIDAndAccountMap = new Map<String, Account>();
    for (Account account : accountsList) {
      ocvIDAndAccountMap.put(account.OCV_ID__c, account);
    }
    List<FinServ__FinancialAccount__c> finServFinancialAccountsList = [
      SELECT Id, FinServ__PrimaryOwner__c, OCV_ID__c
      FROM FinServ__FinancialAccount__c
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, FinServ__FinancialAccount__c> ocvIDAndFinSerAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (
      FinServ__FinancialAccount__c finServFinancialAccount : finServFinancialAccountsList
    ) {
      ocvIDAndFinSerAccountMap.put(
        finServFinancialAccount.OCV_ID__c,
        finServFinancialAccount
      );
    }

    Case theCase = TestDataFactory.createCase(recordTypeDeveloperName);
    verifyAccountAndFinAccount(
      theCase,
      ocvIDAndAccountMap.get('OCV000000001'),
      ocvIDAndFinSerAccountMap.get('OCV000000002')
    );

    theCase.AccountId = ocvIDAndAccountMap.get('OCV000000001').Id;
    theCase.FinServ__FinancialAccount__c = ocvIDAndFinSerAccountMap.get(
        'OCV000000001'
      )
      .Id;
    Test.startTest();
    try {
      insert theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case: ' + e);
    }
    Test.stopTest();
    String fieldsToBeQueried = CommonUtil.getCaseFieldsString();
    theCase = Database.query(
      'Select Id, ' +
      String.escapeSingleQuotes(fieldsToBeQueried) +
      ' From Case Where Id = \'' +
      theCase.Id +
      '\''
    );
    verifyCloudEventForATMDisputeCase(theCase);

    theCase.External_System__c = 'CARBe';
    theCase.External_Case_Id__c = 'EXTERNALCASEID000';
    theCase.Submitted__c = true;
    System.assertEquals(
      true,
      GetHelpCaseActionsHelper.isValidPegaDispute(theCase),
      'Test result should match.'
    );
    try {
      update theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case: ' + e);
    }
    verifyPegaIntegration(theCase);

    theCase.Status = 'Closed';
    try {
      update theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case: ' + e);
    }
  }

  @IsTest
  static void testCardDisputeCase() {
    String recordTypeDeveloperName = 'Card_Dispute';
    List<Account> accountsList = [
      SELECT Id, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, Account> ocvIDAndAccountMap = new Map<String, Account>();
    for (Account account : accountsList) {
      ocvIDAndAccountMap.put(account.OCV_ID__c, account);
    }
    List<FinServ__FinancialAccount__c> finServFinancialAccountsList = [
      SELECT Id, FinServ__PrimaryOwner__c, OCV_ID__c
      FROM FinServ__FinancialAccount__c
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, FinServ__FinancialAccount__c> ocvIDAndFinSerAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (
      FinServ__FinancialAccount__c finServFinancialAccount : finServFinancialAccountsList
    ) {
      ocvIDAndFinSerAccountMap.put(
        finServFinancialAccount.OCV_ID__c,
        finServFinancialAccount
      );
    }

    Case theCase = TestDataFactory.createCase(recordTypeDeveloperName);
    theCase.AccountId = ocvIDAndAccountMap.get('OCV000000001').Id;
    theCase.FinServ__FinancialAccount__c = ocvIDAndFinSerAccountMap.get(
        'OCV000000001'
      )
      .Id;
    Test.startTest();
    try {
      insert theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case');
    }
    
    String fieldsToBeQueried = CommonUtil.getCaseFieldsString();
    theCase = Database.query(
      'Select Id, ' +
      String.escapeSingleQuotes(fieldsToBeQueried) +
      ' From Case Where Id = \'' +
      theCase.Id +
      '\''
    );
    verifyCloudEventForCardDisputeCase(theCase);
    verifyCaseSubject(theCase);
    verifyCardTokenNumber(theCase);
    verifyDuplicateDispute(theCase, recordTypeDeveloperName);
    theCase.Status = 'Closed';
    theCase.External_System__c = 'CARBe';
    theCase.External_Case_Id__c = 'EXTERNALCASEID000';
    Test.stopTest();
    try {
      update theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case');
    }
    verifyDuplicateDispute(theCase, recordTypeDeveloperName);
  }

  private static void insertTestAccountsForDisputeCases() {
    List<Account> accountList = new List<Account>();
    Account newAccount1 = TestDataFactory.createTestAccountForDisputeCases('1');
    newAccount1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('IndustriesIndividual')
      .getRecordTypeId();
    accountList.add(newAccount1);
    Account newAccount2 = TestDataFactory.createTestAccountForDisputeCases('2');
    newAccount2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('IndustriesIndividual')
      .getRecordTypeId();
    accountList.add(newAccount2);
    insert accountList;
    List<FinServ__FinancialAccount__c> finServFinancialAccountList = new List<FinServ__FinancialAccount__c>();
    FinServ__FinancialAccount__c newFinServFinancialAccount1 = TestDataFactory.createTestFinAccountForDisputeCases(
      '1'
    );
    newFinServFinancialAccount1.FinServ__PrimaryOwner__c = accountList[0].Id;
    finServFinancialAccountList.add(newFinServFinancialAccount1);
    FinServ__FinancialAccount__c newFinServFinancialAccount2 = TestDataFactory.createTestFinAccountForDisputeCases(
      '2'
    );
    newFinServFinancialAccount2.FinServ__PrimaryOwner__c = accountList[1].Id;
    finServFinancialAccountList.add(newFinServFinancialAccount2);
    insert finServFinancialAccountList;
  }

  private static void verifyCloudEventForATMDisputeCase(Case theCase) {
    System.assertEquals(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
    System.assert(
      String.isNotBlank(CloudEventController.cloudEvents[0].Data_1__c),
      'Cloud Event should be generated'
    );
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    ATMDisputeCaseCloudEventModel atmDisputeCaseCloudEventModel = (ATMDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      ATMDisputeCaseCloudEventModel.class
    );

    Map<String, Object> mappedResponse = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Map<String, Object> mappedResponse2 = (Map<String, Object>) mappedResponse.get(
      'ce_data'
    );
    ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel atmDisputeCaseCloudEventDataModel = (ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel) JSON.deserialize(
      JSON.serialize(mappedResponse2),
      ATMDisputeCaseCloudEventModel.ATMDisputeCaseCloudEventDataModel.class
    );

    System.assertEquals(
      theCase.CaseNumber,
      atmDisputeCaseCloudEventDataModel.caseNumber,
      'Case Number should match'
    );
    System.assertEquals(
      'CaseNumber/' + theCase.CaseNumber,
      atmDisputeCaseCloudEventModel.ce_subject,
      'ce_subject should match'
    );
    DisputeCaseCloudEventModel.AccountModel customer = atmDisputeCaseCloudEventDataModel.customer;
    System.assertEquals(
      theCase.Account.OCV_ID__c,
      customer.ocvId,
      'customer should not be null'
    );
    DisputeCaseCloudEventModel.FinancialAccountModel financialAccount = atmDisputeCaseCloudEventDataModel.financialAccount;
    System.assert(
      financialAccount != null,
      'financialAccount should not be null'
    );
    DisputeCaseCloudEventModel.TransactionModel transactionInformation = atmDisputeCaseCloudEventDataModel.transactionInformation;
    System.assert(
      transactionInformation != null,
      'transaction should not be null'
    );
  }

  private static void verifyCloudEventForCardDisputeCase(Case theCase) {
    System.assertEquals(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
    System.assert(
      String.isNotBlank(CloudEventController.cloudEvents[0].Data_1__c),
      'Cloud Event should be generated'
    );
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    CardDisputeCaseCloudEventModel cardDisputeCaseCloudEventModel = (CardDisputeCaseCloudEventModel) JSON.deserialize(
      payload,
      CardDisputeCaseCloudEventModel.class
    );

    Map<String, Object> mappedResponse = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Map<String, Object> mappedResponse2 = (Map<String, Object>) mappedResponse.get(
      'ce_data'
    );
    CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel cardDisputeCaseCloudEventDataModel = (CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel) JSON.deserialize(
      JSON.serialize(mappedResponse2),
      CardDisputeCaseCloudEventModel.CardDisputeCaseCloudEventDataModel.class
    );

    System.assertEquals(
      theCase.CaseNumber,
      cardDisputeCaseCloudEventDataModel.caseNumber,
      'Case Number should match'
    );
    System.assertEquals(
      'CaseNumber/' + theCase.CaseNumber,
      cardDisputeCaseCloudEventModel.ce_subject,
      'ce_subject should match'
    );
    DisputeCaseCloudEventModel.AccountModel customer = cardDisputeCaseCloudEventDataModel.customer;
    System.assertEquals(
      theCase.Account.OCV_ID__c,
      customer.ocvId,
      'customer should not be null'
    );
    DisputeCaseCloudEventModel.FinancialAccountModel financialAccount = cardDisputeCaseCloudEventDataModel.financialAccount;
    System.assert(
      financialAccount != null,
      'financialAccount should not be null'
    );
    DisputeCaseCloudEventModel.TransactionModel transactionInformation = cardDisputeCaseCloudEventDataModel.transactionInformation;
    System.assert(
      transactionInformation != null,
      'transaction should not be null'
    );
  }

  private static void verifyAccountAndFinAccount(
    Case theCase,
    Account account,
    FinServ__FinancialAccount__c finServFinanceAccount
  ) {
    Case caseWithError = theCase.clone(false, false, false, false);
    caseWithError.AccountId = account.Id;
    caseWithError.FinServ__FinancialAccount__c = finServFinanceAccount.Id;
    if (finServFinanceAccount.FinServ__PrimaryOwner__c == account.Id) {
    } else {
      try {
        insert caseWithError;
        System.assert(
          false,
          'Failed to detect misalignment between customer\'s OCV ID and Financial Account'
        );
      } catch (DmlException e) {
        System.assertEquals(
          true,
          e.getMessage()
            .contains(GetHelpCaseActions.MISALIGNED_FINANCIAL_ACCOUNT_ERROR),
          'Error messages match.'
        );
      }
    }
  }

  private static void verifyPegaIntegration(Case theCase) {
    List<sObject> platFormEventList = GetHelpCaseActions.pegaPEList;
    System.assertEquals(
      theCase.CaseNumber,
      platFormEventList[0].get('Original_Case_Number__c'),
      'Case Number should not be null.'
    );
    System.assertEquals(
      theCase.Transaction_Id__c,
      platFormEventList[0].get('Transaction_Id__c'),
      'Transaction Id should match.'
    );
  }

  private static void verifyCaseSubject(Case theCase) {
    List<String> fraudCasesRecordTypeNames = new List<String>{
      'Fraud',
      'Identity',
      'Recipient_Mule',
      'Scam',
      'KYC_QA'
    };
    List<String> disputeCasesRecordTypeNames = new List<String>{
      'ATM_Dispute',
      'BPAY_Dispute',
      'Card_Dispute',
      'Direct_Debit_Dispute',
      'Direct_Entry_Dispute',
      'NPP_Dispute'
    };
    if (
      disputeCasesRecordTypeNames.contains(theCase.RecordType.DeveloperName)
    ) {
      System.assertEquals(
        theCase.RecordType.Name +
        ' - ' +
        theCase.Dispute_Reason__c,
        theCase.Subject,
        'New case subject should be as expected.'
      );
    } else if (fraudCasesRecordTypeNames.contains(theCase.RecordType.Name)) {
      System.assertEquals(
        theCase.RecordType.Name +
        ' - ' +
        theCase.Type,
        theCase.Subject,
        'New case subject should be as expected.'
      );
    } else if (theCase.RecordType.Name == 'General_Inquiry') {
      if (String.isBlank(theCase.Sub_Type__c)) {
        System.assertEquals(
          theCase.Type,
          theCase.Subject,
          'New case subject should be as expected.'
        );
      } else {
        String subTypes = theCase.Sub_Type__c.replace(';', ' - ');
        System.assertEquals(
          theCase.Type +
          ' - ' +
          subTypes,
          theCase.Subject,
          'New case subject should be as expected.'
        );
      }
    }
  }

  private static void verifyCardTokenNumber(Case theCase) {
    theCase.Status = 'Escalated';
    theCase.External_System__c = 'CARBe';
    theCase.External_Case_Id__c = 'EXTERNALCASEID000';
    try {
      update theCase;
      Case theCaseUpdated = [
        SELECT Id, Card_Token_Number__c
        FROM Case
        WHERE Id = :theCase.Id
      ];
      System.assertEquals(
        null,
        theCaseUpdated.Card_Token_Number__c,
        'Card token number should be null'
      );
    } catch (DmlException e) {
    }
  }

  private static void verifyDuplicateDispute(
    Case theCase,
    String recordTypeDeveloperName
  ) {
    Case duplicateCase = TestDataFactory.createCase(recordTypeDeveloperName);
    duplicateCase.AccountId = theCase.AccountId;
    duplicateCase.Transaction_Id__c = theCase.Transaction_Id__c;
    if (theCase.Status != 'Closed') {
      try {
        insert duplicateCase;
        System.assert(false, 'Failed to detect existing dispute case');
      } catch (DmlException e) {
        System.assertEquals(
          true,
          e.getMessage().contains(GetHelpCaseActions.DUPLICATE_DISPUTE_ERROR),
          'Error messages match. Expected: ' +
          GetHelpCaseActions.DUPLICATE_DISPUTE_ERROR +
          ' Actual: ' +
          e.getMessage()
        );
      }
    } else {
      try {
        insert duplicateCase;
      } catch (DmlException e) {
        System.assertEquals(
          null,
          e,
          'New dispute case was not successfully inserted.'
        );
      }
    }
  }

  // Test create Fraud Check Case when ID Ops Case changes to 'Potential Fraud' status
  @isTest
  public static void testCreateFraudCheckCase() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    //create an onboarding application
    List<CustomerOnboardingApplication__c> cobs = new List<CustomerOnboardingApplication__c>();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      cobs.add(
        new CustomerOnboardingApplication__c(
          PersonaId__c = 'dsfsadfasdf' + i,
          OCVId__c = '4324234234' + i
        )
      );
    }

    insert cobs;

    //create an id ops case with application
    List<Case> idOpsAssistsCases = new List<Case>();

    for (CustomerOnboardingApplication__c a : cobs) {
      idOpsAssistsCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
          Status = GetHelpConstants.OPEN_STATUS,
          CustomerOnboardingApplication__c = a.Id
        )
      );
    }

    insert idOpsAssistsCases;

    //move id ops case to potential fraud
    idOpsAssistsCases = [
      SELECT Id, Status, OwnerId
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    ];

    for (Case c : idOpsAssistsCases) {
      c.OwnerId = usr.Id;
    }

    update idOpsAssistsCases;

    for (Case c : idOpsAssistsCases) {
      c.Status = GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS;
    }

    Test.startTest();

    System.runAs(usr) {
      update idOpsAssistsCases;
    }

    //verify fraud check case gets created
    List<Case> fraudCheckCases = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.FRAUD_CHECK_RT_ID
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      fraudCheckCases.size(),
      'Should have ' +
      Label.Test_Bulk_Size +
      ' new Fraud Check cases.'
    );

    Test.stopTest();
  }

  // Test update Id Ops case by a corresponding Fraud Check Case
  @isTest
  public static void testUpdateIdOpsCaseStatus() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    //create ID Ops Cases
    createIdOpsCases(usr);

    //create Fraud Check Cases as child cases of the Id Ops Cases and set statuses
    List<Case> fraudCheckCases = createFraudCheckCases();

    List<Case> fraudCheckWithStatuses = setFraudCheckCasesStatuses(
      fraudCheckCases
    );

    Test.startTest();

    System.runAs(usr) {
      update fraudCheckWithStatuses;
    }
    Test.stopTest();

    assert();
  }

  @isTest
  static void testEntitlementInsertKYCQA() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Display_Name__c = 'TestAccount'
      LIMIT 1
    ];

    // WHEN a KYC QA case is created
    Case newCase = new Case(
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      Type = 'KYC QA Sample',
      AccountId = acc.Id
    );

    Test.startTest();
    insert newCase;
    Test.stopTest();

    Case testingCase = [
      SELECT Id, EntitlementId
      FROM Case
      WHERE Id = :newCase.Id
      LIMIT 1
    ];

    Entitlement accountEntitlement = [
      SELECT Id
      FROM Entitlement
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];

    Assert.areEqual(
      accountEntitlement.Id,
      testingCase.EntitlementId,
      'Link Entitlement from Account to KYC QA case.'
    );
  }

  private static void createIDOpsCases(User usr) {
    List<Case> idOpsCases = new List<Case>();

    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      idOpsCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
          Status = GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
          OwnerId = usr.Id
        )
      );
    }
    insert idOpsCases;
  }

  private static List<Case> createFraudCheckCases() {
    // Retrieve created ID Ops Cases with Ids and OwnerIds
    List<Case> idOpsCases = getIdOpsCase();

    List<Case> fraudCheckCases = new List<Case>();
    for (Case idOpsCase : idOpsCases) {
      fraudCheckCases.add(
        new Case(
          RecordTypeId = GetHelpConstants.FRAUD_CHECK_RT_ID,
          OwnerId = idOpsCase.OwnerId,
          ParentId = idOpsCase.Id
        )
      );
    }

    insert fraudCheckCases;

    return fraudCheckCases;
  }

  private static List<Case> setFraudCheckCasesStatuses(
    List<Case> fraudCheckCases
  ) {
    // transition Fraud Check Cases to the Closed statuses
    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      fraudCheckCases[i].Status = COB_CLOSED_STATUSES[i];
      fraudCheckCases[i]
        .OnboardingVerificationFailedReason__c = COB_CLOSED_STATUSES[i] ==
        GetHelpConstants.COB_FAILED_OK_STATUS
        ? FAILED_RESON
        : EMPTY_FAILED_REASON;
    }

    return fraudCheckCases;
  }

  private static void assert() {
    List<Case> updatedIdOpsCases = getIdOpsCase();

    //verify Id Ops cases are updated with the correct corresponding status
    for (Integer i = 0; i < COB_CASES_COUNT; i++) {
      Assert.areEqual(
        COB_CLOSED_STATUSES[i],
        updatedIdOpsCases[i].Status,
        'Status should be ' + COB_CLOSED_STATUSES[i]
      );

      if (
        updatedIdOpsCases[i].Status == GetHelpConstants.COB_FAILED_OK_STATUS
      ) {
        Assert.areEqual(
          FAILED_RESON,
          updatedIdOpsCases[i].OnboardingVerificationFailedReason__c,
          'Failed reasons should be ' + FAILED_RESON
        );
      }
    }
  }

  private static List<Case> getIdOpsCase() {
    return [
      SELECT Id, Status, OwnerId, OnboardingVerificationFailedReason__c
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    ];
  }

  @isTest
  static void testEmailTaskOnCaseClosureCreation() {
    User usr = TestUtil.getUserByFirstName('IntegrationTest');
    Case theCase;
    System.runAs(usr) {
      String recordTypeDeveloperName = 'Card_Dispute';
      List<Account> accountsList = [
        SELECT Id, OCV_ID__c
        FROM Account
        WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
      ];
      Map<String, Account> ocvIDAndAccountMap = new Map<String, Account>();
      for (Account account : accountsList) {
        ocvIDAndAccountMap.put(account.OCV_ID__c, account);
      }
      List<FinServ__FinancialAccount__c> finServFinancialAccountsList = [
        SELECT Id, FinServ__PrimaryOwner__c, OCV_ID__c
        FROM FinServ__FinancialAccount__c
        WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
      ];
      Map<String, FinServ__FinancialAccount__c> ocvIDAndFinSerAccountMap = new Map<String, FinServ__FinancialAccount__c>();
      for (
        FinServ__FinancialAccount__c finServFinancialAccount : finServFinancialAccountsList
      ) {
        ocvIDAndFinSerAccountMap.put(
          finServFinancialAccount.OCV_ID__c,
          finServFinancialAccount
        );
      }

      theCase = TestDataFactory.createCase(recordTypeDeveloperName);
      theCase.AccountId = ocvIDAndAccountMap.get('OCV000000001').Id;
      theCase.FinServ__FinancialAccount__c = ocvIDAndFinSerAccountMap.get(
          'OCV000000001'
        )
        .Id;
      theCase.External_System__c = 'Pega_Smarts';
      theCase.External_Case_ID__c = 'C-1234';
      insert theCase;

      External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
        Case__c = theCase.Id,
        External_Status__c = 'Resolved-WriteOff',
        Status_Event_ID__c = 'Status_Event_ID',
        Result_Code__c = 'Result_Code',
        Result_Message__c = 'Result_Message'
      );
      insert externalCaseStatus;

      Test.startTest();
      theCase.Status = 'Closed';
      update theCase;
      Test.stopTest();
    }

    String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
      .get('Email_Task')
      .getRecordTypeId();
    Task tsk = [
      SELECT Id, Description
      FROM Task
      WHERE WhatId = :theCase.Id AND RecordTypeId = :taskRecordTypeId
      LIMIT 1
    ];
    Assert.areEqual(
      GetHelpConstants.TASK_EMAIL_DESCRIPTION,
      tsk.Description,
      'Description should be ' + GetHelpConstants.TASK_EMAIL_DESCRIPTION
    );
  }

  @isTest
  static void testEmailTaskOnCaseClosureCreationNegative() {
    String recordTypeDeveloperName = 'Card_Dispute';
    List<Account> accountsList = [
      SELECT Id, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, Account> ocvIDAndAccountMap = new Map<String, Account>();
    for (Account account : accountsList) {
      ocvIDAndAccountMap.put(account.OCV_ID__c, account);
    }
    List<FinServ__FinancialAccount__c> finServFinancialAccountsList = [
      SELECT Id, FinServ__PrimaryOwner__c, OCV_ID__c
      FROM FinServ__FinancialAccount__c
      WHERE OCV_ID__c IN ('OCV000000001', 'OCV000000002')
    ];
    Map<String, FinServ__FinancialAccount__c> ocvIDAndFinSerAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (
      FinServ__FinancialAccount__c finServFinancialAccount : finServFinancialAccountsList
    ) {
      ocvIDAndFinSerAccountMap.put(
        finServFinancialAccount.OCV_ID__c,
        finServFinancialAccount
      );
    }

    User usr = TestUtil.getUserByFirstName('IntegrationTest');
    Case theCase;
    System.runAs(usr) {
      theCase = TestDataFactory.createCase(recordTypeDeveloperName);
      theCase.AccountId = ocvIDAndAccountMap.get('OCV000000001').Id;
      theCase.FinServ__FinancialAccount__c = ocvIDAndFinSerAccountMap.get(
          'OCV000000001'
        )
        .Id;
      theCase.External_System__c = 'Pega_Smarts';
      theCase.External_Case_ID__c = 'C-1234';
      insert theCase;

      External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
        Case__c = theCase.Id,
        External_Status__c = 'Resolved-SystemClosure',
        Status_Event_ID__c = 'Status_Event_ID',
        Result_Code__c = 'Result_Code',
        Result_Message__c = 'Result_Message'
      );
      insert externalCaseStatus;

      Test.startTest();
      theCase.Status = 'Closed';
      update theCase;
      Test.stopTest();
    }

    String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
      .get('Email_Task')
      .getRecordTypeId();
    List<Task> taskList = [
      SELECT Id, Description
      FROM Task
      WHERE WhatId = :theCase.Id AND RecordTypeId = :taskRecordTypeId
    ];
    Assert.isTrue(taskList.isEmpty(), 'No Task should be created');
  }

  private static void makeCOBData() {
    List<CustomerOnboardingApplication__c> cobApps = new List<CustomerOnboardingApplication__c>();
    List<Account> personAccsWithMobile = new List<Account>();
    for (String mobileNumber : COB_MATCHING_MOBILE_NUMBERS) {
      cobApps.add(createCOBApp(mobileNumber));
    }

    for (String mobileNumber : CUSTOMER_MATCHING_MOBILE_NUMBERS) {
      personAccsWithMobile.add(createPersonAccount(mobileNumber));
    }

    for (String mobileNumber : NOT_MATCHING_MOBILE_NUMBERS) {
      cobApps.add(createCOBApp(mobileNumber));
    }

    insert cobApps;
    insert personAccsWithMobile;

    List<Entitlement> entitlements = CommonUtil.addPersonAccountEntitlements(
      personAccsWithMobile,
      GetHelpConstants.ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME,
      GetHelpConstants.BASIC_SUBSCRIPTION_ENTITLEMENT_NAME
    );
    insert entitlements;
  }

  private static CustomerOnboardingApplication__c createCOBApp(
    String mobileNumber
  ) {
    CustomerOnboardingApplication__c cobApp = new CustomerOnboardingApplication__c(
      SecurityMobile__c = mobileNumber
    );

    return cobApp;
  }

  private static List<CustomerOnboardingApplication__c> getCOBApps() {
    return [SELECT Id, SecurityMobile__c FROM CustomerOnboardingApplication__c];
  }

  private static Case createKYCQACase(Id cobAppId, Id caseOwnerId) {
    Case c = new Case(
      Status = GetHelpConstants.OPEN_STATUS,
      RecordTypeId = GetHelpConstants.KYCQA_RT_ID,
      CustomerOnboardingApplication__c = cobAppid,
      OwnerId = caseOwnerId
    );

    return c;
  }

  private static List<Case> getKYCQACases() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.KYCQA_RT_ID
    ];
  }

  private static List<Case> getCasesLinkedWithAccount() {
    return [
      SELECT Id, AccountId, ContactId, ContactMobile, EntitlementId
      FROM Case
      WHERE AccountId != NULL AND ContactId != NULL AND EntitlementId != NULL
    ];
  }

  private static List<Case> getCasesWithNoAccount() {
    return [SELECT Id, OwnerId FROM Case WHERE AccountId = NULL];
  }

  private static Account createPersonAccount(String mobileNumber) {
    Faker faker = new Faker('AU');
    Account acc = new Account(
      FirstName = faker.person.firstName(),
      LastName = faker.person.lastName(),
      OCV_ID__c = faker.randomString(10),
      PersonMobilePhone = mobileNumber,
      ANZx_Customer__c = true,
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
    );

    return acc;
  }

  private static List<Case> createKYCQACases(Id caswOwnerId) {
    List<CustomerOnboardingApplication__c> cobApps = getCOBApps();

    List<Case> kycQACases = new List<Case>();
    for (CustomerOnboardingApplication__c cobApp : cobApps) {
      kycQACases.add(createKYCQACase(cobApp.Id, caswOwnerId));
    }

    insert kycQACases;
    return kycQACases;
  }

  @isTest
  static void testLinkKYCQACasesToAccountChangeOwnership() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change owner
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = usr.Id;
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with no Matched Person Accounts'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountChangeDescription() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change Description
    for (Case kycQACase : kycQACases) {
      kycQACase.Description = 'Test';
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );
  }

  @isTest
  static void testLinkKYCQACasesToAccountNoCustomerCaseClosed() {
    // GIVEN KYC Case in Pending KYC QA Queue
    List<Case> kycQACases = createKYCQACases(
      COBApplicationActionsHelper.PENDING_KYC_QA_QUEUE.Id
    );

    // WHEN Change Status to CLOSED
    for (Case kycQACase : kycQACases) {
      kycQACase.Status = GetHelpConstants.CLOSED_STATUS;
      kycQACase.Sub_Status__c = 'No Defect';
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will be linked with Matched Person Accounts
    List<Case> casesLinkedWithAccount = getCasesLinkedWithAccount();

    Assert.areEqual(
      COB_MATCHING_MOBILE_NUMBERS.size(),
      casesLinkedWithAccount.size(),
      'Should be ' +
      COB_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will be moved to Pending KYC QA - No Customer Queue
    for (Case c : casesWithNoAccount) {
      Assert.areEqual(
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        c.OwnerId,
        'KYC QA Cases should move to ' +
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id +
        'queue'
      );
    }
  }

  @isTest
  static void testLinkKYCQACasesToAccountNoCustomerChangeOwnerInNoCustomerQueue() {
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // GIVEN KYC Case in Pending KYC QA - No Customer Queue
    List<Case> kycQACases = createKYCQACases(
      GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id
    );

    // WHEN Attempt Changing owner
    for (Case kycQACase : kycQACases) {
      kycQACase.OwnerId = usr.Id;
    }

    Test.startTest();
    update kycQACases;
    Test.stopTest();

    // THEN KYC QA Cases will not be linked if no Matched Person Accounts found
    List<Case> casesWithNoAccount = getCasesWithNoAccount();

    Assert.areEqual(
      NOT_MATCHING_MOBILE_NUMBERS.size(),
      casesWithNoAccount.size(),
      'Should be ' +
      NOT_MATCHING_MOBILE_NUMBERS.size() +
      ' KYC QA Cases with Matched Person Accounts'
    );

    // AND THEN KYC QA Cases will remain in Pending KYC QA - No Customer Queue
    for (Case c : casesWithNoAccount) {
      Assert.areEqual(
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id,
        c.OwnerId,
        'KYC QA Cases should remain in ' +
        GetHelpCaseActionsHelper.PENDING_KYC_QA_WO_CUSTOMER.Id +
        'queue'
      );
    }
  }
}
