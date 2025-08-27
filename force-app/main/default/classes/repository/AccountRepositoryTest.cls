/**
 * @author Peter Charalambous
 * @since June 2025
 * @description
 */
@isTest
public with sharing class AccountRepositoryTest {
  private final static Faker TESTFAKER = new Faker('AU');
  static String ocvId = TESTFAKER.randomString(10);
  static Account getAccount {
    get {
      return new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Account',
        OCV_ID__c = ocvId,
        ANZx_Customer__c = true
      );
    }
  }

  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    System.runAs(TestDataFactory.thisUser) {
      User coachUser = TestUtil.createTestUser(
        new Map<String, Object>{
          'FirstName' => 'TestCoachUser',
          'ProfileId' => stdUserProfile.Id,
          'UserRoleId' => coachRole.Id
        }
      );
      insert coachUser;
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
  static void testGetAccountsWithExternalId() {
    Set<Id> accountIds = new Set<Id>();
    accountIds.add(getAccount.Id);
    AccountRepository accountRepo = new AccountRepository();
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Test.startTest();
      Map<Id, Account> response = accountRepo.getAccountsWithExternalId(
        accountIds
      );
      Test.stopTest();
    }
    Assert.areEqual(getAccount.ANZx_Customer__c, true, 'ANZX customer is true');
  }

  @isTest
  static void testGetAccountByOcvId() {
    AccountRepository accountRepo = new AccountRepository();
    User coachUser = [
      SELECT Id
      FROM User
      WHERE FirstName = 'TestCoachUser'
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Test.startTest();
      Account response = accountRepo.getAccountByOcvId(getAccount.OCV_ID__c);
      Test.stopTest();
    }
    Assert.areEqual(getAccount.OCV_ID__c, ocvId, 'ocvId should be same');
  }
}
