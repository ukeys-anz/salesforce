/**
 * @author ML Developer
 * @since 11/2024
 * @description UserActionsTest is the test class for UserActions Class functionality.
 */
@isTest
public class UserActionsTest {
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }
  @IsTest
  static void testCreateTerritoryForMLUserOnInsert() {
    registerMocks();
    List<User> userList = new List<User>{
      new User(
        Id = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType()),
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      ),
      new User(
        Id = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType()),
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      )
    };
    Test.startTest();
    UserActions.createTerritoryForMLUser(userList, null);
    Test.stopTest();
    String userIdString = ((User_Territory_Setup_Event__e) dmlMockProvider.getHistory(
          'doPublish'
        )
        .listOfArgs[0])
      .User_Id__c;
    Assert.isTrue(
      userIdString.contains(userList[0].Id),
      'Territory Creation Event not published for first user'
    );
    Assert.isTrue(
      userIdString.contains(userList[1].Id),
      'Territory Creation Event not published for second user'
    );
  }

  @IsTest
  static void testCreateTerritoryForMLUserOnUpdate() {
    registerMocks();
    Id userId1 = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType());
    Id userId2 = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType());
    List<User> userList = new List<User>{
      new User(
        Id = userId1,
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      ),
      new User(
        Id = userId2,
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Franchise Owner'
      )
    };
    Map<Id, User> oldMapUsers = new Map<Id, User>{
      userId1 => new User(
        Id = userId1,
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Franchise Owner'
      ),
      userId2 => new User(
        Id = userId2,
        ProfileId = QueryProfile.anzUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Franchise Owner'
      )
    };
    Test.startTest();
    UserActions.createTerritoryForMLUser(userList, oldMapUsers);
    Test.stopTest();
    String userIdString = ((User_Territory_Setup_Event__e) dmlMockProvider.getHistory(
          'doPublish'
        )
        .listOfArgs[0])
      .User_Id__c;
    Assert.isTrue(
      userIdString.contains(userId1),
      'Territory Creation Event not published for first user'
    );
    Assert.isTrue(
      userIdString.contains(userId2),
      'Territory Creation Event not published for second user'
    );
  }

  @IsTest
  static void testCreateTerritoryForMLUserNoEvent() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType());
    List<User> userList = new List<User>{
      new User(
        Id = userId,
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      )
    };
    Map<Id, User> oldMapUsers = new Map<Id, User>{
      userId => new User(
        Id = userId,
        ProfileId = QueryProfile.anzMLStandardUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      )
    };
    Test.startTest();
    UserActions.createTerritoryForMLUser(userList, oldMapUsers);
    Test.stopTest();
    Assert.areEqual(
      null,
      dmlMockProvider.getHistory('doPublish'),
      'Territory event is published'
    );
  }

  @IsTest
  static void testCreateTerritoryForMLUserOtherUser() {
    registerMocks();
    List<User> userList = new List<User>{
      new User(
        Id = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType()),
        ProfileId = QueryProfile.anzUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      )
    };
    Test.startTest();
    UserActions.createTerritoryForMLUser(userList, null);
    Test.stopTest();
    Assert.areEqual(
      null,
      dmlMockProvider.getHistory('doPublish'),
      'Territory event is published'
    );
  }

  @isTest
  static void testFilterUsersForTerritorySetup() {
    List<User> userList = new List<User>{
      new User(
        Id = Lib_FakeIdGenerator.getMockId(Schema.User.getSObjectType()),
        ProfileId = QueryProfile.anzUser.Id,
        UserRoleId = QueryRole.mlFranchiseRole.Id,
        IsActive = true,
        ML_Territories__c = 'Canberra Inner South (ACT)',
        ML_Role__c = 'Loan Writer'
      )
    };
    Test.startTest();
    List<User> filteredUsers = UserActions.filterUsersForTerritorySetup(
      userList,
      null
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      filteredUsers.size(),
      'User is not filtered for territory setup'
    );
  }
}
