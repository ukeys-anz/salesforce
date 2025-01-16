/**
 * @author Alan Hillgemann
 * @since June 2024
 * @description Test class for {@link UserProvisioningAfterActions}
 */
@isTest
private class UserProvisioningAfterActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userRepoMock = Lib_MockProvider.forType(
      UserProvisioningActionsRepository.class
    );
  }
  private static Id anzProfile = CommonUtil.getProfileByName(
      'ANZ Standard User'
    )
    .Id;
  private static Id anzxProfile = CommonUtil.getProfileByName(
      'ANZx Standard User'
    )
    .Id;

  @isTest
  static void testLogEntryWhenUserManuallyCreated() {
    User nonSailPointUser = TestUtil.createTestUserWithProfile(
      'ANZx Standard User'
    );
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Username = 'new.user@anzx.com';
    newUsers.add(newUser);
    Test.startTest();
    System.runAs(nonSailPointUser) {
      UserProvisioningAfterActions.logManualUserProvisioning(newUsers);
    }
    Test.stopTest();
    String expectedLogMessage =
      'User ' +
      newUser.Username +
      ' manually created by ' +
      nonSailPointUser.Username;
    List<LogEntry__c> logEntries = [
      SELECT LogMessage__c, Severity__c
      FROM LogEntry__c
      WHERE LogMessage__c LIKE :expectedLogMessage
    ];
    Assert.areEqual(
      1,
      logEntries.size(),
      'Log entry should be created when the user is manually created'
    );
    Assert.areEqual(
      Logger.Severity.CRITICAL.name(),
      logEntries[0].Severity__c,
      'Log entry severity should be critical'
    );
  }

  @isTest
  static void testNoLogEntryWhenUserNotManuallyCreated() {
    User sailPointUser = TestUtil.createTestUserWithProfile(
      'Minimum Access - External Apps'
    );
    sailPointUser.Username = 'sailpoint.user@anzx.com.unittest';
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Username = 'new.user@anzx.com';
    newUsers.add(newUser);
    Test.startTest();
    System.runAs(sailPointUser) {
      UserProvisioningAfterActions.logManualUserProvisioning(newUsers);
    }
    Test.stopTest();
    String unexpectedLogMessage =
      'User ' +
      newUser.Username +
      ' manually created by ' +
      sailPointUser.Username;
    List<LogEntry__c> logEntries = [
      SELECT LogMessage__c
      FROM LogEntry__c
      WHERE LogMessage__c LIKE :unexpectedLogMessage
    ];
    Assert.areEqual(
      0,
      logEntries.size(),
      'Log entry should not be created when the user is not manually created'
    );
  }
  @isTest
  static void testaddUsertoChatterGroup() {
    CollaborationGroup collGroup = new CollaborationGroup();
    collGroup.id = Lib_FakeIdGenerator.getMockId(
      CollaborationGroup.SObjectType
    );
    collGroup.Name = System.Label.CMOS_Chatter_Group_Name;
    collGroup.CollaborationType = 'Private';
    registerMocks();
    userRepoMock.mock(
      'queryChatterGroup',
      new List<CollaborationGroup>{ collGroup }
    );
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Id = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    newUser.FirstName = 'Test';
    newUser.LastName = 'User';
    newUser.isActive = true;
    newUser.ProfileId = anzProfile;
    newUsers.add(newUser);
    user oldUser = new User();
    oldUser.Id = newUser.Id;
    oldUser.ProfileId = anzxProfile;
    map<Id, User> oldMap = new Map<Id, User>();
    oldMap.put(oldUser.Id, oldUser);
    Test.startTest();
    UserProvisioningAfterActions.addOrRemoveUsertoChatterGroup(
      newUsers,
      oldMap
    );
    Test.stopTest();
    List<CollaborationGroupMember> collaborationGroupList = (List<CollaborationGroupMember>) dmlRepoMock.getHistory(
        'insertRecords'
      )
      .getParam('records');
    System.assertEquals(
      1,
      collaborationGroupList.size(),
      'One Group Member should be updated'
    );
  }
  @isTest
  static void testRemoveUsertoChatterGroup() {
    CollaborationGroup collGroup = new CollaborationGroup();
    collGroup.id = Lib_FakeIdGenerator.getMockId(
      CollaborationGroup.SObjectType
    );
    collGroup.Name = System.Label.CMOS_Chatter_Group_Name;
    collGroup.CollaborationType = 'Private';
    registerMocks();
    userRepoMock.mock(
      'queryChatterGroup',
      new List<CollaborationGroup>{ collGroup }
    );
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Id = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    newUser.FirstName = 'Test';
    newUser.LastName = 'User';
    newUser.isActive = true;
    newUser.ProfileId = anzxProfile;
    newUsers.add(newUser);
    user oldUser = new User();
    oldUser.Id = newUser.Id;
    oldUser.ProfileId = anzProfile;
    map<Id, User> oldMap = new Map<Id, User>();
    oldMap.put(oldUser.Id, oldUser);
    CollaborationGroupMember collmember = new CollaborationGroupMember();
    collmember.Id = Lib_FakeIdGenerator.getMockId(
      CollaborationGroupMember.SObjectType
    );
    userRepoMock.mock(
      'queryChatterGroupUser',
      new List<CollaborationGroupMember>{ collmember }
    );
    Test.startTest();
    UserProvisioningAfterActions.addOrRemoveUsertoChatterGroup(
      newUsers,
      oldMap
    );
    Test.stopTest();
    List<CollaborationGroupMember> collaborationGroupList = (List<CollaborationGroupMember>) dmlRepoMock.getHistory(
        'deleteRecords'
      )
      .getParam('records');
    System.assertEquals(
      1,
      collaborationGroupList.size(),
      'One Group Member should be removed'
    );
  }
  @isTest
  static void testCheckValidUser() {
    User newUser = new User();
    newUser.Id = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    newUser.isActive = true;
    newUser.ProfileId = anzProfile;
    Boolean isValid = UserProvisioningAfterActions.checkforValidUserProfile(
      newUser
    );
    System.assertEquals(true, isValid, 'User Should be valid');
  }
}
