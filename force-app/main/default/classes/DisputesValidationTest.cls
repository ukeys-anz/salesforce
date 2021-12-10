@isTest
public with sharing class DisputesValidationTest {
  public static final String DISPUTE_CARD_VR1_ERROR = 'These fields are required: Description of Issue, Is The card Lost/Stolen, Card In Possession During Transaction, Has The Card Been Stopped.';
  public static final String DISPUTE_CARD_VR8_ERROR = 'These fields are required: Description of Issue, Goods Or Services Returned, Goods Returned or Service Cancelled Date, What Happened with Merchant?';
  public static final String DISPUTE_ATM_VR2_ERROR = 'Please provide Description of Issue.';
  public static final String DISPUTE_NPP_VR1_ERROR = 'These fields are required: Description of Issue, Intended Account BSB, Intended Account Name, Intended Account Number.';

  @TestSetup
  // Turn off triggers to run tests
  static void turnOffTriggers() {
    // Insert Account & User as current user, to get around MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      // Create a Coach User with 'Coach Agent' role
      Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
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
        'Customer_Read_Only',
        'Quality_Assessment_Read_Only',
        'Case_Read_Write_Dispute'
      };
      List<PermissionSet> coachPsList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN :coachPSs
      ];
      List<PermissionSetAssignment> coachPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : coachPsList) {
        coachPsaList.add(TestUtil.createPSAssignment(coach.id, ps.Id));
      }
      insert coachPsaList;
      // Create test data for account case
      Account acc = new Account(
        Name = 'TestAccount',
        Display_Name__c = 'TestAccount',
        OCV_ID__c = 'OCV78786678',
        ANZx_Customer__c = true
      );
      insert acc;
      insert new Case(
        RecordTypeID = GetHelpConstants.CARD_DISPUTE_RT_ID,
        Subject = 'Test Disputes',
        Type = 'Cards',
        Dispute_Reason__c = 'Charged for a cancelled payment',
        AccountId = acc.Id,
        Is_The_Card_Lost_Stolen__c = 'Lost',
        Status = 'Open',
        Queue__c = null,
        Description = 'Some description',
        Regular_Payment_Cancellation_Date__c = Date.valueOf('2021-10-15'),
        Customer_Contacted_Merchant__c = 'Yes',
        Merchant_Description__c = 'Coles'
      );
      insert new Salesforce_Library_Settings__c(
        SetupOwnerId = UserInfo.getOrganizationId(),
        Disable_Triggers__c = true
      );
    }
  }
  // When Case Owner is manually re-assigned from Queue to an invalid User Role
  @isTest
  static void testDisputesQueuetoUser() {
    Case c = (Case) [SELECT Id FROM Case LIMIT 1];
    c.OwnerId = UserInfo.getUserId();
    Test.startTest();
    try {
      update c;
    } catch (Exception e) {
      System.assertEquals(
        true,
        e.getMessage()
          .contains(
            'For ATM or Card record types, please select either Card Disputes - General Queue or Card Disputes - Fraud Queue or the User must have a Coach, Support Coach, Card Dispute Agent or FraudX Agent Role.'
          ),
        'Incorrect error message.'
      );
    }
    Test.stopTest();
  }

  // When manually re-assigned to a invalid Queue to pass
  @isTest
  static void testDisputesValidQueue() {
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Group cardDisputesQueue = CommonUtil.getQueueByName(
      'Card_Dispute_General_Queue'
    );
    Case c = (Case) [SELECT Id FROM Case LIMIT 1];
    c.OwnerId = cardDisputesQueue.Id;
    Test.startTest();
    System.runAs(usr) {
      update c;
    }
    Test.stopTest();
    System.assertEquals(
      c.OwnerId,
      cardDisputesQueue.Id,
      'Update was not successful.'
    );
  }

  // When the Status changes to closed and the External Case ID is null
  @isTest
  static void testDisputesStatusClosedNullExternal() {
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Case c = (Case) [SELECT Id, External_System__c, Status FROM Case LIMIT 1];
    c.External_Case_ID__c = null;
    c.Status = 'Closed';
    Test.startTest();
    System.runAs(usr) {
      try {
        update c;
      } catch (Exception e) {
        System.assertEquals(
          true,
          e.getMessage()
            .contains(
              'These fields are required in order to change Status from open - External System and External Case ID.'
            ),
          'Incorrect error message.'
        );
      }
    }
    Test.stopTest();
  }

  // When External System is changed and External Case ID is null
  @isTest
  static void testDisputesChangedButNullExternal() {
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Case c = (Case) [
      SELECT Id, External_System__c, External_Case_ID__c
      FROM Case
      LIMIT 1
    ];
    c.OwnerId = usr.Id;
    update c;
    c.External_System__c = 'CARBe';
    c.External_Case_ID__c = null;
    Test.startTest();
    System.runAs(usr) {
      try {
        update c;
      } catch (Exception e) {
        System.assertEquals(
          true,
          e.getMessage()
            .contains(
              'Please select an External System and acknowledge that External System ID has been provided.'
            ),
          'Incorrect error message.' + e.getMessage()
        );
      }
    }
    Test.stopTest();
  }

  // Test DISPUTE_CARD_VR1 validation rule with error
  @isTest
  static void testDisputeCardV1RuleWithError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a card dispute with Dispute Reason = 'Don't recognise the transaction'
    // And one of these fields Customer Description, Is The Card Lost/Stolen, (If card lost/stolen = No, Card In Possession During Transaction), Has The Card Been Stopped is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case cardDispute = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Don\'t recognise the transaction',
      AccountId = acc.Id,
      Description = 'Sample Customer Description',
      Is_The_Card_Lost_Stolen__c = 'No',
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert cardDispute;
      } catch (DmlException e) {
        // THEN an error message should be thrown by DISPUTE_CARD_VR1 validation rule
        System.assertEquals(
          true,
          e.getMessage().contains(DISPUTE_CARD_VR1_ERROR),
          'Error messages should match.'
        );
      }
    }
    System.assertEquals(
      0,
      [SELECT Id FROM Case].size(),
      'Card dispute should not be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_CARD_VR1 validation rule without error
  @isTest
  static void testDisputeCardV1RuleWithoutError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a card dispute with Dispute Reason = 'Don't recognise the transaction'
    // And NONE of these fields Customer Description, Is The Card Lost/Stolen, (If card lost/stolen = No, Card In Possession During Transaction), Has The Card Been Stopped is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case cardDispute = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Don\'t recognise the transaction',
      AccountId = acc.Id,
      Description = 'Sample Customer Description',
      Is_The_Card_Lost_Stolen__c = 'No',
      Card_In_Possession_During_Transaction__c = 'Yes',
      Has_The_Card_Been_Stopped__c = 'No',
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert cardDispute;
      } catch (DmlException e) {
        // THEN NO error message should be thrown by DISPUTE_CARD_VR1 validation rule
        System.assertEquals(null, e, 'Error messageshould be null.');
      }
    }
    System.assertEquals(
      1,
      [SELECT Id FROM Case].size(),
      'Card dispute should be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_CARD_VR8 validation rule with error
  @isTest
  static void testDisputeCardV8RuleWithError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a card dispute with Dispute Reason = 'Product Defective or Unsatisfactory'
    // And one of these fields Customer Description, Goods Or Services Returned, Merchant Description, Goods Returned or Service Cancelled Date (If Goods or Services Returned is equal to Yes) is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case cardDispute = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Product Defective or Unsatisfactory',
      AccountId = acc.Id,
      Description = 'Sample Customer Description',
      Goods_Or_Services_Returned__c = 'Yes',
      Merchant_Description__c = 'Sample Merchant Description',
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert cardDispute;
      } catch (DmlException e) {
        // THEN an error message should be thrown by DISPUTE_CARD_VR8 validation rule
        System.assertEquals(
          true,
          e.getMessage().contains(DISPUTE_CARD_VR8_ERROR),
          'Error messages should match.'
        );
      }
    }
    System.assertEquals(
      0,
      [SELECT Id FROM Case].size(),
      'Card dispute should not be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_CARD_VR8 validation rule without error
  @isTest
  static void testDisputeCardV8RuleWithoutError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a card dispute with Dispute Reason = 'Product Defective or Unsatisfactory'
    // And NONE of these fields Customer Description, Goods Or Services Returned, Merchant Description, Good Returned or Service Cancelled Date (If Goods or Services Returned is equal to Yes) is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case cardDispute = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Product Defective or Unsatisfactory',
      AccountId = acc.Id,
      Description = 'Sample Customer Description',
      Goods_Or_Services_Returned__c = 'Yes',
      Date_Goods_Were_Returned_Or_Services_can__c = Date.valueOf('2021-11-10'),
      Merchant_Description__c = 'Sample Merchant Description',
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert cardDispute;
      } catch (DmlException e) {
        // THEN NO error message should be thrown by DISPUTE_CARD_VR8 validation rule
        System.assertEquals(null, e, 'Error messageshould be null.');
      }
    }
    System.assertEquals(
      1,
      [SELECT Id FROM Case].size(),
      'Card dispute should be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_ATM_VR2 validation rule with error
  @isTest
  static void testDisputeATMV2RuleWithError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a ATM dispute with Dispute Reason = 'Duplicate Transactions'
    // And Customer Description is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case atmDispute = new Case(
      RecordTypeId = GetHelpConstants.ATM_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Duplicate Transactions',
      AccountId = acc.Id,
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert atmDispute;
      } catch (DmlException e) {
        // THEN an error message should be thrown by DISPUTE_ATM_VR2 validation rule
        System.assertEquals(
          true,
          e.getMessage().contains(DISPUTE_ATM_VR2_ERROR),
          'Error messages should match.'
        );
      }
    }
    System.assertEquals(
      0,
      [SELECT Id FROM Case].size(),
      'ATM dispute should not be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_ATM_VR2 validation rule without error
  @isTest
  static void testDisputeATMV2RuleWithoutError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a ATM dispute with Dispute Reason = 'Duplicate Transactions'
    // And Customer Description is NOT missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case atmDispute = new Case(
      RecordTypeId = GetHelpConstants.ATM_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Duplicate Transactions',
      AccountId = acc.Id,
      Description = 'Sample Customer Description',
      Transaction_Id__c = 'CT5M00000024404234',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert atmDispute;
      } catch (DmlException e) {
        // THEN NO error message should be thrown by DISPUTE_ATM_VR2 validation rule
        System.assertEquals(null, e, 'Error messageshould be null.');
      }
    }
    System.assertEquals(
      1,
      [SELECT Id FROM Case].size(),
      'ATM dispute should be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_NPP_VR1 validation rule with error
  @isTest
  static void testDisputeNPPV1RuleWithError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a NPP dispute with Dispute Reason = 'Incorrect Account Details'
    // And one of these fields Customer Description, Intended Account BSB, Intended Account Name, Intended Account Number is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case nppDispute = new Case(
      RecordTypeId = GetHelpConstants.NPP_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Incorrect Account Details',
      AccountId = acc.Id,
      Description = 'Sample customer description',
      Transaction_Id__c = 'CT5M00000024404234',
      Intended_Account_Name__c = 'AccountName',
      Intended_Account_BSB__c = '252432',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert nppDispute;
      } catch (DmlException e) {
        // THEN an error message should be thrown by DISPUTE_NPP_VR1 validation rule
        System.assertEquals(
          true,
          e.getMessage().contains(DISPUTE_NPP_VR1_ERROR),
          'Error messages should match.'
        );
      }
    }
    System.assertEquals(
      1,
      [SELECT Id FROM Case].size(),
      'NPP dispute should not be created.'
    );
    Test.stopTest();
  }

  // Test DISPUTE_NPP_VR1 validation rule without error
  @isTest
  static void testDisputeNPPV1RuleWithoutError() {
    // Delete the case created in @TestSetup
    Case existingDisputeCase = (Case) [SELECT Id FROM Case];
    delete existingDisputeCase;
    // GIVEN a NPP dispute with Dispute Reason = 'Incorrect Account Details'
    // And NONE of these fields Customer Description, Intended Account BSB, Intended Account Name, Intended Account Number is missing
    User usr = TestUtil.getUserByFirstName('CoachTest');
    Account acc = (Account) [SELECT Id FROM Account LIMIT 1];
    Case nppDispute = new Case(
      RecordTypeId = GetHelpConstants.NPP_DISPUTE_RT_ID,
      Dispute_Reason__c = 'Incorrect Account Details',
      AccountId = acc.Id,
      Description = 'Sample customer description',
      Transaction_Id__c = 'CT5M00000024404234',
      Intended_Account_Name__c = 'AccountName',
      Intended_Account_BSB__c = '252432',
      Intended_Account_Number__c = '4808237410',
      Transaction_UUID__c = '4313ds-51d2-4ve2-ba7e-0b339p157da1'
    );
    // WHEN the case is inserted
    Test.startTest();
    System.runAs(usr) {
      try {
        insert nppDispute;
      } catch (DmlException e) {
        // THEN NO error message should be thrown by DISPUTE_NPP_VR1 validation rule
        System.assertEquals(null, e, 'Error messageshould be null.');
      }
    }
    System.assertEquals(
      1,
      [SELECT Id FROM Case].size(),
      'NPP dispute should be created.'
    );
    Test.stopTest();
  }
}
