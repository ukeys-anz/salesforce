/**
 * @author Aman Gupta
 * @since 01/2024
 * @description  Test Class for the CoachNudgeTaskAutoExpireBatch created to auto expire Coach Nudge Task
 */
@isTest
public with sharing class CoachNudgeTaskAutoExpireBatchTest {
  @TestSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    // Create coach user
    System.runAs(TestDataFactory.thisUser) {
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;
      //Assign Permission set group as coach
      PermissionSetGroup psgCoach = [
        SELECT Id
        FROM PermissionSetGroup
        WHERE DeveloperName = 'Coach'
        LIMIT 1
      ];
      Test.calculatePermissionSetGroup(new List<String>{ psgCoach.Id });
      PermissionSetAssignment psa = new PermissionSetAssignment(
        AssigneeId = coachUser.Id,
        PermissionSetGroupId = psgCoach.Id
      );
      insert psa;
    }

    Group coachQueue = CommonUtil.getQueueByName('BOH_Coach_Queue');

    Faker faker = new Faker('AU');

    // create an ANZx Customer
    Account acc = new Account(
      Name = 'Test ANZx Account',
      OCV_ID__c = 'TESTOCVID4321',
      ANZx_Customer__c = true
    );
    insert acc;
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');

    ResidentialLoanApplication rla = TestDataFactory.createTestResidentialLoanApplication(
      'Test'
    );
    rla.Credit_ID__c = '000-000-000-00';
    rla.AccountId = acc.Id;
    insert rla;

    Task coachNudgeTask = new Task(
      RecordTypeId = GetHelpConstants.COACH_NUDGE_RT_ID,
      Type = 'Home Loan Ineligible Nudge',
      Status = 'Not Started',
      Priority = 'Normal',
      ActivityDate = Date.today().addDays(-2),
      WhoId = acc.PersonContactId,
      WhatId = rla.Id,
      Description = 'Outbound',
      Subject = 'ANZPlus-Data-Customer - Coach task',
      OwnerId = coachQueue.Id
    );
    insert coachNudgeTask;
  }

  @isTest
  public static void testCoachNudgeValidation() {
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    Test.startTest();
    System.runAs(coachUser) {
      try {
        Database.executeBatch(new CoachNudgeTaskAutoExpireBatch());
      } catch (Exception exp) {
        Assert.isTrue(exp.getMessage() != null, 'Exception Occured');
      }
    }
    Test.stopTest();
    Assert.isTrue(
      [
        SELECT Id, Status, CompletedDateTime, ActivityDate
        FROM Task
        WHERE
          ActivityDate < TODAY
          AND RecordTypeId = :GetHelpConstants.COACH_NUDGE_RT_ID
        LIMIT 1
      ][0]
      .Status == 'Expired',
      'Expired'
    );
  }
}
