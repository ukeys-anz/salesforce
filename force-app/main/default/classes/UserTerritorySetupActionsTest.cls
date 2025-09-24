/**
 * @author Pragya Awasthi
 * @since 15 Jan 2025
 * @description UserTerritorySetupActionsTest is the test class for UserTerritorySetupActions Class functionality.
 */
@isTest
public class UserTerritorySetupActionsTest {
  static Lib_MockProvider userActionsRepoMock;
  static Lib_MockProvider userTerritoryActionsRepoMock;
  static Lib_MockProvider territoryActionsRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    userActionsRepoMock = Lib_MockProvider.forType(UserActionsRepository.class);
    userTerritoryActionsRepoMock = Lib_MockProvider.forType(
      UserTerritoryActionsRepository.class
    );
    territoryActionsRepoMock = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
  }

  /**
   * @description test method for subscribeUserRecord
   */
  @isTest
  public static void testsubscribeUserRecord() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);
    List<User> testUser = new List<User>{
      new User(Id = usrId, isActive = false)
    };
    List<User_Territory_Setup_Event__e> objEvent = new List<User_Territory_Setup_Event__e>{
      new User_Territory_Setup_Event__e(User_Id__c = usrId)
    };
    List<Territory__c> terrRecord = new List<Territory__c>{
      new Territory__c(Id = idTerritory, Name = 'Canberra Inner South (ACT)')
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(User__c = usrId, Territory__c = idTerritory)
    };
    userActionsRepoMock.mock('getUserbyUserIds', testUser);
    userTerritoryActionsRepoMock.mock('getTerritoriesbyUserIds', usrTerrRecord);
    territoryActionsRepoMock.mock('getTerritoriesbyTerritoryNames', terrRecord);

    Test.startTest();
    UserTerritorySetupActions.subscribeUserRecord(objEvent);
    Test.stopTest();

    List<User_Territory__c> usrTerritory = (List<User_Territory__c>) dmlRepoMock.getHistory(
        'doUpsert'
      )
      .getParam('records');
    Assert.areEqual(
      idTerritory,
      usrTerritory[0].Territory__c,
      'Territories are not inserted/updated successfully.'
    );
    Assert.areEqual(
      usrId,
      usrTerritory[0].User__c,
      'Users are not inserted/updated successfully.'
    );
  }

  /**
   * @description test method for updateInactiveUsers
   */
  @isTest
  public static void testupdateInactiveUsers() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<User> testUser = new List<User>{
      new User(Id = usrId, isActive = false)
    };

    Test.startTest();
    UserTerritorySetupActions.updateInactiveUsers(testUser);
    Test.stopTest();

    List<User> usr = (List<User>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');
    Assert.areEqual(
      null,
      usr[0].ML_Territories__c,
      'Territory of Inactive User is not null'
    );
  }

  /**
   * @description test method for setUpTerritoryForNewUsers
   */
  @isTest
  public static void testsetUpTerritoryForNewUsers() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);

    List<User> testUser = new List<User>{
      new User(
        ML_Role__c = 'Loan Writer',
        ML_Territories__c = 'Canberra Inner South (ACT)'
      )
    };
    List<User> newUser = new List<User>{
      new User(
        Id = usrId,
        ML_Role__c = 'Loan Writer',
        ML_Territories__c = 'Canberra Inner South (ACT)',
        isActive = true
      )
    };
    List<Territory__c> terrRecord = new List<Territory__c>{
      new Territory__c(Id = idTerritory, Name = 'Canberra Inner South (ACT)')
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(
        User__c = usrId,
        Status__c = 'Active',
        ML_Role__c = 'Loan Writer',
        Territory__c = terrRecord[0].Id
      )
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(newUser[0].Id, usrTerrRecord);

    Map<String, Territory__c> mapOfTerritory = new Map<String, Territory__c>();
    mapOfTerritory.put(terrRecord[0].Name, terrRecord[0]);

    Test.startTest();
    UserTerritorySetupActions.setUpTerritoryForNewUsers(
      testUser,
      mapOfUserTerritory,
      mapOfTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      terrRecord[0].Id,
      usrTerrRecord[0].Territory__c,
      'Territory of User Territory is null'
    );
  }

  /**
   * @description test method for setUpTerritoryForActiveUsers
   */
  @isTest
  public static void testsetUpTerritoryForActiveUsers() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);

    List<User> testUser = new List<User>{
      new User(
        Id = usrId,
        ML_Role__c = 'Loan Writer',
        ML_Territories__c = 'Canberra Inner South (ACT)',
        isActive = true
      )
    };
    List<Territory__c> terrRecord = new List<Territory__c>{
      new Territory__c(Id = idTerritory, Name = 'Canberra Inner South (ACT)')
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(
        User__c = usrId,
        Status__c = 'Active',
        ML_Role__c = 'Loan Writer',
        Territory__c = terrRecord[0].Id
      )
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(testUser[0].Id, usrTerrRecord);

    Map<String, Territory__c> mapOfTerritory = new Map<String, Territory__c>();
    mapOfTerritory.put(terrRecord[0].Name, terrRecord[0]);

    Test.startTest();
    UserTerritorySetupActions.setUpTerritoryForActiveUsers(
      testUser,
      mapOfUserTerritory,
      mapOfTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      terrRecord[0].Id,
      usrTerrRecord[0].Territory__c,
      'Territory of User Territory is null'
    );
  }

  /**
   * @description test method for setUpTerritoryForInActiveUsers
   */
  @isTest
  public static void testsetUpTerritoryForInActiveUsers() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    List<User> testUser = new List<User>{
      new User(
        Id = usrId,
        ML_Role__c = 'Loan Writer',
        ML_Territories__c = 'Canberra Inner South (ACT)',
        isActive = false
      )
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(User__c = usrId, Status__c = 'InActive')
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(testUser[0].Id, usrTerrRecord);

    Test.startTest();
    UserTerritorySetupActions.setUpTerritoryForInActiveUsers(
      testUser,
      mapOfUserTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      'Inactive',
      usrTerrRecord[0].Status__c,
      'Status of User Territory is Active'
    );
  }

  /**
   * @description test method for setUpTerritoryForInActiveUsers
   */
  @isTest
  public static void testForActiveUsersWithBlankRoleOrTerritory() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    List<User> testUser = new List<User>{
      new User(Id = usrId, isActive = true)
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(
        User__c = usrId,
        Status__c = 'InActive',
        ML_Role__c = 'Loan Writer'
      )
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(testUser[0].Id, usrTerrRecord);

    Test.startTest();
    UserTerritorySetupActions.setUpTerritoryForInActiveUsers(
      testUser,
      mapOfUserTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      'Inactive',
      usrTerrRecord[0].Status__c,
      'Status of User Territory is Active'
    );
  }

  /**
   * @description test method for updateExistingUserTerritoryForActiveUsers
   */
  @isTest
  public static void testupdateExistingUserTerritoryForActiveUsers() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);

    User testUser = new User(
      Id = usrId,
      IsActive = true,
      ML_Role__c = 'Loan Writer',
      ML_Territories__c = 'Canberra Inner South (ACT)'
    );
    List<Territory__c> terrRecord = new List<Territory__c>{
      new Territory__c(Id = idTerritory, Name = 'Canberra Inner South (ACT)')
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(
        User__c = usrId,
        Territory__c = terrRecord[0].Id,
        Territory__r = terrRecord[0]
      )
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(testUser.Id, usrTerrRecord);

    Set<String> setOfTerritory = new Set<String>();
    setOfTerritory.add('Canberra Inner South (ACT)');

    Test.startTest();
    UserTerritorySetupActions.updateExistingUserTerritoryForActiveUsers(
      testUser,
      usrTerrRecord,
      setOfTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      'Loan Writer',
      usrTerrRecord[0].ML_Role__c,
      'ML Role of User Territory does not match to the ML Role of the related User'
    );
  }

  /**
   * @description test method for createNewActiveUserTerritories
   */
  @isTest
  public static void testcreateNewActiveUserTerritories() {
    registerMocks();
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id idTerritory = Lib_FakeIdGenerator.getMockId(Territory__c.SObjectType);

    User testUser = new User(Id = usrId, isActive = true);
    List<Territory__c> terrRecord = new List<Territory__c>{
      new Territory__c(Id = idTerritory, Name = 'Canberra Inner South (ACT)')
    };
    List<User_Territory__c> usrTerrRecord = new List<User_Territory__c>{
      new User_Territory__c(User__c = usrId, Status__c = 'Active')
    };

    Map<Id, List<User_Territory__c>> mapOfUserTerritory = new Map<Id, List<User_Territory__c>>();
    mapOfUserTerritory.put(testUser.Id, usrTerrRecord);

    Map<String, Territory__c> mapOfTerritory = new Map<String, Territory__c>();
    mapOfTerritory.put(terrRecord[0].Name, terrRecord[0]);

    Set<String> setOfTerritory = new Set<String>();
    setOfTerritory.add('Canberra Inner South (ACT)');

    Test.startTest();
    UserTerritorySetupActions.createNewActiveUserTerritories(
      testUser,
      mapOfTerritory,
      setOfTerritory
    );
    Test.stopTest();

    Assert.areEqual(
      'Active',
      usrTerrRecord[0].Status__c,
      'Status of User Territory is not Active'
    );
  }
}
