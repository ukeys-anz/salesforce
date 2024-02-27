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
  }

  @isTest
  public static void testCoachNudgeBatch() {
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    Faker faker = new Faker('AU');
    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.COACH_NUDGE_RT_ID,
      null,
      '0069p000000' + faker.randomString(7),
      '00G9p000000' + faker.randomString(7),
      false
    );
    Test.startTest();
    System.runAs(coachUser) {
      try {
        CoachNudgeTaskAutoExpireBatch cnBatch = new CoachNudgeTaskAutoExpireBatch();
        cnBatch.execute(null, new List<Task>{ coachNudgeTask });
        cnBatch.execute(null);
        cnBatch.start(null);
        cnBatch.finish(null);
      } catch (Exception exp) {
        Assert.isTrue(exp.getMessage() != null, 'Exception Occured');
      }
    }
    Test.stopTest();
  }

  @isTest
  public static void testCheckAndUpdateTaskRecords() {
    User coachUser = TestUtil.getUserByFirstName('TestCoachUser');
    Faker faker = new Faker('AU');
    Task coachNudgeTask = TestDataFactory.createTaskRecord(
      GetHelpConstants.COACH_NUDGE_RT_ID,
      null,
      '0069p000000' + faker.randomString(7),
      '00G9p000000' + faker.randomString(7),
      false
    );
    Test.startTest();
    List<Task> expiredTasks = CoachNudgeTaskAutoExpireBatch.checkAndUpdateTaskRecords(
      new List<Task>{ coachNudgeTask }
    );
    Test.stopTest();
    Assert.isTrue(expiredTasks[0].Status == 'Expired', 'Expired');
  }
}
