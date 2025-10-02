@isTest
public with sharing class TSPHandlerTest {
  static String anzUserProfile = 'ANZ Standard User';
  static String anzxUserProfile = 'ANZx Standard User';
  static String integrationProfile = 'Integration User';
  static Lib_MockProvider queryMock;
  static void registerMocks() {
    queryMock = Lib_MockProvider.forType(TSPRepository.class);
  }
  static Lib_MockProvider testUserMock = Lib_MockProvider.forType(
    TSPRepository.class
  );

  static User anzUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Alias = 'anzUser',
    Username = 'anzUser TestUser',
    Profile = CommonUtil.getProfileByName(anzUserProfile)
  );

  static User anzxUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Alias = 'anzxUser',
    Username = 'anzxUser TestUser',
    Profile = CommonUtil.getProfileByName(anzxUserProfile)
  );
  static User integrationUser = new User(
    Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
    Alias = 'integrationUser',
    Username = 'integrationUser TestUser',
    Profile = CommonUtil.getProfileByName(integrationProfile)
  );
  @isTest
  static void bulkAPITSPHandlerANZxUserTest() {
    //GIVEN the user with `ANZx Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query BulkAPI
      BulkApiResultEventStore testEvent = new BulkApiResultEventStore();

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(result, 'Should return true');
    }
  }
  @isTest
  static void fileEventStoreANZxUserTest() {
    //WHEN the user want to query BulkAPI
    FileEventStore testEvent = new FileEventStore();

    //THEN the condition should be true
    Boolean result = TSPHandler.evaluate(testEvent);
    Assert.isTrue(!result, 'Should return false');
  }

  @isTest
  static void bulkAPICondtionANZUserTest() {
    //GIVEN the user with `ANZ Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZ Standard User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query BulkAPI
      BulkApiResultEventStore testEvent = new BulkApiResultEventStore();

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(!result, 'Should return false');
    }
  }

  @isTest
  static void bulkAPICondtionIntegrationUserTest() {
    //GIVEN the user with `ANZ Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('Integration User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query BulkAPI
      BulkApiResultEventStore testEvent = new BulkApiResultEventStore();

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(!result, 'Should return false');
    }
  }

  @isTest
  static void reportEventCondtionANZxUserTest() {
    registerMocks();
    List<PermissionSetAssignment> psaList = getPermissionSetAssignments;
    queryMock.mock('queryPermissionSetAssignment', psaList);
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);

    //WHEN the user want to query ReportEvent
    ReportEvent testEvent = new ReportEvent();
    testevent.Operation = 'ReportExported';

    //THEN the condition should be true
    Boolean result = TSPHandler.evaluate(testEvent);
    System.assert(result, 'Should return true');
  }

  static List<PermissionSetAssignment> getPermissionSetAssignments {
    get {
      List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
      PermissionSetAssignment ps = new PermissionSetAssignment();
      ps.AssigneeId = UserInfo.getUserId();
      ps.PermissionSetGroupId = CommonUtil.getPermissionSetByName('Join_Lead')
        .Id;
      //ps.Id = psaIds[0].Id;
      psaList.add(ps);
      return psaList;
    }
  }
  @isTest
  static void reportEventCondtionANZUserTest() {
    registerMocks();
    List<PermissionSetAssignment> psaList = getPermissionSetAssignments;
    queryMock.mock('queryPermissionSetAssignment', psaList);

    //WHEN the user want to query ReportEvent
    ReportEvent testEvent = new ReportEvent();

    //THEN the condition should be true
    Boolean result = TSPHandler.evaluate(testEvent);
    System.assert(!result, 'Should return false');
  }

  @isTest
  static void reportEventCondtionJoinLeadPSGTest() {
    registerMocks();
    List<PermissionSetAssignment> psaList = getPermissionSetAssignments;
    queryMock.mock('queryPermissionSetAssignment', psaList);
    testUserMock.mock('queryProfilebyEventUserId', anzUser);
    Test.startTest();

    //WHEN the user want to query ReportEvent
    ReportEvent testEvent = new ReportEvent();
    testevent.Operation = 'ReportExported';

    //THEN the condition should be true
    Boolean result = TSPHandler.evaluate(testEvent);

    Test.stopTest();

    System.assert(result, 'Should return true');
  }

  @isTest
  static void reportEventCondtionIntegrationUserTest() {
    registerMocks();
    List<PermissionSetAssignment> psaList = getPermissionSetAssignments;
    queryMock.mock('queryPermissionSetAssignment', psaList);
    testUserMock.mock('queryProfilebyEventUserId', integrationUser);
    //WHEN the user want to query ReportEvent
    ReportEvent testEvent = new ReportEvent();
    testevent.Operation = 'ReportExported';

    //THEN the condition should be true
    Boolean result = TSPHandler.evaluate(testEvent);
    System.assert(result, 'Should return true');
  }

  @isTest
  static void nullEventTest() {
    //WHEN the user want to query ReportEvent
    Sobject testEvent = null;

    //THEN the condition should be false
    Boolean result = TSPHandler.evaluate(testEvent);
    System.assert(!result, 'Should return false');
  }

  @isTest
  static void listViewEventCondtionANZUserTest() {
    //WHEN the user want to query ListViewEvent
    ListViewEvent testEvent = new ListViewEvent();

    //THEN the condition should be false
    Boolean result = TSPHandler.evaluate(testEvent);
    System.assert(!result, 'Should return false');
  }

  /*
    * Point: ReportAnomalyEvent for positive case (return true) has no test, as if we want to test it, we need
    * to use a Report and make many execution to be as an anomaly event. For using Report on test we need to
    * use `@isTest(SeeAllData=true)` that will make some risk. 

    * Point: ReportAnomalyEvent for negative case (return false) can be tested, as the testUser does not 
    * have ReportAnomalyEvent.score >= 50, and it will give false as the result
  */

  @isTest
  static void reportAnomalyEventCondtionNotTriggered() {
    //GIVEN the user with `Integration User` profile
    User thisUser = TestUtil.createTestUserWithProfile('Integration User');
    insert thisUser;
    System.runAs(thisUser) {
      //WHEN the user want to query ReportAnomalyEvent
      ReportAnomalyEvent testEvent = new ReportAnomalyEvent(Score = 0);

      //THEN the condition should be false
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(
        !result,
        'Should return false as the Score is less than 50'
      );
    }
  }

  @isTest
  static void reportAnomalyEventCondtionTriggered() {
    //GIVEN the user with `Integration User` profile
    User thisUser = TestUtil.createTestUserWithProfile('Integration User');
    insert thisUser;
    System.runAs(thisUser) {
      //WHEN the user want to query ReportAnomalyEvent
      ReportAnomalyEvent testEvent = new ReportAnomalyEvent(Score = 99.9);

      //THEN the condition should be false
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(result, 'Should return true as the Score is more than 50');
    }
  }

  @isTest
  static void testBlockRefreshTokenQueried() {
    //GIVEN
    //1. the user with `ANZx Standard User` profile
    //2. Set the queried entity to User
    //3. Set the query to get Refresh_Token__c field  from User object
    testUserMock.mock('queryProfilebyEventUserId', anzxUser);
    ApiEvent testQueryEvent = new ApiEvent();
    testQueryEvent.QueriedEntities = 'User';
    testQueryEvent.query = 'SELECT Id, Refresh_Token__c FROM User';

    //WHEN the user want to query RefreshToken Field
    Test.startTest();
    Boolean result = TSPHandler.evaluate(testQueryEvent);
    Test.stopTest();

    //THEN TSP should return true when user query RefreshToken Field from user object
    Assert.isTrue(
      result,
      'TSP for refreshTokenQueriedEvent should return true for refresh_token__c when being que'
    );
  }

  @isTest
  static void testReportLoginEventBreakGlassUser() {
    //GIVEN LoginEvent with Username is BreakGlass User (System User)
    LoginEvent testLoginEvent = new LoginEvent();
    testLoginEvent.UserName = 'anzx.user@anzx.com';

    //WHEN TSPHandler is checking Login Event Policies
    Test.startTest();
    Boolean result = TSPHandler.evaluate(testLoginEvent);
    Test.stopTest();

    //THEN TSP should return true when breakglass user is logged into the system
    Assert.isTrue(
      result,
      'TSP for Login Event should return true for breakglass user login Event'
    );
  }

  @isTest
  static void testCheckBreakGlassUser() {
    //GIVEN Login Event with BreakGlass User
    LoginEvent testLoginEvent = new LoginEvent();
    testLoginEvent.Username = 'anzx.user@anzx.com';

    ////WHEN checkBreakGlassUser is called
    Test.startTest();
    Boolean result = TSPHandler.checkBreakGlassUser(testLoginEvent);
    Test.stopTest();

    // THEN checkBreakGlassUser should return TRUE
    Assert.isTrue(
      result,
      'breakglass user should be detected and returned TRUE'
    );
  }

  @isTest
  static void testCheckBreakGlassUserNonBreakGlassUser() {
    //GIVEN Login Event with normal user
    LoginEvent testLoginEvent = new LoginEvent();
    testLoginEvent.Username = math.random() + '@anzx.com';

    ////WHEN checkBreakGlassUser is called
    Test.startTest();
    Boolean result = TSPHandler.checkBreakGlassUser(testLoginEvent);
    Test.stopTest();

    // THEN checkBreakGlassUser should return FALSE
    Assert.isFalse(
      result,
      'checkBreakGlassUser should return false when normal user login to Salesforce'
    );
  }
}
