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
    updateSegmentRegion(
      new List<User>{ CCRMTestDataFactory.createCCRMBaseUser() }
    );
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
      //CCRMRegionSharingUtil.addUsersToRegion(users);
      update users;
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
      WHERE DeveloperName LIKE 'BB_NewAreaCode%'
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
    User ccrmUser = CCRMTestDataFactory.createCCRMRelManagerUser();
    updateSegmentRegion(new List<User>{ ccrmUser });
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<Lead> leads;

    //set owner regions (existing region public groups)
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c = 'Standard Area Code';
    }
    update users;

    System.runAs(ccrmUser) {
      //GIVEN lead records
      leads = CCRMTestDataFactory.createLeadRecords(TEST_BULK_SIZE, ccrmUser);
      //WHEN shared to an existing region
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        leads[i].OwnerId = users[i].Id;
      }
      Test.startTest();
      checkRecursive.firstCall = false;
      update leads;
      Test.stopTest();
    }
    System.debug(
      'User group name' +
      [
        SELECT Id, UserOrGroup.Name
        FROM LeadShare
        WHERE
          LeadId IN :leads
          AND RowCause = 'Manual'
          AND LeadAccessLevel = 'Edit'
          AND UserOrGroupId = :groups
      ]
    );
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
  static void testAddOpportunityToExistingRegion() {
    User ccrmUser = CCRMTestDataFactory.createCCRMRelManagerUser();
    updateSegmentRegion(new List<User>{ ccrmUser });
    List<User> users = getTestUsers();
    List<Group> groups = getTestGroups();
    List<Opportunity> opportunityList;

    //set owner regions (existing region public groups)
    for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
      users[i].Area_Code__c = 'Standard Area Code';
    }
    update users;

    System.runAs(ccrmUser) {
      //GIVEN lead records
      opportunityList = CCRMTestDataFactory.createOpportunityRecords(
        TEST_BULK_SIZE,
        ccrmUser,
        true
      );
      //WHEN shared to an existing region
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        opportunityList[i].OwnerId = users[i].Id;
      }
      Test.startTest();
      update opportunityList;
      Test.stopTest();
    }
    //THEN share records are created corresponding to the lead records
    System.assertEquals(
      TEST_BULK_SIZE,
      [
        SELECT COUNT()
        FROM OpportunityShare
        WHERE
          OpportunityId IN :opportunityList
          AND RowCause = 'Manual'
          AND OpportunityAccessLevel = 'Edit'
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
      WHERE DeveloperName LIKE 'BB_NewAreaCode%'
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
        //users[i].Area_Code__c = 'Standard ' + String.valueOf(i).leftPad(6, '0');
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
      CheckRecursive.firstCall = false;
      update leads;
      /*CCRMRegionSharingUtil.removeRecordsFromRegion(
        Lead.getSObjectType(),
        CCRMRegionSharingUtil.groupRecordsByOwnerRegion(leads, users)
      );*/
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
  static void testUpdateUserAreaCode() {
    User adminUser = CCRMTestDataFactory.getAdminUser();
    List<User> users = getTestUsers();
    List<Lead> leads;
    List<Opportunity> opps;
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
    }
    System.runAs(adminUser) {
      for (Integer i = 0; i < TEST_BULK_SIZE; i++) {
        users[i].Area_Code__c =
          'NewAreaCode ' + String.valueOf(i).leftPad(6, '0');
      }
      Test.startTest();
      update users;
      Test.stopTest();
    }
    //AND those users are added as member of the new regions, along with their active leads/opps records
    List<Group> newGroups = [
      SELECT Id
      FROM Group
      WHERE DeveloperName LIKE 'BB_NewAreaCode%'
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
          Name = 'BB Standard 000000' + String.valueOf(i).leftPad(6, '0'),
          DeveloperName = 'BB_Standard000000' +
            String.valueOf(i).leftPad(6, '0'),
          Type = 'Regular',
          DoesIncludeBosses = false
        )
      );
      groups.add(
        new Group(
          Name = 'BB Standard 000001 ' + String.valueOf(i).leftPad(6, '0'),
          DeveloperName = 'BB_Standard000001' +
            String.valueOf(i).leftPad(6, '0'),
          Type = 'Regular',
          DoesIncludeBosses = false
        )
      );
      groups.add(
        new Group(
          Name = 'BB Standard Area Code' + String.valueOf(i).leftPad(6, '0'),
          DeveloperName = 'BB_StandardAreaCode' +
            String.valueOf(i).leftPad(6, '0'),
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
      ccrmBaseUser.UserRoleId = CCRMTestDataFactory.relationshipManager.Id;
      ccrmBaseUser.ProfileId = CCRMTestDataFactory.anzStandardProfileId;
      ccrmBaseUser.Area_Code__c =
        'Standard ' + String.valueOf(i).leftPad(6, '0');
      ccrmBaseUser.Commercial_Segment__c = CCRMConstants.BB_SEGMENT;
      ccrmBaseUser.IsActive = true;
      users.add(ccrmBaseUser);
    }
    insert users;
  }

  static List<Group> getTestGroups() {
    return [
      SELECT Id, Name, DeveloperName
      FROM Group
      WHERE DeveloperName LIKE 'BB_%'
      ORDER BY DeveloperName
    ];
  }

  static List<User> getTestUsers() {
    return [
      SELECT
        Id,
        FirstName,
        LastName,
        Area_Code__c,
        IsActive,
        Commercial_Segment__c
      FROM User
      WHERE LastName = 'RegionSharingTest'
      ORDER BY FirstName
    ];
  }

  static List<User> updateSegmentRegion(List<User> userList) {
    for (User userIterator : userList) {
      userIterator.Commercial_Segment__c = CCRMConstants.BB_SEGMENT;
      userIterator.Area_Code__c = 'Standard Area Code';
    }
    update userList;
    return userList;
  }
}
