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
  private static string appointmentRTName = 'Appointment';

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
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount.Id,
      StartTime = startDate,
      Interaction_Purpose__c = purpose
    );
    insert testInteraction;

    testInteraction.Status__c = 'Unassigned';
    update testInteraction;

    test.startTest();
    Interaction testInteraction2 = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
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
      'ID must not be set as this means it exists'
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
   * @description helper method to create a person account
   * @return Account a Person Account with Name Fred Smith, OCV ID 123456
   */
  static Account createTestAccount() {
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
