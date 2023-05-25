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

  @isTest
  static void testBlockRefreshTokenQueried() {
    //GIVEN the user with `ANZx Standard User` profile
    User thisUser = TestUtil.createTestUserWithProfile('ANZx Standard User');
    insert thisUser;
    String errorMessage =
      'Block RefreshToken Queried APIEvent has been done by ' +
      thisUser.Username +
      ' (Id: ' +
      thisUser.Id +
      ' ) with ANZx Standard User profile.';

    //WHEN the user want to query RefreshToken Field
    Test.startTest();
    System.runAs(thisUser) {
      String testQuery = '[SELECT Id, Refresh_Token__c FROM User]';
      ApiEvent testEvent = new ApiEvent();
      testEvent.QueriedEntities = 'User';
      testEvent.query = testQuery;
      Boolean result = TSPHandler.evaluate(testEvent);
      Logger.saveLog(Logger.SaveMethod.QUEUEABLE);
      Test.stopTest();

      //THEN error message should be logged
      LogEntry__c testLogEntry = [
        SELECT LogMessage__c
        FROM LogEntry__c
        LIMIT 1
      ];
      String testLog = testLogEntry.LogMessage__c;

      System.assertEquals(
        errorMessage.toLowerCase(),
        testLog.toLowerCase(),
        'Error Message should be logged as expected'
      );
    }
  }
}
