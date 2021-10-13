/**
 * @description Test class to cover tests for {@link IDRCaseChangeEventActions}
 * @author Olivier Saier
 * @since 06/2021
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
public with sharing class IDRCaseChangeEventActionsTest {
  @testSetup
  static void makeData() {
    // Insert User as current user to avoid MIXED_DML_OPERATION error
    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      //create banker
      Profile anzProfile = [
        SELECT Id
        FROM Profile
        WHERE Name = 'ANZ Standard User'
        LIMIT 1
      ];
      UserRole bankerRole = [
        SELECT Id
        FROM UserRole
        WHERE Name = 'Banker'
        LIMIT 1
      ];
      User idrUser = (User) FakerFactory.make(new FakerUserFactory());
      idrUser.FirstName = 'IDRL3';
      idrUser.ProfileId = anzProfile.Id;
      idrUser.UserRoleId = bankerRole.Id;
      insert idrUser;
      List<PermissionSet> idrPsetList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN ('IDR_User', 'IDR_User_Level_3')
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

      //create crp user
      UserRole crRole = [
        SELECT Id
        FROM UserRole
        WHERE Name = 'Customer Resolution'
        LIMIT 1
      ];
      User idrUser1 = (User) FakerFactory.make(new FakerUserFactory());
      idrUser1.FirstName = 'IDRL1';
      idrUser1.ProfileId = anzProfile.Id;
      idrUser1.UserRoleId = crRole.Id;
      insert idrUser1;
      idrPsetList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN ('IDR_User', 'IDR_User_Level_1')
      ];
      idrPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : idrPsetList) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = idrUser1.id,
          PermissionSetId = ps.Id
        );
        idrPsaList.add(psa);
      }
      insert idrPsaList;
    }

    //create cases
    User level3User = [SELECT Id FROM User WHERE FirstName = 'IDRL3' LIMIT 1];
    System.runAs(level3User) {
      Test.enableChangeDataCapture();
      Case[] cases = new List<Case>();
      for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
        cases.add(
          new case(
            RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
            IDR_Restriction_Level__c = 'Restricted Case',
            Status = 'Escalated',
            IDR_Escalated_to__c = '1',
            IDR_Escalation_Reason__c = '1'
          )
        );
        cases.add(
          new case(
            RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
            IDR_Restriction_Level__c = 'No Restriction'
          )
        );
      }
      insert cases;
      Test.getEventBus().deliver();
    }
  }

  @isTest
  public static void testInsertAsRestricted() {
    //GIVEN cases inserted with restricted level
    Case c = [
      SELECT IDR_Is_Restricted__c
      FROM Case
      WHERE IDR_Restriction_Level__c = 'Restricted Case'
      LIMIT 1
    ];

    //THEN They're restricted
    System.assertEquals(
      true,
      c.IDR_Is_Restricted__c,
      'Case should be restricted'
    );
  }

  @istest
  public static void testUpdateToRestricted() {
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with not restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE IDR_Restriction_Level__c = 'No Restriction'
    ];

    //WHEN a banker updates level to restricted
    User level3User = [SELECT Id FROM User WHERE FirstName = 'IDRL3' LIMIT 1];
    System.runAs(level3User) {
      for (Case c : cases) {
        c.Status = 'Escalated';
        c.IDR_Escalated_to__c = '1';
        c.IDR_Escalation_Reason__c = '1';
        c.IDR_Restriction_Level__c = 'Restricted Case';
      }
      update cases;
    }
    Test.getEventBus().deliver();

    //THEN They're restricted
    cases = [SELECT id FROM Case WHERE IDR_Is_Restricted__c = FALSE];
    System.assertEquals(0, cases.size(), 'All cases should be restricted');
  }

  @istest
  public static void testUpdateToNotRestricted() {
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE IDR_Restriction_Level__c = 'Restricted Case'
    ];

    //WHEN I update level to not restricted
    for (Case c : cases) {
      c.IDR_Restriction_Level__c = 'No Restriction';
    }
    update cases;
    Test.getEventBus().deliver();

    //THEN They're not restricted
    cases = [SELECT id FROM Case WHERE IDR_Is_Restricted__c = TRUE];
    System.assertEquals(0, cases.size(), 'All cases should be not restricted');
  }
}
