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

    Account testAccount = createTestAccount(
      faker.randomString(10),
      faker.randomString(10),
      faker.randomString(10)
    );
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];
    DateTime startTime = DateTime.newInstance(DateTime.now().year(), 1, 1);

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      Direction__c = 'Inbound',
      InteractionType = 'Chat',
      Authentication_Method__c = 'Not Required',
      StartTime = startTime,
      AccountId = testAccount.Id,
      Name = 'Inbound Chat',
      OwnerId = UserInfo.getUserId()
    );
    insert testInteraction;

    Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
    List<InteractionAttendee> newAttendees = new List<InteractionAttendee>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newAttendees.add(
        new InteractionAttendee(
          InteractionId = testInteraction.Id,
          UserId = userData.Id
        )
      );
    }

    Test.startTest();
    insert newAttendees;
    Test.stopTest();

    Interaction parentInteraction = [
      SELECT Attendees__c, Attendees_and_Roles__c
      FROM Interaction
      WHERE Name = 'Inbound Chat'
      LIMIT 1
    ];
    System.assertEquals(
      userData.Name,
      parentInteraction.Attendees__c,
      'Incorrect value for Attendees__c'
    );
    System.assertEquals(
      '{"userIdToDetails":{"' +
      userData.Id +
      '":"Coach"}}',
      parentInteraction.Attendees_and_Roles__c,
      'Incorrect value for Attendees_and_Roles__c'
    );
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
