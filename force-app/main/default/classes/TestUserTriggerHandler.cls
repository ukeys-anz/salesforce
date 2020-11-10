/**
 * @author Boobalakrishnan Duraisamy
 * @since 02/2020
 * @description  TestUserTriggerHandler is the a class for UserProvisioningService and UserTriggerHandler Class.
 */
@isTest
public class TestUserTriggerHandler {
  static List<User> testUsers = new List<User>();

  /**
   * @description This method is used to test OnBeforeInsert & OnAfterInsert functionalities from user trigger.
   */

  @isTest
  static void testUserInsert() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];

    User_Provisioning_Request__c upr = new User_Provisioning_Request__c();
    upr.Requestor_UUID__c = 'Test1';
    upr.Type__c = 'Grant';

    insert upr;

    for (Integer i = 0; i < 3; i++) {
      testUsers.add((User) FakerFactory.make(new FakerUserFactory()));
    }

    for (User usr : testUsers) {
      usr.ProfileId = p.Id;
      usr.Business_Function__c = 'Test Business Function ';
      usr.Business_Role__c = 'Business Role';
    }

    testUsers[2].FederationIdentifier = upr.Requestor_UUID__c;

    Test.startTest();

    insert testUsers;

    Test.stopTest();

    User insertedUser = [
      SELECT Id, ProfileId, UserRoleId
      FROM User
      WHERE Id = :testUsers[0].Id
      LIMIT 1
    ];

    List<User_Provisioning_Setting__mdt> testMetaData = [
      SELECT
        Id,
        Label,
        DeveloperName,
        Profile_Name__c,
        Role_Name__c,
        Permission_Sets__c,
        Permission_Set_Licences__c
      FROM User_Provisioning_Setting__mdt
      WHERE DeveloperName = 'Test_Business_Function_Business_Role'
      LIMIT 1
    ];

    List<Profile> assignedProfileId = new List<Profile>();
    List<UserRole> assignedRoleId = new List<UserRole>();
    if (!testMetaData.isEmpty()) {
      assignedProfileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :testMetaData[0].Profile_Name__c
        LIMIT 1
      ];
      assignedRoleId = [
        SELECT Id
        FROM UserRole
        WHERE DeveloperName = :testMetaData[0].Role_Name__c
        LIMIT 1
      ];
    }

    List<PermissionSetLicenseAssign> pslAssignList = [
      SELECT Id
      FROM PermissionSetLicenseAssign
    ];

    System.assertNotEquals(0, pslAssignList.size());

    //Check if Profile and Role are assigned correctly as defined from Custom Metadata
    if (!assignedProfileId.isEmpty() && !assignedRoleId.isEmpty()) {
      System.assertEquals(assignedProfileId[0].Id, insertedUser.ProfileId);
      System.assertEquals(assignedRoleId[0].Id, insertedUser.UserRoleId);
    }
  }

  /**
   * @description This method is used to test OnBeforeUpdate & OnAfterUpdate functionalities from user trigger.
   */

  @isTest
  static void testUserUpdate() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    for (Integer i = 0; i < 3; i++) {
      testUsers.add((User) FakerFactory.make(new FakerUserFactory()));
    }
    for (User usr : testUsers) {
      usr.ProfileId = p.Id;
    }

    insert testUsers;

    //update user records with different business function to test update trigger
    for (User testUser : testUsers) {
      testUser.Business_Function__c = 'Test Business Function';
      testUser.Business_Role__c = 'Business Role';
    }

    Test.startTest();

    update testUsers;

    Test.stopTest();

    List<User_Provisioning_Setting__mdt> testMetaData = [
      SELECT
        Id,
        Label,
        DeveloperName,
        Profile_Name__c,
        Role_Name__c,
        Permission_Sets__c
      FROM User_Provisioning_Setting__mdt
      WHERE DeveloperName = 'Test_Business_Function_Business_Role'
      LIMIT 1
    ];

    List<PermissionSet> assignedPsetId = new List<PermissionSet>();
    if (!testMetadata.isEmpty()) {
      assignedPsetId = [
        SELECT Id
        FROM PermissionSet
        WHERE
          Name IN :testMetaData[0]
            .Permission_Sets__c.deleteWhitespace()
            .split(';')
        LIMIT 1
      ];
    }

    List<PermissionSetAssignment> testAssignment = new List<PermissionSetAssignment>();
    if (!assignedPsetId.isEmpty()) {
      testAssignment = [
        SELECT Id, PermissionSetId
        FROM PermissionSetAssignment
        WHERE
          AssigneeId = :testusers[0].Id
          AND PermissionSetId = :assignedPsetId[0].Id
        LIMIT 1
      ];
    }
    //Check if Permission Set is assigned correctly as defined from Custom Metadata
    if (!testAssignment.isEmpty()) {
      System.assertEquals(
        assignedPsetId[0].Id,
        testAssignment[0].PermissionSetId
      );
    }
  }

  /**
   * @description This method is used to test whether the change in Business Function and Business Role is revoking the user permissions.
   */

  @isTest
  static void testRevoke() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    User testUser = (User) FakerFactory.make(new FakerUserFactory());
    testUser.ProfileId = p.Id;
    testUser.Business_Function__c = 'Test Business Function';
    testUser.Business_Role__c = 'Business Role';

    insert testUser;

    Test.startTest();

    //test revoke functionality
    testUser.Business_Function__c = 'New Business Function';
    testUser.Business_Role__c = 'New Business Role';
    update testUser;

    Test.stopTest();

    List<GroupMember> testAssignment = [
      SELECT Id
      FROM GroupMember
      WHERE UserOrGroupId = :testuser.Id
    ];

    System.assertEquals(0, testAssignment.size());
  }
}
