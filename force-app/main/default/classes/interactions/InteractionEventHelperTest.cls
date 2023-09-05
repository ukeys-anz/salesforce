/**
 * @description Test the InteractionEventHelper class
 * @author Adam Phillip Smith
 * @since 20220809
 */
@isTest
public with sharing class InteractionEventHelperTest {
  private final static Faker FAKER_TEST = new Faker('AU');
  private final static String ANZX_USER_PROFILE_NAME = 'ANZx Standard User';
  private final static String APPOINTMENT_BOOKING_PERMSET_NAME = 'Appointment_Booking_Read_Write';
  private final static String COACH_LEAD_ROLE_NAME = 'Coach_Lead';
  private final static String COACH_LEAD_PSG = 'Coach_Lead';
  private final static String FIRST_NAME_IDENTIFIER = 'This is a User for this specific test';
  private final static UserRole COACH_LEAD_ROLE = CommonUtil.getUserRoleByDevName(
    COACH_LEAD_ROLE_NAME
  );

  @testSetup
  static void setup() {
    Map<String, String> userParameters = new Map<String, String>();

    userParameters.put('UserRoleId', COACH_LEAD_ROLE.Id);

    Map<String, String> firstUserParameters = userParameters.clone();
    firstUserParameters.put('FirstName', FIRST_NAME_IDENTIFIER);
    firstUserParameters.put('LastName', FAKER_TEST.randomString(15));

    User firstUser = TestUtil.createTestUserWithProfile(
      ANZX_USER_PROFILE_NAME,
      firstUserParameters
    );

    Map<String, String> secondUserParameters = userParameters.clone();
    secondUserParameters.put('FirstName', FIRST_NAME_IDENTIFIER);
    secondUserParameters.put('LastName', FAKER_TEST.randomString(15));

    User secondUser = TestUtil.createTestUserWithProfile(
      ANZX_USER_PROFILE_NAME,
      secondUserParameters
    );

    List<User> users = new List<User>{ firstUser, secondUser };
    insert users;

    TestUtil.assignPermissionSets(
      new List<String>{ APPOINTMENT_BOOKING_PERMSET_NAME },
      users
    );

    TestUtil.assignPermissionSetGroups(
      new List<String>{ COACH_LEAD_PSG },
      users
    );
  }

  // @isTest
  // static void testReassigningEvent() {
  //   List<User> users = [
  //     SELECT Id
  //     FROM User
  //     WHERE
  //       UserRoleID = :COACH_LEAD_ROLE.Id
  //       AND FirstName = :FIRST_NAME_IDENTIFIER
  //   ];

  //   User userOne = users[0];
  //   User userTwo = users[1];

  //   System.assertNotEquals(null, userOne, 'First user should exist');
  //   System.assertNotEquals(null, userTwo, 'Second user should exist');

  //   DateTime startDate = DateTime.newInstance(
  //     DateTime.now().year() + 1,
  //     1,
  //     1,
  //     12,
  //     0,
  //     0
  //   );

  //   List<GroupMember> members = [
  //     SELECT UserOrGroupId
  //     FROM GroupMember
  //     WHERE GroupId = :InteractionConstants.APPOINTMENT_QUEUE_ID
  //   ];

  //   Interaction testInteraction;
  //   System.runAs(userOne) {
  //     Account testAccount = createTestAccount();

  //     testInteraction = new Interaction(
  //       RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
  //       Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
  //       StartTime = startDate,
  //       Name = FAKER_TEST.randomString(10),
  //       AccountId = testAccount.Id
  //     );

  //     Database.SaveResult insertResult = Database.insert(testInteraction);

  //     String errorMessage = '';
  //     Id interactionId;
  //     if (insertResult.success == false) {
  //       for (Database.Error currentError : insertResult.getErrors()) {
  //         errorMessage +=
  //           currentError.getStatusCode() +
  //           ': ' +
  //           currentError.getMessage() +
  //           ' END';
  //       }
  //     } else {
  //       interactionId = insertResult.getId();
  //     }

  //     System.assertEquals(true, String.isEmpty(errorMessage), errorMessage);
  //     System.assertNotEquals(null, interactionId);

  //     test.startTest();
  //     List<Interaction> allInteractions = [
  //       SELECT Id, OwnerId
  //       FROM Interaction
  //       WHERE Id = :interactionId
  //     ];

  //     //Take ownership of the Interaction
  //     testInteraction.Id = interactionId;
  //     testInteraction.OwnerId = UserInfo.getUserId();

  //     if (Interaction.SObjectType.getDescribe().isUpdateable()) {
  //       update testInteraction;
  //     } else {
  //       System.assert(
  //         false,
  //         'You do not have Update permissions on interactions'
  //       );
  //     }

  //     List<Event> resultEvents = [SELECT OwnerId, WhatId FROM Event];
  //     System.assertEquals(
  //       false,
  //       resultEvents.isEmpty(),
  //       'There should be an event'
  //     );
  //     System.assertEquals(1, resultEvents.size(), 'There should be one event');
  //     System.assertEquals(
  //       UserOne.Id,
  //       resultEvents[0].OwnerId,
  //       'The event should be owned by the same person that owns the interaction'
  //     );
  //     System.assertEquals(
  //       testInteraction.Id,
  //       resultEvents[0].WhatId,
  //       'The event should relate to the interaction'
  //     );
  //   }

  //   System.runAs(userTwo) {
  //     String errorMessage = '';
  //     //Switch ownership to the other user.
  //     testInteraction.OwnerId = userTwo.Id;

  //     Exception thrownException;
  //     try {
  //       Database.SaveResult updateResult = Database.Update(testInteraction);
  //       if (updateResult.success == false) {
  //         for (Database.Error currentError : updateResult.getErrors()) {
  //           errorMessage +=
  //             currentError.getStatusCode() +
  //             ': ' +
  //             currentError.getMessage() +
  //             ' END';
  //         }
  //       }
  //       System.assertEquals(true, String.isEmpty(errorMessage), errorMessage);
  //     } catch (Exception exc) {
  //       thrownException = exc;
  //     }
  //     test.stopTest();
  //     System.assertEquals(
  //       null,
  //       thrownException,
  //       'An exception must not be thrown'
  //     );

  //     List<Event> newResultEvents = [SELECT OwnerId, WhatId FROM Event];
  //     System.assertEquals(
  //       false,
  //       newResultEvents.isEmpty(),
  //       'There should be an event'
  //     );
  //     System.assertEquals(
  //       1,
  //       newResultEvents.size(),
  //       'There should be one event'
  //     );
  //     System.assertEquals(
  //       userTwo.Id,
  //       newResultEvents[0].OwnerId,
  //       'The event should be owned by the same person that owns the interaction'
  //     );
  //     System.assertEquals(
  //       testInteraction.Id,
  //       newResultEvents[0].WhatId,
  //       'The event should relate to the interaction'
  //     );
  //   }
  // }

  /**
   * @description helper method to create a person account
   * @return Account a Person Account with Name Fred Smith, OCV ID 123456
   */
  static Account createTestAccount() {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = FAKER_TEST.randomString(5);
    testAccount.LastName = FAKER_TEST.randomString(5);
    testAccount.OCV_ID__c = FAKER_TEST.randomString(6);
    testAccount.PersonMobilePhone = String.valueOf(
      FAKER_TEST.randomDecimal(10, 0)
    );
    testAccount.RecordTypeId = personAccountRecordTypeId;
    insert testAccount;

    testAccount = [
      SELECT Id, PersonContactId, PersonMobilePhone
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    return testAccount;
  }
}
