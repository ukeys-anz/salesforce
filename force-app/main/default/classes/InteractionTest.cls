/**
 * @description tests for Interactions
 * @since 2022-05-30
 * @author Adam Phillip Smith
 */
@isTest
public with sharing class InteractionTest {
  @isTest
  static void storeValidationTest() {
    DateTime startDate = DateTime.newInstance(
      DateTime.now().year(),
      1,
      1,
      12,
      0,
      0
    );
    Account testAccount = createTestAccount();

    Schema.Location testLocation = new Schema.Location();
    testLocation.LocationType = 'Store';
    testLocation.Name = 'ANZX Store';
    insert testLocation;

    string purpose = 'Digital Support';

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount.Id,
      StartTime = startDate,
      Interaction_Purpose__c = purpose,
      InteractionType = 'Store',
      LocationId = testLocation.Id
    );

    Exception thrownException;
    try {
      insert testInteraction;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertEquals(
      null,
      thrownException,
      'An exception should not have been thrown.'
    );
    System.assertNotEquals(
      null,
      testInteraction.Id,
      'The Interaction must have an ID set'
    );

    startDate = startDate.addHours(1);

    Interaction testInteraction2 = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount.Id,
      StartTime = startDate,
      Interaction_Purpose__c = purpose,
      InteractionType = 'Store',
      LocationId = null //This is explicitly null as the test is what to do when it is so.
    );

    thrownException = null;
    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown.'
    );
    System.assertEquals(
      null,
      testInteraction2.Id,
      'The Interaction must not have an ID set'
    );

    ContactRequest testRequest = new ContactRequest(
      Appointment_date_and_Time__c = DateTime.now(),
      RequestReason = purpose,
      WhoId = testAccount.PersonContactId,
      PreferredChannel = 'Store',
      Location__c = null //This is explicitly null as the test is what to do when it is so.
    );

    try {
      insert testRequest;
    } catch (Exception exc) {
      thrownException = exc;
    }

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown.'
    );
    System.assertEquals(
      null,
      testRequest.Id,
      'The ContactRequest must not have an ID set'
    );
  }

  /**
   * @description helper method to create a person account
   * @return Account a Person Account with Name Fred Smith, OCV ID 123456
   */
  static Account createTestAccount() {
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = 'Fred';
    testAccount.LastName = 'Smith';
    testAccount.OCV_ID__c = '123456';
    testAccount.PersonMobilePhone = '01189998819991197253';
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
