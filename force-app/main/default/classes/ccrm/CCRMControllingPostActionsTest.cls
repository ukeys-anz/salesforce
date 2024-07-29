/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Controlling Post Action Test is the test class for CCRM Controlling Post Actions Class.
 */
@isTest
private class CCRMControllingPostActionsTest {
  static Lib_MockProvider cpRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    cpRepoMock = Lib_MockProvider.forType(CCRMControllingPostRepository.class);
  }

  @testSetup
  static void setup() {
    Set<String> setOfEmployeeId = new Set<String>{ '10456789', '10456790' };
    CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);
  }

  @isTest
  static void testCreateCPID() {
    //Given when banker creates a new Controlling post
    //When Employee ID is a valid User Id
    //Then Controlling Post Responsible Employee will be same as User Id
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID__c = 'L6601';
      cp1.Name = 'L6601';
      cp1.Responsible_Employee_Id__c = '10456789';
      insert cp1;

      cp1 = [
        SELECT Id, Responsible_Employee__c
        FROM Controlling_Post__c
        WHERE Id = :cp1.id
      ];

      User ccrmUser = [
        SELECT id
        FROM User
        WHERE Employee_Id__c = '10456789'
        LIMIT 1
      ];

      System.assertEquals(
        cp1.Responsible_Employee__c,
        ccrmUser.Id,
        'Controlling Post ID is equal'
      );
    }
  }

  @isTest
  static void testUpdateCPID() {
    //Given when banker updating a new Controlling post with invalid Responsible Employee Id
    //When Responsible Employee ID is updated to a valid user id
    //Then Controlling Post Responsible Employee will be same as User Id
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      Controlling_Post__c cp1 = new Controlling_Post__c();
      cp1.Is_Active__c = true;
      cp1.CPID__c = 'L6602';
      cp1.Name = 'L6602';
      cp1.Responsible_Employee_Id__c = '20456790';
      insert cp1;

      System.assertEquals(
        cp1.Responsible_Employee__c,
        null,
        'Controlling Post currently null'
      );

      Controlling_Post__c cp2 = [
        SELECT id, Responsible_Employee_Id__c
        FROM Controlling_Post__c
        WHERE Responsible_Employee_Id__c = '20456790'
        LIMIT 1
      ];

      cp2.Responsible_Employee_Id__c = '10456790';
      update cp2;

      Controlling_Post__c cp3 = [
        SELECT id, Responsible_Employee__c
        FROM Controlling_Post__c
        WHERE Responsible_Employee_Id__c = '10456790'
        LIMIT 1
      ];

      User ccrmUser = [
        SELECT id
        FROM User
        WHERE Employee_Id__c = '10456790'
        LIMIT 1
      ];

      System.assertEquals(
        cp3.Responsible_Employee__c,
        ccrmUser.Id,
        'Controlling Post ID is equal'
      );
    }
  }

  @isTest
  static void testGetFilterCpRecords() {
    //GIVEN Controlling_Post__c record
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType),
        Is_Active__c = true,
        Name = 'Controlling Post Record',
        CPID_LanID__c = 'user2'
      )
    };

    //WHEN method get called
    test.startTest();
    CCRMControllingPostActions.ControllingPostWrapper cpWrapper = CCRMControllingPostActions.getFilterCpRecords(
      cpList,
      new Map<Id, Controlling_Post__c>()
    );
    test.stopTest();

    //THEN the user is able to get the filtered Controlling_Post__c records
    System.assertEquals(
      1,
      cpWrapper.filteredCpList.size(),
      'Not able to get the cp records inserted with a CPID Lan Id value.'
    );
  }

  @isTest
  static void testFormLanIdToUserMap() {
    //GIVEN User List
    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'user1',
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    //WHEN method get called
    test.startTest();
    Map<String, User> lanIdUserMap = CCRMControllingPostActions.formLanIdToUserMap(
      userList
    );
    test.stopTest();

    //THEN the user is able to get the filtered Controlling_Post__c records
    System.assertEquals(
      1,
      lanIdUserMap.size(),
      'Not able to form the map of User and lan Id'
    );
  }

  @isTest
  static void testUpdateUserLookupOnCpRecordsNull() {
    //GIVEN there exist no user with LAN Id
    Map<String, User> lanIdUserMap = new Map<String, User>();

    //GIVEN Controlling_Post__c record
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType),
        Is_Active__c = true,
        Name = 'Controlling Post Record',
        CPID_LanID__c = 'user1'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CCRMControllingPostActions.updateUserLookupOnCpRecords(
      cpList,
      lanIdUserMap
    );
    Test.stopTest();

    //THEN the CPID User on Controlling_Post__c should be null
    System.assertEquals(
      cpList[0].CPID_User__c,
      null,
      'CPID User lookup value gets updated on controlling post records.'
    );
  }

  @isTest
  static void testUpdateUserLookupOnCpRecords() {
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Lan_Id__c = 'user1'
    );

    //GIVEN there exist a user with LAN Id
    Map<String, User> lanIdUserMap = new Map<String, User>{
      'user1' => userRec
    };

    //GIVEN Controlling_Post__c record
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType),
        Is_Active__c = true,
        Name = 'Controlling Post Record',
        CPID_LanID__c = 'user1'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CCRMControllingPostActions.updateUserLookupOnCpRecords(
      cpList,
      lanIdUserMap
    );
    Test.stopTest();

    //THEN the CPID User on Controlling_Post__c should be updated with a user Id
    System.assertEquals(
      cpList[0].CPID_User__c,
      userRec.Id,
      'CPID User lookup value didn\'t gets updated on controlling post records.'
    );
  }

  @isTest
  static void testSetCPIDUserOnInsert() {
    Id userId;
    registerMocks();
    userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    //GIVEN Controlling_Post__c record
    Controlling_Post__c cpRec = new Controlling_Post__c(
      Name = 'Test Controlling Post',
      CPID_LanId__c = 'user1'
    );

    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'user1',
        Id = userId
      )
    };
    cpRepoMock.mock('getActiveLanIdUser', userList);

    //WHEN user try to insert the record
    Test.startTest();
    CCRMControllingPostActions.setCPIDUser(
      new List<Controlling_Post__c>{ cpRec },
      new Map<Id, Controlling_Post__c>()
    );
    Test.stopTest();

    //THEN the CPID user field on Controlling post record should get updated.
    System.assertEquals(
      userId,
      cpRec.CPID_User__c,
      'User lookup not updated on Controlling post record on Insert.'
    );
  }

  @isTest
  static void testSetCPIDUserOnUpdate() {
    registerMocks();

    Id cpId = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    //GIVEN Controlling_Post__c record
    Map<Id, Controlling_Post__c> cpOldMap = new Map<Id, Controlling_Post__c>{
      cpId => (new Controlling_Post__c(
        Id = cpId,
        Is_Active__c = true,
        Name = 'Controlling Post Record',
        CPID_LanID__c = 'user1'
      ))
    };

    //WHEN User try to update the CPID LanID value
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = cpId,
        Is_Active__c = true,
        Name = 'Controlling Post Record',
        CPID_LanID__c = 'user2'
      )
    };

    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'user2',
        Id = userId
      )
    };
    cpRepoMock.mock('getActiveLanIdUser', userList);

    //WHEN user try to update the record
    Test.startTest();
    CCRMControllingPostActions.setCPIDUser(cpList, cpOldMap);
    Test.stopTest();

    //THEN the CPID user field on Controlling post record should get updated.
    System.assertEquals(
      userId,
      cpList[0].CPID_User__c,
      'User lookup not updated on Controlling post record on Update.'
    );
  }
}
