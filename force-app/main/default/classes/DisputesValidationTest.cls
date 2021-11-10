@isTest
public with sharing class DisputesValidationTest {
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
        'Quality_Assessment_Read_Only'
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
      Id cardRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Card_Dispute')
        .getRecordTypeId();
      // Create test data for account case
      Account acc = new Account(
        Name = 'TestAccount',
        Display_Name__c = 'TestAccount',
        OCV_ID__c = 'OCV78786678',
        ANZx_Customer__c = true
      );
      insert acc;
      insert new Case(
        RecordTypeID = cardRTId,
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
}
