/**
 * @author Tan Phan
 * @since  07/2022
 * @group CCRM (Commercial CRM)
 * @description Test class for {@link CCRMRegionSharingUtil}
 */
@isTest
private class CCRMRegionSharingUtilTest {
  static final Integer TEST_BULK_SIZE = Integer.valueOf(Label.Test_Bulk_Size);
  @TestSetup
  static void makeData() {
    CCRMTestDataFactory.createCCRMBaseUser();
    CCRMTestDataFactory.createAdminUser();

    createTestGroups();
    createTestUsers();
  }

  @IsTest
  static void testAddUserToExistingRegion() {
    //GIVEN ccrmUser
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //WHEN added to existing Region
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
      }
      CCRMRegionSharingUtil.addUsersToRegion(users);
    }
    Test.stopTest();

    //THEN group member records are created
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM GroupMember
        WHERE UserOrGroupId = :users AND GroupId = :groups
      ],
      'Users should be added to their respective region public group'
    );
  }

  @IsTest
  static void testRemoveUserFromRegion() {
    //GIVEN users that are member of various region public groups
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<GroupMember> members = new List<GroupMember>();
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
      members.add(
        new GroupMember(GroupId = groups[i].Id, UserOrGroupId = users[i].Id)
      );
    }
    insert members;

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //WHEN removed from a region
      CCRMRegionSharingUtil.removeUsersFromRegion(users);
    }
    Test.stopTest();

    //THEN no group member record remains when removed from existing region
    System.assertEquals(
      0,
      [SELECT COUNT() FROM GroupMember WHERE Id IN :members],
      'Users should be removed from their respective region public group'
    );
  }

  @IsTest
  static void testAddUserToNewRegion() {
    bypassUserUpdateTrigger();
    //GIVEN users with new area codes (that don't have matched region public group yet)
    List<User> users = getTestUsers();
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c =
        'NewAreaCode ' + String.valueOf(i).leftPad(6, '0');
    }
    update users;

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //WHEN added to new region
      CCRMRegionSharingUtil.addUsersToRegion(users);
    }
    Test.stopTest();

    //THEN
    //new public groups should be created
    List<Group> newGroups = [
      SELECT Id
      FROM Group
      WHERE DeveloperName LIKE 'Region_NewAreaCode%'
    ];
    System.assertEquals(
      TEST_BULK_SIZE,
      newGroups.size(),
      'New public groups should be created based on the new area code values'
    );

    //AND a group member record is created
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM GroupMember
        WHERE UserOrGroupId IN :users AND GroupId IN :newGroups
      ],
      'Users should be added to new region public groups'
    );
  }

  @IsTest
  static void testAddLeadToExistingRegion() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<Lead> leads;

    //set owner regions (existing region public groups)
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
    }

    System.runAs(ccrmUser) {
      //GIVEN lead records
      leads = CCRMTestDataFactory.createLeadRecords(TEST_BULK_SIZE, ccrmUser);
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        leads[i].OwnerId = users[i].Id;
      }

      Test.startTest();
      //WHEN shared to an existing region
      CCRMRegionSharingUtil.addRecordsToRegion(
        Lead.getSObjectType(),
        CCRMRegionSharingUtil.groupRecordsByOwnerRegion(leads, users)
      );
      Test.stopTest();
    }

    //THEN share records are created corresponding to the lead records
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM LeadShare
        WHERE
          LeadId IN :leads
          AND RowCause = 'Manual'
          AND LeadAccessLevel = 'Edit'
          AND UserOrGroupId = :groups
      ],
      'Leads should be shared to their owner region public group'
    );
  }

  @IsTest
  static void testAddLeadToNewRegion() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    List<User> users = getTestUsers();
    List<Lead> leads;

    bypassUserUpdateTrigger();
    //set owner regions (region public groups not exist yet)
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c =
        'NewAreaCode ' + String.valueOf(i).leftPad(6, '0');
    }
    update users;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //GIVEN lead records
      leads = CCRMTestDataFactory.createLeadRecords(TEST_BULK_SIZE, ccrmUser);
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        leads[i].OwnerId = users[i].Id;
      }

      Test.startTest();
      //WHEN shared to an existing region
      CCRMRegionSharingUtil.addRecordsToRegion(
        Lead.getSObjectType(),
        CCRMRegionSharingUtil.groupRecordsByOwnerRegion(leads, users)
      );
      Test.stopTest();
    }

    //THEN
    //new public groups should be created
    List<Group> newGroups = [
      SELECT Id
      FROM Group
      WHERE DeveloperName LIKE 'Region_NewAreaCode%'
    ];
    System.assertEquals(
      TEST_BULK_SIZE,
      newGroups.size(),
      'New public groups should be created based on the new area code values'
    );

    //AND group members record are created for the owners
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM GroupMember
        WHERE UserOrGroupId IN :users AND GroupId IN :newGroups
      ],
      'User should be added to new public group Region_NewAreaCode'
    );

    //AND share records are created corresponding to the lead records
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM LeadShare
        WHERE
          LeadId IN :leads
          AND RowCause = 'Manual'
          AND LeadAccessLevel = 'Edit'
          AND UserOrGroupId IN :newGroups
      ],
      'Leads should be shared to their owner region public group'
    );
  }

  @IsTest
  static void testRemoveLeadFromRegion() {
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<LeadShare> leadShares = new List<LeadShare>();
    List<Lead> leads;

    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //GIVEN a lead record is shared to a region public group
      leads = CCRMTestDataFactory.createLeadRecords(TEST_BULK_SIZE, ccrmUser);
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
        leads[i].OwnerId = users[i].Id;
        leadShares.add(
          new LeadShare(
            LeadId = leads[i].Id,
            LeadAccessLevel = 'Edit',
            RowCause = 'Manual',
            UserOrGroupId = groups[i].Id
          )
        );
      }
      insert leadShares;
    }

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getAdminUser()) {
      //WHEN removed from the region
      CCRMRegionSharingUtil.removeRecordsFromRegion(
        Lead.getSObjectType(),
        CCRMRegionSharingUtil.groupRecordsByOwnerRegion(leads, users)
      );
    }
    Test.stopTest();

    //THEN the share record will be deleted
    System.assertEquals(
      0,
      [SELECT COUNT() FROM LeadShare WHERE Id IN :leadShares],
      'LeadShare record should be deleted'
    );
  }

  @isTest
  static void testUpdateUserRegion() {
    User adminUser = CCRMTestDataFactory.getAdminUser();
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<Lead> leads;
    List<Opportunity> opps;
    List<LeadShare> leadShares = new List<LeadShare>();
    List<OpportunityShare> oppShares = new List<OpportunityShare>();
    List<GroupMember> groupMembers = new List<GroupMember>();
    List<User> newUsers = users.deepClone(true, true, true);

    //GIVEN leads and opportunity records shared to owners group
    System.runAs(adminUser) {
      leads = CCRMTestDataFactory.createLeadRecords(
        TEST_BULK_SIZE,
        adminUser,
        false
      );
      opps = CCRMTestDataFactory.createOpportunityRecords(
        TEST_BULK_SIZE,
        adminUser,
        false
      );
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        leads[i].OwnerId = users[i].Id;
        opps[i].OwnerId = users[i].Id;
      }
      insert leads;
      insert opps;

      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        leadShares.add(
          new LeadShare(
            LeadId = leads[i].Id,
            LeadAccessLevel = 'Edit',
            RowCause = 'Manual',
            UserOrGroupId = groups[i].Id
          )
        );
        oppShares.add(
          new OpportunityShare(
            OpportunityId = opps[i].Id,
            OpportunityAccessLevel = 'Edit',
            RowCause = 'Manual',
            UserOrGroupId = groups[i].Id
          )
        );
      }
      insert leadShares;
      insert oppShares;
    }
    System.runAs(adminUser) {
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
        newUsers[i].Area_Code__c =
          'NewAreaCode ' + String.valueOf(i).leftPad(6, '0');
        groupMembers.add(
          new GroupMember(GroupId = groups[i].Id, UserOrGroupId = users[i].Id)
        );
      }
      insert groupMembers;
      bypassUserUpdateTrigger();
      update newUsers;
    }

    //WHEN users are moved from one region to another
    Test.startTest();
    System.runAs(adminUser) {
      CCRMRegionSharingUtil.updateUserRegion(
        newUsers,
        new Map<Id, User>(users)
      );
    }
    Test.stopTest();

    //THEN those users are removed as member of the previous regions, along with their active leads/opps records
    System.assertEquals(
      0,
      [SELECT COUNT() FROM LeadShare WHERE Id IN :leadShares],
      'LeadShare records of old region should be deleted when user move to new region'
    );
    System.assertEquals(
      0,
      [SELECT COUNT() FROM OpportunityShare WHERE Id IN :oppShares],
      'OpportunityShare records of old region should be deleted when user move to new region'
    );
    System.assertEquals(
      0,
      [SELECT COUNT() FROM GroupMember WHERE Id IN :groupMembers],
      'GroupMemnber records of old region should be deleted when user move to new region'
    );

    //AND those users are added as member of the new regions, along with their active leads/opps records
    List<Group> newGroups = [
      SELECT Id
      FROM Group
      WHERE DeveloperName LIKE 'Region_NewAreaCode%'
    ];
    System.assertEquals(
      TEST_BULK_SIZE,
      newGroups.size(),
      'New groups should be created when no matching groups available for given area codes'
    );
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM LeadShare
        WHERE UserOrGroupId IN :newGroups AND LeadId IN :leads
      ],
      'LeadShare records of new region should be created when user move to new region'
    );
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM OpportunityShare
        WHERE UserOrGroupId IN :newGroups AND OpportunityId IN :opps
      ],
      'OpportunityShare records of new region should be deleted when user move to new region'
    );
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM GroupMember
        WHERE GroupId IN :newGroups AND UserOrGroupId IN :users
      ],
      'GroupMember records of new region should be added when user move to new region'
    );
  }

  static void bypassUserUpdateTrigger() {
    bypassUserUpdateTrigger(true);
  }

  static void bypassUserUpdateTrigger(Boolean asAdmin) {
    Salesforce_Bypass_Trigger_Actions__c bypassActions = Salesforce_Bypass_Trigger_Actions__c.getOrgDefaults();
    bypassActions.Object_API_Name__c = 'User';
    bypassActions.Bypass_Update__c = true;
    //disable User update trigger to isolate unit test flow
    if (asAdmin) {
      System.runAs(CCRMTestDataFactory.getAdminUser()) {
        upsert bypassActions;
      }
    } else {
      update bypassActions;
    }
  }

  static void createTestGroups() {
    List<Group> groups = new List<Group>();
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      groups.add(
        new Group(
          Name = 'Region Standard ' + String.valueOf(i).leftPad(6, '0'),
          DeveloperName = 'Region_Standard' + String.valueOf(i).leftPad(6, '0'),
          Type = 'Regular',
          DoesIncludeBosses = false
        )
      );
    }
    insert groups;
  }

  static void createTestUsers() {
    List<User> users = new List<User>();
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      User ccrmBaseUser = (User) FakerFactory.make(new FakerUserFactory());
      ccrmBaseUser.FirstName = 'BaseUser' + String.valueOf(i).leftPad(6, '0');
      ccrmBaseUser.LastName = 'RegionSharingTest';
      ccrmBaseUser.UserRoleId = CCRMTestDataFactory.commercialBankerRole.Id;
      ccrmBaseUser.ProfileId = CCRMTestDataFactory.anzStandardProfileId;
      ccrmBaseUser.IsActive = true;
      users.add(ccrmBaseUser);
    }
    insert users;
  }

  static List<Group> getTestGroups() {
    return [
      SELECT Id, Name, DeveloperName
      FROM Group
      WHERE DeveloperName LIKE 'Region_Standard%'
      ORDER BY DeveloperName
    ];
  }

  static List<User> getTestUsers() {
    return [
      SELECT Id, FirstName, LastName, Area_Code__c, IsActive
      FROM User
      WHERE LastName = 'RegionSharingTest'
      ORDER BY FirstName
    ];
  }
}
