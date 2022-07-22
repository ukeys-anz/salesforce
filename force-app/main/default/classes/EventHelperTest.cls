/**
 * @author Adam Smith
 * @since 20220617
 * @description Test Class for Event Helper class for working with events
 */
@isTest
public with sharing class EventHelperTest {
  private static string contactRequestQueueName = 'Contact Request';
  private static string appointmentQueueName = 'Appointments Queue';

  private static Integer otherPurposeDuration = 30;
  private static Integer financialWellbeingPurposeDuration = 45;

  //Number of minutes before an event to set the reminder
  private static Integer reminderMinutes = 15;

  static void setup() {
    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = InteractionConstants.OTHER_PURPOSE_NAME;
    otherPurpose.Duration__c = otherPurposeDuration;

    Automated_Request_Purpose__mdt financialWellbeingPurpose = new Automated_Request_Purpose__mdt();
    financialWellbeingPurpose.MasterLabel = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    financialWellbeingPurpose.Duration__c = financialWellbeingPurposeDuration;

    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(InteractionConstants.OTHER_PURPOSE_NAME, otherPurpose);
    purposeMap.put(
      InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      financialWellbeingPurpose
    );

    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);
  }

  @isTest
  static void testEventCreation() {
    setup();
    DateTime appointmentDateTime = DateTime.Now();
    DateTime endDateTime = appointmentDateTime.addMinutes(otherPurposeDuration);

    Account testAccount = createTestAccount();

    Interaction testInteraction = new Interaction();
    testInteraction.RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID;
    testInteraction.Name =
      InteractionConstants.OTHER_PURPOSE_NAME + ' Appointment';
    testInteraction.AccountId = testAccount.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    insert testInteraction;

    Event testEvent = EventHelper.createEventFromInteraction(testInteraction);

    System.assertNotEquals(null, testEvent, 'Must return an Event');

    String expectedName = 'Appointment with Fred Smith';
    System.assertEquals(
      expectedName,
      testEvent.Subject,
      'Subject must match the expected Name'
    );

    System.assertEquals(
      appointmentDateTime,
      testEvent.StartDateTime,
      'Event start time should be the same as the interactions'
    );

    Id eventWhoId = testEvent.WhoId;
    System.assertEquals(
      testAccount.PersonContactId,
      eventWhoId,
      'Name should link to the PersonContact'
    );

    System.assertEquals(
      testInteraction.Id,
      testEvent.WhatId,
      'Interaction should be mapped with the whatId of the Event'
    );

    System.assertEquals(
      testInteraction.OwnerId,
      testEvent.OwnerId,
      'Owner Id of Event must match the Interactions'
    );

    System.assertEquals(
      endDateTime,
      testEvent.EndDateTime,
      'The End Date of the Event must match the Interactions End Date'
    );

    System.assertEquals(
      true,
      testEvent.IsReminderSet,
      'Reminder should be set to true'
    );

    DateTime expectedReminderDate = appointmentDateTime.addMinutes(
      -1 * reminderMinutes
    );

    System.assertEquals(
      expectedReminderDate,
      testEvent.ReminderDateTime,
      'Reminder should be 15 minutes before the start time'
    );
  }

  @isTest
  static void testEventCreationForLead() {
    setup();
    DateTime appointmentDateTime = DateTime.Now();
    DateTime endDateTime = appointmentDateTime.addMinutes(otherPurposeDuration);

    Lead testLead = createTestLead();

    List<Event> events = [SELECT Id FROM Event];

    system.assertEquals(0, events.size(), 'No events should be available');

    Interaction testInteraction = new Interaction();
    testInteraction.RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID;
    testInteraction.Name =
      InteractionConstants.OTHER_PURPOSE_NAME + ' Appointment';
    testInteraction.Lead__c = testLead.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    testInteraction.Interaction_Purpose__c = InteractionConstants.OTHER_PURPOSE_NAME;
    insert testInteraction;

    Event testEvent = EventHelper.createEventFromInteraction(testInteraction);

    events = [SELECT Id FROM Event];

    system.assertEquals(
      true,
      events.isEmpty(),
      'Events should not be created at this stage'
    );

    System.assertNotEquals(null, testEvent, 'Must return an Event');

    String expectedName = 'Appointment with Test CR Lead';
    System.assertEquals(
      expectedName,
      testEvent.Subject,
      'Subject must match the expected Name'
    );

    System.assertEquals(
      appointmentDateTime,
      testEvent.StartDateTime,
      'Event start time should be the same as the interactions'
    );

    Id eventWhoId = testEvent.Lead__c;
    System.assertEquals(
      testLead.Id,
      eventWhoId,
      'The Lead Id should match with the Lead created'
    );

    System.assertEquals(
      testInteraction.OwnerId,
      testEvent.OwnerId,
      'Owner Id of Event must match the Interactions'
    );

    System.assertEquals(
      testInteraction.Id,
      testEvent.WhatId,
      'Interaction should be mapped with the whatId of the Event'
    );

    System.assertEquals(
      endDateTime,
      testEvent.EndDateTime,
      'The End Date of the Event must match the Interactions End Date'
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

  /**
   * @description helper method to create a test lead record
   * @return a Lead with name as Test Lead for Contact Request
   */
  static Lead createTestLead() {
    Id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('General')
      .getRecordTypeId();

    Lead testLead = new Lead();
    testLead.LastName = 'Test CR Lead';
    testLead.Company = 'Test CR Lead';
    testLead.RecordTypeId = leadRecordTypeId;
    insert testLead;

    testLead = [SELECT ID FROM Lead WHERE ID = :testLead.Id];

    return testLead;
  }
}
