@isTest
public with sharing class TSPHandlerTest {
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
    //GIVEN the user with `ANZx Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query ReportEvent
      ReportEvent testEvent = new ReportEvent();
      testevent.Operation = 'ReportExported';

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(result, 'Should return true');
    }
  }

  @isTest
  static void reportEventCondtionANZUserTest() {
    //GIVEN the user with `ANZx Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZ Standard User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query ReportEvent
      ReportEvent testEvent = new ReportEvent();

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(!result, 'Should return false');
    }
  }

  @isTest
  static void reportEventCondtionJoinLeadPSGTest() {
    //GIVEN the user with `ANZ Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZ Standard User');
    insert thisUser;

    PermissionSetGroup psgJoinLead = [
      SELECT Id
      FROM PermissionSetGroup
      WHERE DeveloperName = 'Join_Lead'
      LIMIT 1
    ];
    // To assign the PSG to test user, after the PSG calculation is finsihed.
    Test.calculatePermissionSetGroup(new List<String>{ psgJoinLead.Id });

    System.runAs(thisUser) {
      Test.startTest();

      insert new PermissionSetAssignment(
        AssigneeId = thisUser.Id,
        PermissionSetGroupId = psgJoinLead.Id
      );
      //WHEN the user want to query ReportEvent
      ReportEvent testEvent = new ReportEvent();
      testevent.Operation = 'ReportExported';

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);

      Test.stopTest();

      System.assert(result, 'Should return true');
    }
  }

  @isTest
  static void reportEventCondtionIntegrationUserTest() {
    //GIVEN the user with `ANZ Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('Integration User');
    insert thisUser;

    System.runAs(thisUser) {
      //WHEN the user want to query ReportEvent
      ReportEvent testEvent = new ReportEvent();
      testevent.Operation = 'ReportExported';

      //THEN the condition should be true
      Boolean result = TSPHandler.evaluate(testEvent);
      System.assert(result, 'Should return true');
    }
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
}
