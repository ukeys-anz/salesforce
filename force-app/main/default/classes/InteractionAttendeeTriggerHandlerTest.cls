/**
 * @description Handler test class for the Interaction Attendee trigger
 * @author Rebecca Jan
 * @since 06/2022
 */
@isTest
public with sharing class InteractionAttendeeTriggerHandlerTest {
  @testSetup
  static void setup() {
    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');

    // Create coach user
    User coachUser = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'TestCoach',
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

  @isTest
  static void testUpdateAttendee() {
    Faker faker = new Faker('AU');
    User coachUser = TestUtil.getUserByFirstName('TestCoach');
    User userData = [
      SELECT Id, UserRole.Name, Name
      FROM User
      WHERE Id = :coachUser.Id
      LIMIT 1
    ];
    System.runAs(coachUser) {
      Account testAccount = createTestAccount(
        faker.randomString(10),
        faker.randomString(10),
        faker.randomString(10)
      );
      insert testAccount;
      testAccount = [
        SELECT Id, PersonContactId, Name
        FROM Account
        WHERE Id = :testAccount.Id
      ];
      DateTime startTime = DateTime.newInstance(DateTime.now().year(), 1, 1);
      Test.startTest();
      Interaction testInteraction = new Interaction(
        RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
        Direction__c = 'Inbound',
        InteractionType = 'Call',
        Authentication_Method__c = 'Not Required',
        StartTime = startTime,
        AccountId = testAccount.Id,
        Name = 'Inbound Call',
        OwnerId = UserInfo.getUserId()
      );
      insert testInteraction;
      Test.stopTest();

      Interaction parentInteraction = [
        SELECT Attendees__c, Attendees_and_Roles__c
        FROM Interaction
        WHERE Name = 'Inbound Call'
        LIMIT 1
      ];
      String[] attendeesArray = parentInteraction.Attendees__c.split(',');
      System.assertEquals(
        2,
        attendeesArray.size(),
        'Two Attendees should be added'
      );
    }
  }

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId
  ) {
    Faker faker = new Faker('AU');
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.RecordTypeId = personAccountRecordTypeId;
    testAccount.PersonMobilePhone = String.valueOf(faker.randomDecimal(10, 0));

    return testAccount;
  }
}
