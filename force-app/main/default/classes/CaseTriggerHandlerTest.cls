@SuppressWarnings('PMD.CyclomaticComplexity')
@isTest
private class CaseTriggerHandlerTest {
  public static Map<String, String> caseTypeLabelByValue = CommonUtil.getPicklistLabelsByValues(
    Case.Type
  );

  @testSetup
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
        'Customer_Read_Only'
      };
      List<PermissionSet> psList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :fraudXPSs
      ];

      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : psList) {
        psaList.add(TestUtil.createPSAssignment(fraudXAgent.id, ps.Id));
      }
      insert psaList;

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
            OwnerId = fraudXAgent.Id
          )
        );
      }
      // Create a PersonAccount
      Account personAcc = new Account(
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
          .get('PersonAccount')
          .getRecordTypeId(),
        FirstName = Faker.randomString(5),
        LastName = Faker.randomString(5),
        OCV_ID__c = 'PERSONOCV879879',
        ANZx_Customer__c = true
      );
      accnts.add(personAcc);

      Account a = new Account(
        Name = 'Complaint Entitlement Account',
        OCV_ID__c = faker.randomString(10),
        AR_C_Customer__c = true
      );
      accnts.add(a);
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
          AssigneeId = idrUser.id,
          PermissionSetId = ps.Id
        );
        idrPsaList.add(psa);
      }
      insert idrPsaList;
    }
  }

  @isTest
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
      WHERE id = :newCases[0].id
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
      WHERE id = :casesWithCopiedCaseNumber[0].id
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
  @isTest
  static void testComplaintCardNumberMasking() {
    // GIVEN cases relate to a account/card/policy, description etc with numbers greater than 8 digits
    Case[] casesWithNumberText = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      casesWithNumberText.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test decription 1234-5678-9101 check mask',
          IDR_Complainant_Desired_Outcome__c = 'Test decription 1234 5678 9101 check mask',
          IDR_Description_of_Outcome__c = 'Test decription 123456789101 check mask',
          IDR_Systemic_Issue_Description__c = 'Test decription 1234-5678-9101 check mask',
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
      WHERE id = :casesWithNumberText[0].id
    ];
    System.assertEquals(
      '*****1234',
      c.IDR_Account_Card_Policy_Number__c,
      'IDR_Account_Card_Policy_Number__c should be masked.'
    );
    System.assertEquals(
      'Test decription ********9101 check mask',
      c.Description,
      'Description should be masked.'
    );
    System.assertEquals(
      'Test decription ********9101 check mask',
      c.IDR_Complainant_Desired_Outcome__c,
      'IDR_Complainant_Desired_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ********9101 check mask',
      c.IDR_Description_of_Outcome__c,
      'IDR_Description_of_Outcome__c should be masked.'
    );
    System.assertEquals(
      'Test decription ********9101 check mask',
      c.IDR_Systemic_Issue_Description__c,
      'IDR_Systemic_Issue_Description__c should be masked.'
    );
  }

  @isTest
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
      WHERE id = :newCasesWithStatus[0].id
    ];
    System.assert(c.IsEscalated, 'IsEscalated is true');
  }

  @isTest
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
      WHERE id = :newCases[0].id
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
    c = [SELECT CaseNumber, IsEscalated FROM Case WHERE id = :newCases[0].id];
    System.assert(c.IsEscalated, 'IsEscalated is true');
  }

  @isTest
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
      WHERE id = :newCases[0].id
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
      Email = 'idruser@anztest.com',
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
  static void testCFMSEscalation() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1'
        )
      );
    }
    insert newCases;
    System.assert(
      IDRCaseActions.idrCaseEscalations.size() ==
      Integer.valueOf(Label.Test_Bulk_Size),
      'Matching no of events'
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          AccountId = accList[0].Id
        )
      );
    }
    insert parentCaseList;

    // create a child case
    Case childCase = new Case(
      ParentId = parentCaseList[0].Id,
      RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
      AccountId = accList[1].Id
    );
    insert childCase;

    // Update parent case to throw error
    try {
      parentCaseList[0].ParentId = parentCaseList[1].Id;
      update parentCaseList;
    } catch (DmlException e) {
      system.assertEquals(
        'You cannot add parent case. This case is associated with child cases',
        e.getDmlMessage(0)
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id,
          Type = 'Card',
          Additional_Type__c = 'App Support;Card;'
        )
      );
    }

    try {
      insert newCases;
    } catch (DMLexception e) {
      system.assert(
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id,
          Additional_Type__c = 'App Support;Card;Coaching'
        )
      );
    }

    try {
      insert newCases;
    } catch (DMLexception e) {
      system.assert(
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
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

    system.assertEquals('Cards - Damaged card', newCases[0].Subject);
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
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

    system.assertEquals('Cards', newCases[0].Subject);
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
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

    system.assertEquals(
      'Cards - Damaged card - Using card',
      newCases[0].Subject
    );
  }

  //Tests if the complaints entitlment logic in working as expected.
  @isTest
  static void testComplaintEntilement() {
    Account a = [SELECT Id FROM Account WHERE AR_C_Customer__c = TRUE LIMIT 1];
    Slaprocess sla = [
      SELECT Id, NAME
      FROM Slaprocess
      WHERE Name = 'complaints'
      LIMIT 1
    ];
    Entitlement et = new Entitlement(
      Name = 'Complaints Entitlement',
      AccountId = a.Id,
      StartDate = Date.valueof(System.now().addDays(-2)),
      SlaProcessId = sla.Id
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
    system.assertEquals(et.Id, checkEntitlment.EntitlementId);
    system.assertEquals('Normal', checkEntitlment.IDR_Milestone_Sla__c);
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
    system.assertEquals('Normal', checkMilestone.IDR_Milestone_Sla__c);
  }

  @isTest
  static void testRollupRelatedBugOnInsert() {
    insert new Reported_Bug__c(Name = 'Test Bug');
    Id bugId = [SELECT Id FROM Reported_Bug__c WHERE Name = 'Test Bug' LIMIT 1]
    .Id;
    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          Related_Bug__c = bugId,
          RecordTypeId = GetHelpCaseActions.BUG_RT_ID,
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
      Integer.valueOf(Label.Test_Bulk_Size),
      relatedCaseNumber,
      'Incorrect reported bug rollup value'
    );
  }

  @isTest
  static void testRollupRelatedBugOnUpdate() {
    insert new Reported_Bug__c(Name = 'Test Bug');
    Id bugId = [SELECT Id FROM Reported_Bug__c WHERE Name = 'Test Bug' LIMIT 1]
    .Id;
    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          Related_Bug__c = bugId,
          RecordTypeId = GetHelpCaseActions.BUG_RT_ID,
          AccountId = accountId
        )
      );
    }
    insert newCases;

    Case updateCase = new Case(
      RecordTypeId = GetHelpCaseActions.BUG_RT_ID,
      AccountId = accountId
    );
    insert updateCase;

    CheckRecursive.firstCall = false;

    Test.startTest();
    updateCase.Related_Bug__c = bugId;
    update updateCase;
    Test.stopTest();

    Decimal relatedCaseNumber = [
      SELECT Number_of_Related_Cases__c
      FROM Reported_Bug__c
      WHERE Name = 'Test Bug'
      LIMIT 1
    ]
    .Number_of_Related_Cases__c;
    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size) + 1,
      relatedCaseNumber,
      'Incorrect reported bug rollup value'
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
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
    Id bugId = [SELECT Id FROM Reported_Bug__c WHERE Name = 'Test Bug' LIMIT 1]
    .Id;
    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<Case> newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
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
          RecordTypeId = GetHelpCaseActions.FRAUD_RT_IDS[
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
    system.assertEquals(
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
    system.assertEquals(
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
          Status = 'Resolved',
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
      updateCase.Status = 'Resolved';
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
    System.assertEquals(IDRTaskActions.siQueue.Id, psiTasks[0].OwnerId);
    System.assertEquals(IDRTaskActions.IDR_TASK_SUBJECT, psiTasks[0].Subject);
  }

  //Tests if the Dispute Case Subject is populated correctly based on case record type and dispute reason
  @isTest
  static void testPopulateDisputeCaseSubject() {
    Case[] newCases = new List<Case>();
    Account acc = [SELECT Id FROM Account LIMIT 1];
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = GetHelpCaseActions.CARD_DISPUTE_RT_ID,
          Type = '',
          Dispute_Reason__c = 'Cardholder does not recognise transaction',
          AccountId = acc.Id,
          Is_The_Card_Lost_Stolen__c = 'Lost'
        )
      );
    }
    insert newCases;
    newCases = [SELECT Subject FROM Case WHERE id = :newCases[0].id];
    system.assertEquals(
      'Card - Cardholder does not recognise transaction',
      newCases[0].Subject
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
          RecordTypeId = GetHelpCaseActions.SCAM_RT_ID,
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
    system.assertEquals(
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
    system.assertEquals(
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
    Faker faker = new Faker('AU');

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
          RecordTypeId = GetHelpCaseActions.FRAUD_RT_IDS[4],
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
    system.assertEquals(
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

    update newCase;

    newCase = [
      SELECT Id, Case_Hour_Duration__c
      FROM Case
      WHERE Id = :newCase.Id
    ];
    System.assert(newCase.Case_Hour_Duration__c >= 0);
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

    System.assertEquals(bhs.Id, c.BusinessHoursId);
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

    system.assertNotEquals(idrTask.ActivityDate, checkTask.ActivityDate);
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
          RecordTypeId = GetHelpCaseActions.GENERAL_INQUIRY_RT_ID,
          AccountId = acc.Id
        )
      );
    }

    Test.startTest();
    GetHelpCaseActionsHelper.populateContactLookupForANZPlus(newCases);
    Test.stopTest();

    // THEN Contact Name lookup should be auto-populated
    system.assertEquals(
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
      SELECT id, developername
      FROM group
      WHERE
        developername = 'Specialised_Early_Resolution_Hardship'
        AND Type = 'Queue'
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
      System.assertEquals(c.OwnerId.getSobjectType(), Group.SobjectType);
      System.assertEquals(queueList[0].Id, c.OwnerId);
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
    insert newCases;
    Test.startTest();
    newCases[0].Status = 'Escalated';
    newCases[0].IDR_Escalation_Reason__c = '1';

    update newCases[0];

    Case caseRec = [SELECT Id, OwnerId FROM Case WHERE id = :newCases[0].id];
    System.assertEquals(Group.SobjectType, caseRec.OwnerId.getSobjectType());
    System.assertEquals(queueList[1].Id, caseRec.OwnerId);

    newCases[1].IDR_Subsequent_Issue__c = '39';
    newCases[1].Status = 'Escalated';
    newCases[1].IDR_Escalation_Reason__c = '1';
    update newCases[1];

    Case caseRec1 = [SELECT Id, OwnerId FROM Case WHERE id = :newCases[1].id];
    System.assertEquals(Group.SobjectType, caseRec1.OwnerId.getSobjectType());
    System.assertEquals(queueList[0].Id, caseRec1.OwnerId);

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
    insert newCases;
    Test.startTest();
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
}
