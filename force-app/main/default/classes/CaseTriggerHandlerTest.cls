// CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
// NcssTypeCount Surpressed : The line of code for this test is more than it is expected.

@SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssTypeCount')
@IsTest
private class CaseTriggerHandlerTest {
  public static Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
    Case.Type
  );

  private static final List<String> COB_CLOSED_STATUSES = new List<String>{
    COBCaseConstants.COB_ID_CHECK_OK_STATUS,
    COBCaseConstants.COB_FAILED_OK_STATUS
  };

  private static final Integer COB_CASES_COUNT = COB_CLOSED_STATUSES.size();

  private static final String FAILED_RESON = 'Selfie fail - selfie image is not clear enough to match';

  private static final String EMPTY_FAILED_REASON = '';

  private static Faker faker = new Faker('AU');

  //User as current user, to get around MIXED_DML_OPERATION error
  private static User thisUser = new User(Id = UserInfo.getUserId());

  @TestSetup
  static void setup() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    Map<String, User> userMap = new Map<String, User>();
    System.runAs(thisUser) {
      /*----------Create users for tests----------*/

      // Create a FraudX User with 'FraudX Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
      userMap.put(
        'fraudXAgent',
        createTestUser(profile.Id, 'FraudX_Agent', 'FraudXTest')
      );
      userMap.put('coach', createTestUser(profile.Id, 'Coach', 'CoachTest'));
      userMap.put(
        'bohCoach',
        createTestUser(profile.Id, 'BOH_Coach', 'BOHCoachTest')
      );
      userMap.put(
        'creditOfficer',
        createTestUser(
          profile.Id,
          'Credit_Assessment_Officer',
          'CreditAssessmentOfficer'
        )
      );
      userMap.put(
        'creditLead',
        createTestUser(profile.Id, 'Credit_Assessor_Lead', 'CreditLead')
      );

      Profile integrationProfile = CommonUtil.getProfileByName(
        'Integration User'
      );
      userMap.put(
        'creditRefIntegrationUser',
        createTestUser(
          integrationProfile.Id,
          'ANZx',
          'CreditRefIntegrationUser'
        )
      );

      Profile anzProfile = CommonUtil.getProfileByName('ANZ Standard User');
      userMap.put('idrUser', createTestUser(anzProfile.Id, 'ANZ', 'IDRL1'));
      userMap.put(
        'integrationUser',
        createTestUser(integrationProfile.Id, 'ANZ', 'IntegrationTest')
      );

      insert userMap.values();

      /*----------Assign permission sets to users----------*/
      // Fraud User permission sets
      List<String> fraudXPSs = new List<String>{
        'Case_Read_Write_Fraud_Agent',
        'Customer_Read_Only',
        'Case_Read_Write_Customer_Onboarding'
      };
      insertPSAList(fraudXPSs, userMap.get('fraudXAgent').Id);

      // Coach User permission sets
      List<String> coachPSs = new List<String>{
        'Case_Read_Write_Get_Help',
        'Case_Read_Write_Dispute',
        'Customer_Read_Only',
        'Quality_Assessment_Read_Only',
        'Case_Read_Write_Non_Customer_Complaints'
      };
      insertPSAList(coachPSs, userMap.get('coach').Id);

      // Credit Referral Integration User permission sets
      List<String> creditRefPs = new List<String>{
        'API_Only',
        'Case_Read_Write_Credit_Referral',
        'Credit_Referral_Integration'
      };
      insertPSAList(creditRefPs, userMap.get('creditRefIntegrationUser').Id);

      // IDR user permission sets
      List<String> idrPsets = new List<String>{
        'IDR_User',
        'IDR_User_Level_1'
      };
      insertPSAList(idrPsets, userMap.get('idrUser').Id);

      // Integration User permission sets
      List<String> integrationPsets = new List<String>{
        'View_And_Edit_Tasks',
        'Case_Read_Write_Get_Help',
        'Case_Read_Write_Dispute',
        'Read_Only_Admin'
      };
      insertPSAList(integrationPsets, userMap.get('integrationUser').Id);

      Account[] accnts = new List<Account>();
      accnts.add(TestDataFactory.createAccount('CustomerRLA', false));
      for (Integer i = 0; i < 2; i++) {
        accnts.add(createPersonAccount(userMap.get('fraudXAgent').Id));
      }
      accnts.add(
        createNonPersonAccount(
          'Complaint Entitlement Account',
          faker.randomString(10)
        )
      );

      accnts.add(
        createNonPersonAccount(
          'Fraud Entitlement Account',
          Label.Fraudx_Generic_Customer_OCV_Id
        )
      );

      insert accnts;

      //test data for Residential Loan Application
      createResidentialLoanApps(accnts[0].Id);
    }
    insertTestAccountsForDisputeCases();
  }

  private static User createTestUser(
    Id profileId,
    String roleName,
    String firstName
  ) {
    UserRole role = CommonUtil.getUserRoleByDevName(roleName);

    return TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => firstName,
        'ProfileId' => profileId,
        'UserRoleId' => role.Id
      }
    );
  }

  private static void insertPSAList(List<String> userPSList, String userId) {
    List<PermissionSet> psList = [
      SELECT Id
      FROM PermissionSet
      WHERE Name IN :userPSList
    ];
    List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : psList) {
      psaList.add(TestUtil.createPSAssignment(userId, ps.Id));
    }
    insert psaList;
  }

  private static Account createPersonAccount(Id userId) {
    return new Account(
      RecordTypeId = GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID,
      FirstName = faker.randomString(5),
      LastName = faker.randomString(5),
      OCV_ID__c = 'PERSONOCV879879',
      ANZx_Customer__c = true,
      OwnerId = userId,
      External_Id__c = faker.randomString(10),
      PersonMobilePhone = '+61400000000'
    );
  }

  private static Account createNonPersonAccount(String name, String ocvId) {
    return new Account(
      Name = name,
      OCV_ID__c = ocvId,
      ANZx_Customer__c = false
    );
  }

  private static List<ResidentialLoanApplication> createResidentialLoanApps(
    Id acctId
  ) {
    ResidentialLoanApplication[] newRLA = new List<ResidentialLoanApplication>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      String value = String.valueOf(i);
      ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
        value
      );
      rla.Credit_ID__c = '000-000-000-00' + value;
      rla.AccountId = acctId;

      newRLA.add(rla);
    }
    insert newRLA;
    return newRLA;
  }

  @IsTest
  static void testCaseNumberCopy() {
    // GIVEN cases are created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(new Case(RecordTypeId = RTCase.nonCustomerComplaint));
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
  static void testFalseCustomerProfileDefaultValue() {
    Account personAcc = [SELECT Id, Name FROM Account LIMIT 1];
    Case newCase = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
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
  static void testFalseCustomerProfileNoUpdateForGenericValue() {
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
      RecordTypeId = RTCase.falseCustomerProfile,
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
  static void testFalseCustomerProfileUpdateValue() {
    // GIVEN: We have a Fraud Cusotmer Profile case with not Fraud Generic customer
    List<Account> personAcc = [
      SELECT Id, Name
      FROM Account
      WHERE Name != 'Fraud Entitlement Account'
      LIMIT 2
    ];
    Case newCase = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
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

  @isTest
  static void testFalseCustomerProfileCOBRealCustomer() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE PersonMobilePhone = '+61400000000'
      LIMIT 1
    ];
    CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
      PersonaId__c = 'dsfsadfasdf',
      OCVId__c = '4324234234',
      SecurityMobile__c = '61400000000'
    );
    insert cob;

    Case newCase = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
      AccountId = acc.Id
    );

    Test.startTest();
    insert newCase;
    Case c = [
      SELECT Id, CustomerOnboardingApplication__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertEquals(
      c.CustomerOnboardingApplication__c,
      cob.Id,
      'COB for real customer should be populated.'
    );
    Test.stopTest();
  }

  @isTest
  static void testFalseCustomerProfileCOBGenericFraudCustomer() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Name = 'Fraud Entitlement Account'
      LIMIT 1
    ];

    Case newCase = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
      AccountId = acc.Id
    );

    Test.startTest();
    insert newCase;
    Case c = [
      SELECT Id, CustomerOnboardingApplication__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertEquals(
      c.CustomerOnboardingApplication__c,
      null,
      'COB should be null'
    );
    Test.stopTest();
  }

  @isTest
  static void testFalseCustomerProfileCOBUpdateRealCustomerToFraudGeneric() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE PersonMobilePhone = '+61400000000'
      LIMIT 1
    ];
    Account genericFraudAcc = [
      SELECT Id
      FROM Account
      WHERE Name = 'Fraud Entitlement Account'
      LIMIT 1
    ];
    CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
      PersonaId__c = 'dsfsadfasdf',
      OCVId__c = '4324234234',
      SecurityMobile__c = '61400000000'
    );
    insert cob;

    Case newCase = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
      AccountId = acc.Id
    );

    Test.startTest();
    insert newCase;
    Case c = [
      SELECT Id, CustomerOnboardingApplication__c
      FROM Case
      WHERE Id = :newCase.Id
    ];

    c.AccountId = genericFraudAcc.Id;
    update c;

    c = [
      SELECT Id, CustomerOnboardingApplication__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assertEquals(
      c.CustomerOnboardingApplication__c,
      null,
      'COB should be blank when we update it to Fraud Generic Account'
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
          RecordTypeId = RTCase.nonCustomerComplaint
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
          Description = 'Test decription 1234-5678-9101-3321 check mask',
          IDR_Complainant_Desired_Outcome__c = 'Test decription 1234-5678-9101-3321 check mask',
          IDR_Description_of_Outcome__c = 'Test decription 1234-5678-9101-3321 check mask',
          IDR_Systemic_Issue_Description__c = 'Test decription 1234-5678-9101-3321 check mask',
          RecordTypeId = RTCase.customerComplaint,
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
      'Test decription ************3321 check mask',
      c.Description,
      'Description should be masked.'
    );
    System.assertEquals(
      'Test decription ************3321 check mask',
      c.IDR_Complainant_Desired_Outcome__c,
      'IDR_Complainant_Desired_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ************3321 check mask',
      c.IDR_Description_of_Outcome__c,
      'IDR_Description_of_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ************3321 check mask',
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
          RecordTypeId = RTCase.nonCustomerComplaint
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
      newCases.add(new Case(RecordTypeId = RTCase.nonCustomerComplaint));
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
          RecordTypeId = RTCase.nonCustomerComplaint,
          Status = 'Open',
          IDR_Escalated_to__c = '1'
        )
      );
    }
    insert newCases;

    // WHEN they are auto-escalated (kind of)
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].IsEscalated = true;
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

  @IsTest
  static void testCreditReferralEscalationStatus() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    // GIVEN cases are created as not escalated
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.creditReferral,
          Status = GetHelpConstants.OPEN_STATUS,
          AccountId = acc.Id,
          Credit_Id__c = '000-000-000-00' + String.valueOf(i)
        )
      );
    }
    insert newCases;

    // WHEN they status set to escalated
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases[i].Status = GetHelpConstants.ESCALATED_STATUS;
    }
    update newCases;

    // THEN check status and owner fields
    Case c = [SELECT Status, OwnerId FROM Case WHERE Id = :newCases[0].Id];
    System.assertEquals(
      'Escalated',
      c.Status,
      'Status should have been updated to Escalated '
    );
    System.assertEquals(
      GetHelpCaseActions.cadReferralQueue.Id,
      c.OwnerId,
      'Escalated To should have assigned to CAD Referral Queue '
    );
  }

  @IsTest
  static void testCreditReferralDefaults() {
    // WHEN Credit Referral is created
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    ResidentialLoanApplication sampleRLA = [
      SELECT Id, AccountId
      FROM ResidentialLoanApplication
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];

    Case[] newCases = new List<Case>();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = TestDataFactory.createCase('Credit_Referral');
      c.Credit_Id__c = '000-000-000-00' + String.valueOf(i);
      c.AccountId = acc.Id;
      newCases.add(c);
    }
    Test.startTest();
    insert newCases;

    // Verify new case record has an account and loan application
    Case sampleCase = [
      SELECT Loan_Application__c, AccountId
      FROM Case
      WHERE Id = :newCases[0].Id
      LIMIT 1
    ];
    System.assertEquals(
      sampleRLA.Id,
      sampleCase.Loan_Application__c,
      'Case application should be retrieved from the queried loan application upon inserting'
    );
    System.assertEquals(
      sampleRLA.AccountId,
      sampleCase.AccountId,
      'Case account should be retrieved from the queried loan application customer upon inserting'
    );
    Test.stopTest();
  }

  @isTest
  static void testDateWhenComplaintIsReopened() {
    // GIVEN cases are created as not re-openened
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.nonCustomerComplaint,
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
          RecordTypeId = RTCase.nonCustomerComplaint
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
      newCases.add(new Case(RecordTypeId = RTCase.nonCustomerComplaint));
    }
    Test.startTest();
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
    Test.stopTest();
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
      newCases.add(new Case(RecordTypeId = RTCase.nonCustomerComplaint));
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 2
    ];
    // create 2 parent cases
    List<Case> parentCaseList = new List<Case>();

    for (Integer i = 0; i < 2; i++) {
      parentCaseList.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
          AccountId = accList[0].Id
        )
      );
    }
    insert parentCaseList;

    Test.startTest();
    // create a child case
    Case childCase = new Case(
      ParentId = parentCaseList[0].Id,
      RecordTypeId = RTCase.generalInquiry,
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
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
      WHERE ANZx_Customer__c = TRUE
      LIMIT 1
    ];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = RTCase.generalInquiry,
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
          RecordTypeId = RTCase.customerComplaint,
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
          RecordTypeId = RTCase.generalInquiry,
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
        new Case(RecordTypeId = RTCase.generalInquiry, AccountId = accountId)
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
    List<String> caseTypes = new List<String>{ 'Remote Access', 'Not a Scam' };

    //Temporarily disable Validation Rules
    System.runAs(thisUser) {
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = UserInfo.getOrganizationId(),
        Disable_VRs__c = true
      );
    }

    // GIVEN FraudX Agent user has required acces
    // Query for API User
    User usr = TestUtil.getUserByFirstName('FraudXTest');

    // WHEN FraudX Agent user creates or updates a Fraud case
    Case[] newCases = new List<Case>();
    Account acc = [
      SELECT Id
      FROM Account
      WHERE OCV_ID__c = 'PERSONOCV879879'
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
      sampleCase2.RecordType.Name + ' - ' + sampleCase2.Type,
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
          RecordTypeId = RTCase.nonCustomerComplaint,
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
          RecordTypeId = RTCase.cardDispute,
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

  @isTest
  static void testPopulateFalseCustomerProfileCaseSubject() {
    Account acc = [SELECT Id, Name FROM Account LIMIT 1];
    Case c = new Case(
      RecordTypeId = RTCase.falseCustomerProfile,
      Type = 'Not Fraud',
      Origin = 'Other',
      AccountId = acc.Id
    );
    Test.startTest();
    insert c;
    c = [SELECT Subject FROM Case WHERE id = :c.id LIMIT 1];
    Test.stopTest();
    System.assertEquals(
      'False Onboarding',
      c.Subject,
      'New case subject should be as expected.'
    );
  }

  //Test to verify Subject auto-population when Case Type has a numerical value different from the label
  static void testNumericCaseTypeValue() {
    // GIVEN the selected Case Types has numerical values as API names
    List<String> caseTypes = new List<String>{ '10', '11' };

    // WHEN a user creates or updates a Fradx 'Scam' case
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
          RecordTypeId = RTCase.scam,
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
      WHERE OCV_ID__c = 'PERSONOCV879879'
      LIMIT 1
    ];

    CustomerOnboardingApplication__c cob = new CustomerOnboardingApplication__c(
      PersonaId__c = 'dsfsadfasdf',
      OCVId__c = '4324234234',
      SecurityMobile__c = '61400000000'
    );
    insert cob;

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = new List<Id>(CheckCaseRecordType.FRAUD_RT_IDS)[4],
          Type = 'KYC QA Sample',
          AccountId = acc.Id,
          CustomerOnboardingApplication__c = cob.Id
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
    Test.startTest();
    Case newCase = new Case();
    newCase.IDR_Customer_Number__c = '123456789012';
    newCase.Origin = 'Phone';
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
    Test.stopTest();
    System.assert(
      newCase.Case_Hour_Duration__c >= 0,
      'New case duration time hour should be as expected.'
    );
  }

  @istest
  static void testBusinessHoursAssignment() {
    Case newCase = new Case();
    newCase.RecordTypeId = RTCase.nonCustomerComplaint;
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
          RecordTypeId = RTCase.nonCustomerComplaint,
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
      Subject = IDRConstants.TASK_SUBJECT_DAY1,
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
      WHERE RecordTypeId = :GetHelpConstants.ACCOUNT_PERSON_ACCOUNT_RT_ID
      LIMIT 1
    ];

    // WHEN an ANZ Plus Case is created
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(RecordTypeId = RTCase.generalInquiry, AccountId = acc.Id)
      );
    }

    Test.startTest();
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(newCases, null);
    Test.stopTest();

    // THEN Contact Name lookup should be auto-populated
    System.assertEquals(
      acc.PersonContactId,
      newCases[0].ContactId,
      'Failed to auto-populate Contact lookup on ANZ Plus cases while inserting'
    );
  }

  //test IDRCollectionAction getStartCollectionMap method
  //This test method verifies if the returned startCollection map contains IDR Collection Number from Task record and its related caseId/whatId
  @isTest
  static void testGetStartCollectionMap() {
    //Create a customer complaint
    Case custCompCase = IDRTestDataFactory.createAfcaCustomerComplaintCase(
      'Standard',
      '5',
      '38'
    );
    custCompCase.IDR_Collection_Number__c = '1234567890';
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
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = RTCase.generalInquiryCmos;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    oldRecord.IDR_Product_Category__c = 'Not product related';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = RTCase.generalInquiry;
    System.assert(
      GetHelpCaseActionsHelper.isAEMConverted(oldRecord, newRecord),
      'This should be an AEM converted Case'
    );
    Test.stopTest();
  }

  @isTest
  static void testIsAEMConvertedFailure() {
    Case oldRecord = new Case();
    oldRecord.Description = faker.randomString(10);
    oldRecord.Status = IDRConstants.OPEN_STATUS;
    oldRecord.ANZx_Customer__c = true;
    oldRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    oldRecord.RecordTypeId = RTCase.generalInquiryCmos;
    oldRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    oldRecord.Type = '11';
    oldRecord.IDR_Product_Category__c = 'Not product related';
    insert oldRecord;

    Test.startTest();
    Case newRecord = oldRecord.clone(true, true);
    newRecord.RecordTypeId = RTCase.fraud;
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
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = RTCase.generalInquiryCmos;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.IDR_Product_Category__c = 'Not product related';
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
    caseRecord.RecordTypeId = RTCase.generalInquiry;
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
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = RTCase.generalInquiryCmos;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.IDR_Product_Category__c = 'Not product related';
    caseRecord.AccountId = acc.Id;
    caseRecord.Type = '11';
    insert caseRecord;

    Test.startTest();
    // Case caseRecord = prepareCaseForTestingEntitlement(RTCase.anzxComplaint);
    caseRecord.RecordTypeId = RTCase.anzxComplaint;
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
    Case caseRecord = new Case();
    caseRecord.Description = faker.randomString(10);
    caseRecord.Status = IDRConstants.OPEN_STATUS;
    caseRecord.ANZx_Customer__c = true;
    caseRecord.Origin = GetHelpConstants.ANZ_PLUS_WEB_ORIGIN;
    caseRecord.RecordTypeId = RTCase.generalInquiryCmos;
    caseRecord.IDR_NC_Mobile__c = String.valueOf(faker.randomDecimal(10, 0));
    caseRecord.IDR_Product_Category__c = 'Not product related';
    caseRecord.AccountId = acc.Id;
    caseRecord.Type = '11';
    insert caseRecord;

    Test.startTest();
    caseRecord.RecordTypeId = RTCase.nonCustomerComplaint;
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
      RecordTypeId = RTCase.directEntryDispute,
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
      RecordTypeId = RTCase.directEntryDispute,
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
      RecordTypeId = RTCase.directEntryDispute,
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
      RecordTypeId = RTCase.directEntryDispute,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Description = 'Charged more than once for same purchase',
      Effective_Date__c = Date.valueof(System.today()),
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.anzBusinessHours.Id
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
      RecordTypeId = RTCase.directEntryDispute,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.anzBusinessHours.Id
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
          RecordTypeId = RTCase.generalInquiry,
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
      RecordTypeId = RTCase.directEntryDispute,
      AccountId = acc.Id,
      Auto_Created__c = false,
      Dispute_Reason__c = 'Duplicate Transaction',
      Origin = '1',
      Priority = 'Medium',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      BusinessHoursId = CommonUtil.anzBusinessHours.Id,
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
          RecordTypeId = RTCase.nonCustomerComplaint,
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
        RecordTypeId = :RTCase.nonCustomerComplaint
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
          RecordTypeId = RTCase.anzxComplaint,
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
      WHERE RecordTypeId = :RTCase.anzxComplaint AND OCV_Id__c = :acc.OCV_ID__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      newCaseRecords.size(),
      'Should have ' + Label.Test_Bulk_Size + ' new ANZx Complaint records.'
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
          RecordTypeId = RTCase.cardDispute,
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

  // Tests if the Non Customer Complaint Case Subject is populated correctly
  // based on case record type and issue and when created/updated by ANZx user only
  @isTest
  public static void testPopulateNonCustomerComplaintSubject() {
    User coachUser = TestUtil.getUserByFirstName('CoachTest');

    List<Case> casesToInsert = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesToInsert.add(
        new Case(
          RecordTypeId = RTCase.nonCustomerComplaint,
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
          RecordTypeId = RTCase.nonCustomerComplaint,
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
    Test.startTest();
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
    verifyCaseSubject(theCase);
    verifyCardTokenNumber(theCase);
    verifyDuplicateDispute(theCase, recordTypeDeveloperName);
    theCase.Status = 'Closed';
    theCase.External_System__c = 'CARBe';
    theCase.External_Case_Id__c = 'EXTERNALCASEID000';
    try {
      update theCase;
    } catch (DmlException e) {
      System.assert(false, 'Failed to create dispute case');
    }
    Test.stopTest();
    verifyDuplicateDispute(theCase, recordTypeDeveloperName);
  }

  private static void insertTestAccountsForDisputeCases() {
    Id industryRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('IndustriesIndividual')
      .getRecordTypeId();

    List<Account> accountList = new List<Account>();
    Account newAccount1 = TestDataFactory.createTestAccountForDisputeCases('1');
    newAccount1.RecordTypeId = industryRecordTypeId;
    accountList.add(newAccount1);
    Account newAccount2 = TestDataFactory.createTestAccountForDisputeCases('2');
    newAccount2.RecordTypeId = industryRecordTypeId;
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
      'NPP_Dispute',
      'PayTo_Dispute'
    };
    if (
      disputeCasesRecordTypeNames.contains(theCase.RecordType.DeveloperName)
    ) {
      System.assertEquals(
        theCase.RecordType.Name + ' - ' + theCase.Dispute_Reason__c,
        theCase.Subject,
        'New case subject should be as expected.'
      );
    } else if (fraudCasesRecordTypeNames.contains(theCase.RecordType.Name)) {
      System.assertEquals(
        theCase.RecordType.Name + ' - ' + theCase.Type,
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
          theCase.Type + ' - ' + subTypes,
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

  @isTest
  static void testEmailTaskOnCaseClosureCreation() {
    User usr = TestUtil.getUserByFirstName('IntegrationTest');
    Case theCase;

    Test.startTest();
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

      theCase.Status = 'Closed';
      Test.stopTest();
      update theCase;
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
    Test.startTest();
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

  // Test Prevent BOH coach assigning invalid credit referral
  @isTest
  public static void testCreditReferralBOHInvalidAssignment() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    User usr = TestUtil.getUserByFirstName('BOHCoachTest');
    User integrationUser = TestUtil.getUserByFirstName(
      'CreditRefIntegrationUser'
    );
    List<Case> creditRefCases = new List<Case>();
    Group coachQueue = CommonUtil.getQueueByName(
      'No_CAD_Credit_Referral_Case_Queue'
    );
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = TestDataFactory.createCase('Credit_Referral');
      c.OwnerId = coachQueue.Id;
      c.Case_Authority_Level__c = 'CAD_0';
      c.AccountId = acc.Id;
      c.Credit_Id__c = '000-000-000-00' + String.valueOf(i);
      creditRefCases.add(c);
    }

    System.runAs(integrationUser) {
      insert creditRefCases;
    }

    Case c = [SELECT Id FROM Case WHERE Id = :creditRefCases[0].Id];

    Test.startTest();
    System.runAs(usr) {
      try {
        c.OwnerId = usr.Id;
        update c;
      } catch (Exception e) {
        System.assert(
          e.getMessage()
            .contains(
              'You can\'t assign a credit referral case that you do not have authority to resolve. Please select another case.'
            ),
          'Error message should be displayed'
        );
      }
    }
    Test.stopTest();
  }

  // Test BOH coach assigning credit referral
  @isTest
  public static void testCreditReferralBOHAssignment() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    User usr = TestUtil.getUserByFirstName('BOHCoachTest');
    User integrationUser = TestUtil.getUserByFirstName(
      'CreditRefIntegrationUser'
    );
    List<Case> creditRefCases = new List<Case>();
    Group coachQueue = CommonUtil.getQueueByName(
      'No_CAD_Credit_Referral_Case_Queue'
    );
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = TestDataFactory.createCase('Credit_Referral');
      c.OwnerId = coachQueue.Id;
      c.Case_Authority_Level__c = 'NO CAD';
      c.AccountId = acc.Id;
      c.Credit_Id__c = '000-000-000-00' + String.valueOf(i);
      creditRefCases.add(c);
    }

    System.runAs(integrationUser) {
      insert creditRefCases;
    }

    Case c = [SELECT Id FROM Case WHERE Id = :creditRefCases[0].Id];

    Test.startTest();
    System.runAs(usr) {
      c.OwnerId = usr.Id;
      update c;
    }

    Assert.areEqual(usr.Id, c.OwnerId, 'Expected case owner to be boh coach');
    Test.stopTest();
  }

  // Test credit assessment officer assigning credit referral
  @isTest
  public static void testCreditReferralOfficerAssignment() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];

    User usr = TestUtil.getUserByFirstName('CreditAssessmentOfficer');
    User integrationUser = TestUtil.getUserByFirstName(
      'CreditRefIntegrationUser'
    );
    List<Case> creditRefCases = new List<Case>();
    Group coachQueue = CommonUtil.getQueueByName(
      'No_CAD_Credit_Referral_Case_Queue'
    );
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = TestDataFactory.createCase('Credit_Referral');
      c.OwnerId = coachQueue.Id;
      c.Case_Authority_Level__c = 'NO CAD';
      c.AccountId = acc.Id;
      c.Credit_Id__c = '000-000-000-00' + String.valueOf(i);
      creditRefCases.add(c);
    }

    System.runAs(integrationUser) {
      insert creditRefCases;
    }

    Case c = [SELECT Id FROM Case WHERE Id = :creditRefCases[0].Id];

    Test.startTest();
    System.runAs(usr) {
      c.OwnerId = usr.Id;
      update c;
    }

    Assert.areEqual(
      usr.Id,
      c.OwnerId,
      'Expected case owner to be credit assessment officer'
    );
    Test.stopTest();
  }

  // Test Credit assessment lead invalid assign to boh
  @isTest
  public static void testCreditReferralLeadToBohInvalid() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'CustomerRLA' LIMIT 1];
    User creditLead = TestUtil.getUserByFirstName('CreditLead');
    User bohCoach = TestUtil.getUserByFirstName('BOHCoachTest');
    User integrationUser = TestUtil.getUserByFirstName(
      'CreditRefIntegrationUser'
    );
    List<Case> creditRefCases = new List<Case>();
    Group coachQueue = CommonUtil.getQueueByName(
      'No_CAD_Credit_Referral_Case_Queue'
    );
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Case c = TestDataFactory.createCase('Credit_Referral');
      c.OwnerId = coachQueue.Id;
      c.Case_Authority_Level__c = 'CAD_0';
      c.AccountId = acc.Id;
      c.Credit_Id__c = '000-000-000-00' + String.valueOf(i);
      creditRefCases.add(c);
    }

    System.runAs(integrationUser) {
      insert creditRefCases;
    }

    Case c = [SELECT Id FROM Case WHERE Id = :creditRefCases[0].Id];

    Test.startTest();
    System.runAs(creditLead) {
      try {
        c.OwnerId = bohCoach.Id;
        update c;
      } catch (Exception e) {
        System.assert(
          e.getMessage()
            .contains(
              'You can\'t assign a credit referral case to someone who does not have the authority to resolve it.'
            ),
          'Error message should be displayed'
        );
      }
    }
    Test.stopTest();
  }
}
