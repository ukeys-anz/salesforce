/**
 * @description Test intercept for existing interactions
 * @author Adam Phillip Smith
 * @since 20220527
 */
@isTest
public with sharing class InteractionInterceptTest {
  private static final string FIRST_NAME = 'Fred';
  private static final string LAST_NAME = 'Smith';
  private static final string PHONE_NUMBER = '01189998819991197253';
  @isTest
  static void isInterceptInteractions() {
    DateTime startDate = DateTime.newInstance(
      DateTime.now().year(),
      1,
      1,
      12,
      0,
      0
    );
    Account testAccount = createTestAccount();

    string purpose = 'Financial Wellbeing';

    Interaction testInteraction = new Interaction(
      AccountId = testAccount.Id,
      StartTime = startDate,
      Interaction_Purpose__c = purpose
    );
    insert testInteraction;

    testInteraction = [
      SELECT Id, AccountId, StartTime, Interaction_Purpose__c, Status__c
      FROM Interaction
      WHERE Id = :testInteraction.Id
    ];

    System.assertEquals(
      'Unassigned',
      testInteraction.Status__c,
      'A newly created interaction should be unassigned'
    );

    test.startTest();
    Interaction testInteraction2 = new Interaction(
      AccountId = testAccount.Id,
      StartTime = startDate,
      Interaction_Purpose__c = purpose
    );
    Exception thrownException;
    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    test.stopTest();
    System.assertEquals(
      null,
      testInteraction2.Id,
      'The Account cannot have two interactions at the same time'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have occured as the customer should not have two interactions booked at the same time'
    );

    thrownException = null;
    testInteraction.Status__c = 'Scheduled';
    update testInteraction;

    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertEquals(
      null,
      testInteraction2.Id,
      'ID must not be set as this means it exists'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have occured as the customer should not have two interactions booked at the same time'
    );

    thrownException = null;
    testInteraction.Status__c = 'Rescheduled';
    update testInteraction;

    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertEquals(
      null,
      testInteraction2.Id,
      'ID must not be set as this means it exists'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have occured as the customer should not have two interactions booked at the same time'
    );

    thrownException = null;
    testInteraction.Status__c = 'Walk In';
    update testInteraction;

    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertEquals(
      null,
      testInteraction2.Id,
      'ID must not be set as this means it exists'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have occured as the customer should not have two interactions booked at the same time'
    );

    thrownException = null;
    testInteraction.Status__c = 'Cancelled';
    update testInteraction;

    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertNotEquals(
      null,
      testInteraction2.Id,
      'ID must be set as this means it exists'
    );

    System.assertEquals(
      null,
      thrownException,
      'No exception should have occured as the customer should can have two interactions booked at the same time if one is cancelled'
    );

    ContactRequest request = new ContactRequest(
      WhoId = testAccount.PersonContactId,
      Appointment_date_and_Time__c = startDate,
      RequestReason = purpose
    );

    thrownException = null;
    try {
      insert request;
    } catch (Exception exc) {
      thrownException = exc;
    }

    System.assertEquals(
      null,
      request.Id,
      'ID must not be set as this means it exists'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have occured as the customer should not have two interactions booked at the same time'
    );
  }

  /**
   * @description  As a coach lead, I have a rescheduled (Rescheduled Status) appointment (IR-00000166)
   * with Pete from 1:00am-1:30am on 16/06/2022, but I have successfully accepted another appointment
   * with David from 12:30am - 1:15am on the same day which has 15 mins overlap.*/
  @isTest
  static void test48304Issue4() {
    Integer year = DateTime.now().year() + 1;
    String purpose = 'Financial Wellbeing';

    //Pete Account
    Account peteAccount = createTestAccount('Pete', 'Account');

    DateTime peteStartTime = DateTime.newInstance(year, 6, 16, 1, 0, 0);

    //Rescheduled Appointment.
    Interaction peteInteraction = new Interaction(
      Name = 'Pete Interaction',
      AccountId = peteAccount.Id,
      StartTime = peteStartTime,
      Interaction_Purpose__c = 'Other'
    );
    insert peteInteraction;

    peteInteraction.OwnerId = UserInfo.getUserId();
    update peteInteraction;

    DateTime expectedPeteEndDate = DateTime.newInstance(year, 6, 16, 1, 30, 0);
    peteInteraction = [
      SELECT Id, EndTime
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      expectedPeteEndDate,
      peteInteraction.EndTime,
      'Make sure the date is set as expected.'
    );

    peteInteraction.Status__c = InteractionActions.RESCHEDULED_STATUS;
    update peteInteraction;

    peteInteraction = [
      SELECT Id, Status__c
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      InteractionActions.RESCHEDULED_STATUS,
      peteInteraction.Status__c,
      'Status must be Rescheduled for this to work'
    );

    //David Interaction
    Account davidAccount = createTestAccount('David', 'Person');

    DateTime davidStartTime = DateTime.newInstance(year, 6, 16, 0, 30, 0);

    DateTime davidExpectedEndTime = DateTime.newInstance(year, 6, 16, 1, 15, 0);

    Interaction davidInteraction = new Interaction(
      Name = 'David Interaction',
      AccountId = davidAccount.Id,
      StartTime = davidStartTime,
      Interaction_Purpose__c = purpose
    );
    insert davidInteraction;

    test.startTest();
    davidInteraction.OwnerId = UserInfo.getUserId();

    Exception thrownException;
    try {
      update davidInteraction;
    } catch (Exception exc) {
      thrownException = exc;
    }
    test.stopTest();

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown as these two dates overlap.'
    );
  }

  @isTest
  static void test48304Issue4ChangingTime() {
    Integer year = DateTime.now().year() + 1;
    String purpose = 'Financial Wellbeing';

    //Pete Account
    Account peteAccount = createTestAccount('Pete', 'Account');

    DateTime peteStartTime = DateTime.newInstance(year, 6, 15, 1, 0, 0);

    //Rescheduled Appointment.
    Interaction peteInteraction = new Interaction(
      Name = 'Pete Interaction',
      AccountId = peteAccount.Id,
      StartTime = peteStartTime,
      Interaction_Purpose__c = 'Other'
    );
    insert peteInteraction;

    peteInteraction.OwnerId = UserInfo.getUserId();
    update peteInteraction;

    DateTime expectedPeteEndDate = DateTime.newInstance(year, 6, 15, 1, 30, 0);
    peteInteraction = [
      SELECT Id, EndTime
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      expectedPeteEndDate,
      peteInteraction.EndTime,
      'Make sure the date is set as expected.'
    );

    DateTime peteNewStartTime = DateTime.newInstance(year, 6, 16, 1, 0, 0);
    peteInteraction.Status__c = InteractionActions.RESCHEDULED_STATUS;
    peteInteraction.StartTime = peteNewStartTime;
    update peteInteraction;

    peteInteraction = [
      SELECT Id, Status__c
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      InteractionActions.RESCHEDULED_STATUS,
      peteInteraction.Status__c,
      'Status must be Rescheduled for this to work'
    );

    //David Interaction
    Account davidAccount = createTestAccount('David', 'Person');

    DateTime davidStartTime = DateTime.newInstance(year, 6, 16, 0, 30, 0);

    DateTime davidExpectedEndTime = DateTime.newInstance(year, 6, 16, 1, 15, 0);

    Interaction davidInteraction = new Interaction(
      Name = 'David Interaction',
      AccountId = davidAccount.Id,
      StartTime = davidStartTime,
      Interaction_Purpose__c = purpose
    );
    insert davidInteraction;

    test.startTest();
    davidInteraction.OwnerId = UserInfo.getUserId();

    Exception thrownException;
    try {
      update davidInteraction;
    } catch (Exception exc) {
      thrownException = exc;
    }
    test.stopTest();

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown as these two dates overlap.'
    );
  }

  /**
   * @description helper method to create a person account
   * @return Account a Person Account with Name Fred Smith, OCV ID 123456
   */
  static Account createTestAccount() {
    return createTestAccount(FIRST_NAME, LAST_NAME);
  }

  /**
   * @description creates a testAccount
   * @param firstName First Name to put on the account
   * @param lastName Last Name to put on the account
   * @return Account newly created account
   */
  public static Account createTestAccount(String firstName, String lastName) {
    Faker faker = new Faker('AU');
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = FIRST_NAME;
    testAccount.LastName = LAST_NAME;
    testAccount.OCV_ID__c = faker.randomString(10);
    testAccount.PersonMobilePhone = PHONE_NUMBER;
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
