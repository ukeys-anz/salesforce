/**
 * @description Test intercept for existing interactions
 * @author Adam Phillip Smith
 * @since 20220527
 */
@isTest
public with sharing class InteractionInterceptTest {
  static final String CANCELLED = 'Cancelled';
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

    string purpose = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;

    Interaction testInteraction = createTestInteraction(
      startDate,
      purpose,
      testAccount
    );
    insert testInteraction;

    testInteraction = [
      SELECT Id, AccountId, StartTime, Interaction_Purpose__c, Status__c
      FROM Interaction
      WHERE Id = :testInteraction.Id
    ];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction.Status__c,
      'A newly created interaction should be unassigned'
    );

    test.startTest();
    Interaction testInteraction2 = createTestInteraction(
      startDate,
      purpose,
      testAccount
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
    testInteraction.Status__c = InteractionConstants.SCHEDULED_STATUS;
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
    testInteraction.Status__c = InteractionConstants.RESCHEDULED_STATUS;
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
    testInteraction.Status__c = InteractionConstants.WALKIN_STATUS;
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
    testInteraction.Status__c = CANCELLED;
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
    Faker faker = new Faker('AU');
    Integer year = DateTime.now().year() + 1;
    String purpose = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;

    //Pete Account
    Account peteAccount = createTestAccount();

    DateTime peteStartTime = DateTime.newInstance(year, 6, 16, 1, 0, 0);

    //Rescheduled Appointment.
    Interaction peteInteraction = createTestInteraction(
      peteStartTime,
      InteractionConstants.OTHER_PURPOSE_NAME,
      peteAccount
    );
    peteInteraction.Name = faker.randomString(10);
    peteInteraction.AccountId = peteAccount.Id;
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

    peteInteraction.Status__c = InteractionConstants.RESCHEDULED_STATUS;
    update peteInteraction;

    peteInteraction = [
      SELECT Id, Status__c
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      InteractionConstants.RESCHEDULED_STATUS,
      peteInteraction.Status__c,
      'Status must be Rescheduled for this to work'
    );

    //David Interaction
    Account davidAccount = createTestAccount();
    DateTime davidStartTime = DateTime.newInstance(year, 6, 16, 0, 30, 0);

    Interaction davidInteraction = createTestInteraction(
      davidStartTime,
      purpose,
      davidAccount
    );
    davidInteraction.Name = faker.randomString(10);
    davidInteraction.AccountId = davidAccount.Id;
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
    Faker faker = new Faker('AU');
    Integer year = DateTime.now().year() + 1;
    String purpose = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;

    //Pete Account
    Account peteAccount = createTestAccount();

    DateTime peteStartTime = DateTime.newInstance(year, 6, 15, 1, 0, 0);

    //Rescheduled Appointment.
    Interaction peteInteraction = createTestInteraction(
      peteStartTime,
      InteractionConstants.OTHER_PURPOSE_NAME,
      peteAccount
    );
    peteInteraction.Name = faker.randomString(10);
    peteInteraction.AccountId = peteAccount.Id;
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
    peteInteraction.Status__c = InteractionConstants.RESCHEDULED_STATUS;
    peteInteraction.StartTime = peteNewStartTime;
    update peteInteraction;

    peteInteraction = [
      SELECT Id, Status__c
      FROM Interaction
      WHERE Id = :peteInteraction.Id
    ];
    System.assertEquals(
      InteractionConstants.RESCHEDULED_STATUS,
      peteInteraction.Status__c,
      'Status must be Rescheduled for this to work'
    );

    //David Interaction
    Account davidAccount = createTestAccount();

    DateTime davidStartTime = DateTime.newInstance(year, 6, 16, 0, 30, 0);

    Interaction davidInteraction = createTestInteraction(
      davidStartTime,
      purpose,
      davidAccount
    );
    davidInteraction.Name = faker.randomString(10);
    davidInteraction.AccountId = davidAccount.Id;
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
    Faker faker = new Faker('AU');
    return createTestAccount(faker.randomString(5), faker.randomString(5));
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
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = faker.randomString(10);
    testAccount.PersonMobilePhone = String.valueOf(faker.randomDecimal(10, 0));
    testAccount.RecordTypeId = personAccountRecordTypeId;
    insert testAccount;

    testAccount = [
      SELECT Id, PersonContactId, PersonMobilePhone
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    return testAccount;
  }

  /**
   * @description creates an test appointment interaction with all required fields
   * @param startTime Appointment start time
   * @param purpose Interaction Purpose
   * @param account account Id
   * @return an appointment interaction type
   */
  private static Interaction createTestInteraction(
    DateTime startTime,
    String purpose,
    Account account
  ) {
    Interaction testAppointment = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = account.Id,
      StartTime = startTime,
      Interaction_Purpose__c = purpose,
      InteractionType = InteractionConstants.CALL
    );
    return testAppointment;
  }
}
