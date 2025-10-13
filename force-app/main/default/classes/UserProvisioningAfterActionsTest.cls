/**
 * @author Alan Hillgemann
 * @since June 2024
 * @description Test class for {@link UserProvisioningAfterActions}
 */
@isTest
private class UserProvisioningAfterActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider userProMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    userRepoMock = Lib_MockProvider.forType(
      UserProvisioningActionsRepository.class
    );
    userProMock = Lib_MockProvider.forType(UserProvisioningAfterActions.class);
  }
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
    registerMocks();
    CollaborationGroup collGroup = new CollaborationGroup();
    collGroup.Id = Lib_FakeIdGenerator.getMockId(
      CollaborationGroup.SObjectType
    );
    collGroup.Name = System.Label.CMOS_Chatter_Group_Name;
    collGroup.CollaborationType = 'Private';
    QueryCollaborationGroup.collGroups = new Map<String, CollaborationGroup>{
      collGroup.Name => collGroup
    };
    List<User> newUsers = new List<User>();
    User newUser = new User();
    newUser.Id = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    newUser.FirstName = 'Test';
    newUser.LastName = 'User';
    newUser.isActive = true;
    newUser.ProfileId = UserProvisioningAfterActions.anzProfile;
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
        'doInsert'
      )
      .getParam('records');
    System.assertEquals(
      1,
      collaborationGroupList.size(),
      'One Group Member should be updated'
    );
    System.assertEquals(
      newUser.Id,
      collaborationGroupList[0].MemberId,
      'New User Should be addedd to the List'
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
    QueryCollaborationGroup.collGroups = new Map<String, CollaborationGroup>{
      collGroup.Name => collGroup
    };
    registerMocks();
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
    oldUser.ProfileId = UserProvisioningAfterActions.anzProfile;
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
        'doDelete'
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
    newUser.ProfileId = UserProvisioningAfterActions.anzProfile;
    Boolean isValid = UserProvisioningAfterActions.checkforValidUserProfile(
      newUser
    );
    System.assertEquals(true, isValid, 'User Should be valid');
  }
  /**
   * @description Test when Permission Set License assigment won't happens with no create permissions.
   */
  @isTest
  static void testInsertPermissionSetLicenseAssign() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', true);
    Boolean exceptionThrown = false;
    PermissionSetLicenseAssign obj = new PermissionSetLicenseAssign();
    Test.startTest();
    try {
      UserProvisioningAfterActions.insertPsetLicenseAssign(
        new List<PermissionSetLicenseAssign>{ obj }
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();
    Assert.areEqual(
      true,
      exceptionThrown,
      'Not enough permissions to create PermissionSetLicenseAssign'
    );
  }
  /**
   * @description Test when Permission Set insertion won't  with no create permissions.
   */
  @isTest
  static void testInsertPermissionSetAssignment() {
    Boolean exceptionThrown = false;
    registerMocks();
    userProMock.mock('checkCreatePermissions', true);
    PermissionSetAssignment obj = new PermissionSetAssignment();
    Test.startTest();
    try {
      UserProvisioningAfterActions.insertPsetAssignment(
        new List<PermissionSetAssignment>{ obj }
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();
    Assert.areEqual(
      true,
      exceptionThrown,
      'Not enough permissions to create PermissionSetAssign'
    );
  }
  /**
   * @description Test when GroupMember won't inserting  with no create permission.
   */
  @isTest
  static void testInsertGroupAssignment() {
    Boolean exceptionThrown = false;
    registerMocks();
    userProMock.mock('checkCreatePermissions', true);
    GroupMember obj = new GroupMember();
    Test.startTest();
    try {
      UserProvisioningAfterActions.insertGroupAssignment(
        new List<GroupMember>{ obj }
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();
    Assert.areEqual(
      true,
      exceptionThrown,
      'Not enough permissions to create GroupMember.'
    );
  }
  /**
   * @description Test when PermissionSetAssignment deleting  with no object delete permissions.
   */
  @isTest
  static void testdeletePsetAssignment() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', true);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(false, true, ''))
      }
    );
    PermissionSetAssignment obj = new PermissionSetAssignment();
    Test.startTest();

    UserProvisioningAfterActions.deletePsetAssignment(
      new List<PermissionSetAssignment>{ obj }
    );
    Test.stopTest();

    Assert.isNull(
      dmlRepoMock.getHistory('doDelete'),
      'There should no PermissionSetAssignment deleted'
    );
  }
  /**
   * @description Test when GroupMember deleting  with no object delete permissions.
   */
  @isTest
  static void testDeleteGroupAssignment() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', true);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(false, true, ''))
      }
    );
    GroupMember obj = new GroupMember();
    Test.startTest();

    UserProvisioningAfterActions.deleteGroupAssignment(
      new List<GroupMember>{ obj }
    );
    Test.stopTest();
    Assert.isNull(
      dmlRepoMock.getHistory('doDelete'),
      'There should no group deleted'
    );
  }
  /**
   * @description Test when PermissionSetLicenseAssign inserting  with wrong data to cover exceptions and errors.
   */
  @isTest
  static void testInsertPsetLicenseError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(false, true, ''))
      }
    );
    PermissionSetLicenseAssign obj = new PermissionSetLicenseAssign();
    Test.startTest();
    UserProvisioningAfterActions.insertPsetLicenseAssign(
      new List<PermissionSetLicenseAssign>{ obj }
    );

    Test.stopTest();
    List<PermissionSetLicenseAssign> psetAssignList = (List<PermissionSetLicenseAssign>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      String.valueOf(psetAssignList[0]),
      'PermissionSetLicenseAssign:{}',
      'Error occured while inserting PermissionSetAssignment'
    );
  }
  /**
   * @description Test when PermissionSetAssignment inserting  with wrong data to cover exceptions and errors.
   */
  @isTest
  static void testinsertPsetAssignmentError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(false, true, ''))
      }
    );
    PermissionSetAssignment obj = new PermissionSetAssignment();
    Test.startTest();

    UserProvisioningAfterActions.insertPsetAssignment(
      new List<PermissionSetAssignment>{ obj }
    );

    Test.stopTest();
    List<PermissionSetAssignment> psetList = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      String.valueOf(psetList[0]),
      'PermissionSetAssignment:{}',
      'Error occured while inserting PermissionSetAssignment'
    );
  }
  /**
   * @description Test when GroupMember inserting  with wrong data to cover exceptions and errors.
   */
  @isTest
  static void testinsertGroupAssignmentError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(false, true, ''))
      }
    );
    GroupMember obj = new GroupMember();
    Test.startTest();
    UserProvisioningAfterActions.insertGroupAssignment(
      new List<GroupMember>{ obj }
    );

    Test.stopTest();
    List<GroupMember> groupList = (List<GroupMember>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      String.valueOf(groupList[0]),
      'GroupMember:{}',
      'Error occured while inserting GroupMember'
    );
  }
  /**
   * @description Test when PermissionSetAssignment deleting  with wrong data to cover exceptions and errors.
   */
  @isTest
  static void testDeletePsetAssignmentError() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', false);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(true, true, ''))
      }
    );
    PermissionSetAssignment obj = new PermissionSetAssignment(
      Id = Lib_FakeIdGenerator.getMockId(PermissionSetAssignment.SObjectType)
    );

    Test.startTest();

    UserProvisioningAfterActions.deletePsetAssignment(
      new List<PermissionSetAssignment>{ obj }
    );
    Test.stopTest();
    List<PermissionSetAssignment> psetToDelete = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      psetToDelete.size(),
      'There should be one PermissionSetAssignment deleted'
    );
  }
  /**
   * @description Test when GroupMember deleting  with wrong data to cover exceptions and errors.
   */
  @isTest
  static void testDeleteGroupAssignmentError() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', false);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(true, true, ''))
      }
    );
    GroupMember obj = new GroupMember();
    Test.startTest();

    UserProvisioningAfterActions.deleteGroupAssignment(
      new List<GroupMember>{ obj }
    );
    Test.stopTest();
    List<GroupMember> groupToDelete = (List<GroupMember>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      groupToDelete.size(),
      'There should be one group deleted'
    );
  }
  /**
   * @description Test when permissionset license assignment  inserting successfully..
   */
  @isTest
  static void testInsertinsertPsetLicenseAssignNoError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(true, false, ''))
      }
    );
    PermissionSetLicenseAssign obj = new PermissionSetLicenseAssign(
      AssigneeId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      PermissionSetLicenseId = Lib_FakeIdGenerator.getMockId(
        PermissionSetLicense.SObjectType
      )
    );
    Test.startTest();

    UserProvisioningAfterActions.insertPsetLicenseAssign(
      new List<PermissionSetLicenseAssign>{ obj }
    );
    Test.stopTest();
    List<PermissionSetLicenseAssign> psasToAdd = (List<PermissionSetLicenseAssign>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      psasToAdd.size(),
      'There should be one permissionset license assignment to add'
    );
  }

  /**
   * @description Test when GroupMember inserting successfully.
   */
  @isTest
  static void testInserGroupMemberNoError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(true, false, ''))
      }
    );
    GroupMember obj = new GroupMember(
      UserOrGroupId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      GroupId = Lib_FakeIdGenerator.getMockId(Group.SObjectType)
    );
    Test.startTest();

    UserProvisioningAfterActions.insertGroupAssignment(
      new List<GroupMember>{ obj }
    );
    Test.stopTest();
    List<GroupMember> groupToAdd = (List<GroupMember>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      groupToAdd.size(),
      'There should be one GroupMember to add'
    );
  }
  /**
   * @description Test when PermissionSetAssignment inserting successfully.
   */
  @isTest
  static void testinsertPsetAssignmentNoError() {
    registerMocks();
    userProMock.mock('checkCreatePermissions', false);
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult(getMockSaveResult(true, false, ''))
      }
    );
    PermissionSetAssignment obj = new PermissionSetAssignment(
      AssigneeId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      PermissionSetGroupId = Lib_FakeIdGenerator.getMockId(
        PermissionSetGroup.SObjectType
      )
    );
    Test.startTest();

    UserProvisioningAfterActions.insertPsetAssignment(
      new List<PermissionSetAssignment>{ obj }
    );
    Test.stopTest();
    List<PermissionSetAssignment> pSetAssinToAdd = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      pSetAssinToAdd.size(),
      'There should be one permission set assignment to add'
    );
  }

  /**
   * @description Test when PermissionSetAssignment deleting successfully.
   */
  @isTest
  static void testDeletePsetAssignmentNoError() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', false);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(true, false, ''))
      }
    );
    PermissionSetAssignment obj = new PermissionSetAssignment(
      Id = Lib_FakeIdGenerator.getMockId(PermissionSetAssignment.SObjectType),
      AssigneeId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      PermissionSetGroupId = Lib_FakeIdGenerator.getMockId(
        PermissionSetGroup.SObjectType
      )
    );
    Test.startTest();

    UserProvisioningAfterActions.deletePsetAssignment(
      new List<PermissionSetAssignment>{ obj }
    );
    Test.stopTest();
    List<PermissionSetAssignment> permsToDelete = (List<PermissionSetAssignment>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      permsToDelete.size(),
      'There should be one PermissionSetAssignment deleted'
    );
  }

  /**
   * @description Test when GroupMember deleting successfully.
   */
  @isTest
  static void testdeleteGroupAssignmentNoError() {
    registerMocks();
    userProMock.mock('checkDeletePermissions', false);
    dmlRepoMock.mock(
      'doDelete',
      new List<Database.DeleteResult>{
        TestUtil.getMockDeleteResult(getMockSaveResult(true, false, ''))
      }
    );
    GroupMember obj = new GroupMember(
      Id = Lib_FakeIdGenerator.getMockId(GroupMember.SObjectType)
    );
    Test.startTest();

    UserProvisioningAfterActions.deleteGroupAssignment(
      new List<GroupMember>{ obj }
    );
    Test.stopTest();
    List<GroupMember> groupToDelete = (List<GroupMember>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      groupToDelete.size(),
      'There should be one group deleted'
    );
  }
  @isTest
  static void testRemoveUsertoGroup() {
    Boolean exceptionThrown = false;
    CollaborationGroup collGroup = new CollaborationGroup();
    collGroup.id = Lib_FakeIdGenerator.getMockId(
      CollaborationGroup.SObjectType
    );
    collGroup.Name = System.Label.CMOS_Chatter_Group_Name;
    collGroup.CollaborationType = 'Private';
    QueryCollaborationGroup.collGroups = new Map<String, CollaborationGroup>{
      collGroup.Name => collGroup
    };
    Test.startTest();
    try {
      UserProvisioningAfterActions.removeUserToGroup(
        new Set<Id>{ Lib_FakeIdGenerator.getMockId(User.SObjectType) }
      );
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Test.stopTest();
    Assert.areEqual(
      false,
      exceptionThrown,
      'Error while deleting user from group'
    );
  }

  private static string getMockSaveResult(
    Boolean isSuccess,
    Boolean isError,
    string statusCode
  ) {
    if (isError) {
      return '{"success":' +
        isSuccess +
        ',"errors":[{"statusCode":"' +
        statusCode +
        '","message":"TestErrorMessage","fields":[]}]}';
    }
    return '{"success":' + isSuccess + ',"errors":[]}';
  }
}
