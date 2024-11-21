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
      Map<String, String> profileMap = new Map<String, String>();
      //create CCRM banker
      for (Profile iterator : [
        SELECT Id, Name
        FROM Profile
        WHERE Name = 'ANZ Standard User' OR Name = 'ANZ CCRM Standard User'
      ]) {
        profileMap.put(iterator.Name, iterator.Id);
      }
      List<UserRole> userRoleList = [
        SELECT Id, Name
        FROM UserRole
        WHERE
          Name = 'Banker'
          OR Name = 'Customer Resolution'
          OR Name = :Label.ML_ANZ_Role
          OR Name = 'SME Assistant Manager'
      ];

      Map<String, UserRole> mapNameToRole = new Map<String, UserRole>();
      for (UserRole usrRole : userRoleList) {
        mapNameToRole.put(usrRole.Name, usrRole);
      }

      List<User> userToInsert = new List<User>();

      User idrUser = (User) FakerFactory.make(new FakerUserFactory());
      idrUser.FirstName = 'IDRL3';
      idrUser.ProfileId = profileMap.get('ANZ Standard User');
      idrUser.UserRoleId = mapNameToRole.get('Banker').Id;
      userToInsert.add(idrUser);

      //create crp user
      User idrUser1 = (User) FakerFactory.make(new FakerUserFactory());
      idrUser1.FirstName = 'IDRL1';
      idrUser1.ProfileId = profileMap.get('ANZ Standard User');
      idrUser1.UserRoleId = mapNameToRole.get('Customer Resolution').Id;
      userToInsert.add(idrUser1);

      User idrUserCCRM = (User) FakerFactory.make(new FakerUserFactory());
      idrUserCCRM.ProfileId = profileMap.get('ANZ CCRM Standard User');
      idrUserCCRM.Business_Function__c = 'CMOS';
      idrUserCCRM.Business_Role__c = 'Customer Resolution';
      idrUserCCRM.FirstName = 'IDRL3CCRM';
      idrUserCCRM.IsActive = true;
      idrUserCCRM.UserRoleId = mapNameToRole.get('SME Assistant Manager').Id;
      userToInsert.add(idrUserCCRM);

      //CC-5574
      User mlUser = (User) FakerFactory.make(new FakerUserFactory());
      mlUser.ProfileId = MLCRMTestDataFactory.anzStandardProfileId;
      mlUser.FirstName = 'MLUser1';
      mlUser.IsActive = true;
      mlUser.UserRoleId = mapNameToRole.get(Label.ML_ANZ_Role).Id;
      userToInsert.add(mlUser);

      insert userToInsert;

      Map<String, User> mapUserFirstNameToUser = new Map<String, User>();
      for (User usr : [
        SELECT
          Id,
          FirstName,
          ProfileId,
          UserRoleId,
          Business_Function__c,
          IsActive,
          Business_Role__c
        FROM User
        WHERE
          FirstName = 'IDRL3'
          OR FirstName = 'IDRL1'
          OR FirstName = 'IDRL3CCRM'
          OR FirstName = 'MLUser1'
      ]) {
        mapUserFirstNameToUser.put(usr.FirstName, usr);
      }

      List<PermissionSet> idrPsetList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN ('IDR_User', 'IDR_User_Level_3')
      ];
      List<PermissionSetAssignment> idrPsaList = new List<PermissionSetAssignment>();
      for (PermissionSet ps : idrPsetList) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = mapUserFirstNameToUser.get('IDRL3').Id,
          PermissionSetId = ps.Id
        );
        idrPsaList.add(psa);
      }

      idrPsetList = [
        SELECT Id
        FROM PermissionSet
        WHERE Name IN ('IDR_User', 'IDR_User_Level_1')
      ];
      for (PermissionSet ps : idrPsetList) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = mapUserFirstNameToUser.get('IDRL1').Id,
          PermissionSetId = ps.Id
        );
        idrPsaList.add(psa);
      }

      //Assign Permission set group as coach
      List<PermissionSetGroup> permissionSetGroupSetCMOS = new List<PermissionSetGroup>(
        [
          SELECT Id
          FROM PermissionSetGroup
          WHERE DeveloperName = 'CCRM_Banker' OR DeveloperName = 'IDR_Level_3'
        ]
      );

      for (PermissionSetGroup psIterator : permissionSetGroupSetCMOS) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = mapUserFirstNameToUser.get('IDRL3CCRM').Id,
          PermissionSetGroupId = psIterator.Id
        );
        idrPsaList.add(psa);
      }

      List<String> idrPsetsGroupML = new List<String>{
        'MLCRM_Field_Team',
        'IDR_Level_2'
      };
      List<PermissionSetGroup> idrPsetGroupML = [
        SELECT Id
        FROM PermissionSetGroup
        WHERE DeveloperName IN :idrPsetsGroupML
      ];

      for (PermissionSetGroup psGroup : idrPsetGroupML) {
        PermissionSetAssignment psa = new PermissionSetAssignment(
          AssigneeId = mapUserFirstNameToUser.get('MLUser1').Id,
          PermissionSetGroupId = psGroup.Id
        );
        idrPsaList.add(psa);
      }

      List<String> idrPsetsGroupList = new List<String>{
        'MLCRM_Field_Team',
        'IDR_Level_2',
        'CCRM_Banker',
        'IDR_Level_3'
      };
      List<PermissionSetGroup> idrPsetGroupQuery = [
        SELECT Id, Status
        FROM PermissionSetGroup
        WHERE DeveloperName IN :idrPsetsGroupList
      ];
      for (PermissionSetGroup psg : idrPsetGroupQuery) {
        if (psg.Status != 'Updated') {
          Test.calculatePermissionSetGroup(psg.Id);
        }
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

    //create cases as CCRM User
    User level3CCRMUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRL3CCRM'
      LIMIT 1
    ];
    System.runAs(level3CCRMUser) {
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
      WHERE
        IDR_Restriction_Level__c = 'No Restriction'
        AND CreatedBy.FirstName = 'IDRL3'
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
      Test.startTest();
      update cases;
      Test.stopTest();
    }
    Test.getEventBus().deliver();

    //THEN They're restricted
    cases = [
      SELECT id
      FROM Case
      WHERE IDR_Is_Restricted__c = FALSE AND CreatedBy.FirstName = 'IDRL3'
    ];
    System.assertEquals(0, cases.size(), 'All cases should be restricted');
  }

  @istest
  public static void testUpdateToNotRestricted() {
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE
        IDR_Restriction_Level__c = 'Restricted Case'
        AND CreatedBy.FirstName = 'IDRL3'
    ];

    //WHEN I update level to not restricted
    for (Case c : cases) {
      c.IDR_Restriction_Level__c = 'No Restriction';
    }
    Test.startTest();
    update cases;
    Test.stopTest();
    Test.getEventBus().deliver();

    //THEN They're not restricted
    cases = [
      SELECT id
      FROM Case
      WHERE IDR_Is_Restricted__c = TRUE AND CreatedBy.FirstName = 'IDRL3'
    ];
    System.assertEquals(0, cases.size(), 'All cases should be not restricted');
  }

  @istest
  public static void testUpdateToRestrictedForCCRM() {
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with not restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE
        IDR_Restriction_Level__c = 'No Restriction'
        AND CreatedBy.FirstName = 'IDRL3CCRM'
    ];

    //WHEN a banker updates level to restricted
    User level3User = [
      SELECT Id
      FROM User
      WHERE FirstName = 'IDRL3CCRM'
      LIMIT 1
    ];
    System.runAs(level3User) {
      for (Case c : cases) {
        c.Status = 'Escalated';
        c.IDR_Escalated_to__c = '1';
        c.IDR_Escalation_Reason__c = '1';
        c.IDR_Restriction_Level__c = 'Restricted Case';
      }
      Test.startTest();
      update cases;
      Test.stopTest();
    }
    Test.getEventBus().deliver();

    //THEN They're restricted
    cases = [
      SELECT id
      FROM Case
      WHERE IDR_Is_Restricted__c = FALSE AND CreatedBy.FirstName = 'IDRL3CCRM'
    ];
    System.assertEquals(0, cases.size(), 'All cases should be restricted');
  }

  @istest
  public static void testUpdateToNotRestrictedForCCRM() {
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE
        IDR_Restriction_Level__c = 'Restricted Case'
        AND CreatedBy.FirstName = 'IDRL3CCRM'
    ];

    //WHEN I update level to not restricted
    for (Case c : cases) {
      c.IDR_Restriction_Level__c = 'No Restriction';
    }
    Test.startTest();
    update cases;
    Test.stopTest();
    Test.getEventBus().deliver();

    //THEN They're not restricted
    cases = [
      SELECT id
      FROM Case
      WHERE IDR_Is_Restricted__c = TRUE AND CreatedBy.FirstName = 'IDRL3CCRM'
    ];
    System.assertEquals(0, cases.size(), 'All cases should be not restricted');
  }

  @istest
  public static void testUpdateToRestrictedML() {
    List<String> idrPsetsGroupML = new List<String>{
      'MLCRM_Field_Team',
      'IDR_Level_2'
    };
    List<PermissionSetGroup> idrPsetGroupML = [
      SELECT Id, Status
      FROM PermissionSetGroup
      WHERE DeveloperName IN :idrPsetsGroupML
    ];
    for (PermissionSetGroup psg : idrPsetGroupML) {
      if (psg.Status != 'Updated') {
        Test.calculatePermissionSetGroup(psg.Id);
      }
    }

    User level3User = [SELECT Id FROM User WHERE FirstName = 'MLUser1' LIMIT 1];
    Test.enableChangeDataCapture();
    //GIVEN cases inserted with not restricted level
    Case[] cases = [
      SELECT IDR_Restriction_Level__c
      FROM Case
      WHERE IDR_Restriction_Level__c = 'No Restriction'
      LIMIT 1
    ];

    Test.startTest();

    User thisUser = new User(Id = UserInfo.getUserId());
    System.runAs(thisUser) {
      cases[0].OwnerId = level3User.Id;
      update cases;
    }

    //WHEN a banker updates level to restricted

    System.runAs(level3User) {
      for (Case c : cases) {
        c.Status = 'Escalated';
        c.IDR_Escalated_to__c = '1';
        c.IDR_Escalation_Reason__c = '1';
        c.IDR_Restriction_Level__c = 'Restricted Case';
      }
      update cases;
      cases = [SELECT id FROM Case WHERE IDR_Is_Restricted__c = FALSE];
      //System.assertEquals(0, cases.size(), 'All cases should be restricted');
    }

    Test.stopTest();
    Test.getEventBus().deliver();
  }
}
