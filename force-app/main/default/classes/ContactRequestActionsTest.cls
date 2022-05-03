@isTest
public with sharing class ContactRequestActionsTest {
  private static string contactRequestQueueName = 'Contact Request';
  private static string appointmentQueueName = 'Appointments Queue';
  private static string otherPurposeName = 'Other';
  private static string financialWellbeingPurposeName = 'Financial Wellbeing';
  private static string defaultInteractionStatus = 'Unassigned';
  private static string appointmentRTName = 'Appointment';

  private static Integer otherPurposeDuration = 30;
  private static Integer financialWellbeingPurposeDuration = 45;

  //Number of minutes before an event to set the reminder
  private static Integer reminderMinutes = 15;

  @testSetup
  static void loadAutomatedPurposes() {
    setup();
  }
  static void setup() {
    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;

    Automated_Request_Purpose__mdt financialWellbeingPurpose = new Automated_Request_Purpose__mdt();
    financialWellbeingPurpose.MasterLabel = financialWellbeingPurposeName;
    financialWellbeingPurpose.Duration__c = financialWellbeingPurposeDuration;

    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    purposeMap.put(financialWellbeingPurposeName, financialWellbeingPurpose);

    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);
  }

  @isTest
  static void testFindZeroRequestsThatNowBelongToUser() {
    setup();
    Account testAccount = createTestAccount();

    DateTime start = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);
    ContactRequest request = new ContactRequest();
    request.PreferredChannel = 'Call';
    request.Appointment_date_and_Time__c = start;
    request.WhoId = testAccount.PersonContactId;
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(request.Id, request);

    List<ContactRequest> requests = contactRequestActionHelper
      .findRequestsThatNowBelongToUser(oldMap, new List<SObject>{ request });

    System.assertEquals(0, requests.size(), 'Should not return any requests');
  }

  @isTest
  static void testFindRequestsThatNowBelongToUser() {
    setup();
    Account testAccount = createTestAccount();

    DateTime start = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);

    QueueSObject contactRequestQueue = getQueue(contactRequestQueueName);

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue.Queue.Id;
    request.PreferredChannel = 'Call';
    request.Appointment_date_and_Time__c = start;
    request.WhoId = testAccount.PersonContactId;
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(request.Id, request);

    ContactRequest newRequest = new ContactRequest(
      OwnerId = UserInfo.getUserId(),
      Id = request.Id
    );

    List<SObject> records = new List<SObject>();
    records.add(newRequest);

    List<ContactRequest> requests = contactRequestActionHelper
      .findRequestsThatNowBelongToUser(oldMap, records);

    System.assertEquals(1, requests.size(), 'Should return a request');
  }

  @isTest
  static void testOnlyGoingFromContactRequestQueueTriggers() {
    setup();
    Account testAccount = createTestAccount();

    DateTime start = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);

    QueueSObject contactRequestQueue = getQueue(contactRequestQueueName);

    ContactRequest okRequest = new ContactRequest();
    okRequest.OwnerId = contactRequestQueue.Queue.Id;
    okRequest.PreferredChannel = 'Call';
    okRequest.Appointment_date_and_Time__c = start;
    okRequest.WhoId = testAccount.PersonContactId;

    ContactRequest notOkRequest = new ContactRequest();
    notOkRequest.PreferredChannel = 'Call';
    notOkRequest.Appointment_date_and_Time__c = start;
    notOkRequest.WhoId = testAccount.PersonContactId;

    List<ContactRequest> requests = new List<ContactRequest>{
      okRequest,
      notOkRequest
    };
    insert requests;

    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(okRequest.Id, okRequest);
    oldMap.put(notOkRequest.Id, notOkRequest);

    List<ContactRequest> newRequests = new List<ContactRequest>();
    for (ContactRequest request : requests) {
      ContactRequest newRequest = new ContactRequest(
        OwnerId = UserInfo.getUserId(),
        Id = request.Id
      );
      newRequests.add(newRequest);
    }

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    List<ContactRequest> okRequests = contactRequestActionHelper.findRequestsThatNowBelongToUser(
      oldMap,
      newRequests
    );

    system.assertEquals(1, okRequests.size(), 'Should only be one ok request');
  }

  @isTest
  static void testDirectionChoice() {
    ContactRequestActions actions = new ContactRequestActions();

    String direction = actions.getDirection('Call');

    System.assertEquals(
      'Outbound',
      direction,
      'Direction must be Outbound when channel is Call'
    );

    direction = actions.getDirection('Store');
    System.assertEquals(
      '',
      direction,
      'Direction must be blank when channel is Store'
    );
  }

  @isTest
  static void testCreateInteractionFromRequest() {
    setup();
    Account testAccount = createTestAccount();

    string requestReason = financialWellbeingPurposeName;

    Integer duration = financialWellbeingPurposeDuration;

    DateTime appointmentDate = DateTime.now();
    DateTime expectedEndDate = appointmentDate.addMinutes(duration);

    Id appointmentRecordTypeId = Schema.SObjectType.Interaction.getRecordTypeInfosByName()
      .get(appointmentRTName)
      .getRecordTypeId();

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = requestReason;
    request.WhoId = testAccount.PersonContactId;
    request.RequestDescription = 'Test';
    request.PreferredChannel = 'Call';
    request.Channel_Booked__c = 'Chat';
    Test.startTest();
    insert request;
    Test.stopTest();

    List<Interaction> interactions = [
      SELECT
        Id,
        Status__c,
        Interaction_Purpose__c,
        StartTime,
        AccountId,
        EndTime,
        Description,
        Name,
        ContactRequestId__c,
        Direction__c,
        OwnerId,
        RecordTypeId,
        InteractionType,
        Channel_Booked__c
      FROM Interaction
    ];
    System.assertEquals(
      1,
      interactions.size(),
      'An interaction should have been created'
    );

    Interaction newInteraction = interactions[0];

    System.assertNotEquals(
      null,
      newInteraction,
      'A new Interaction should be created'
    );

    System.assertEquals(
      defaultInteractionStatus,
      newInteraction.Status__c,
      'Interaction Status must default to Unassigned'
    );

    System.assertEquals(
      requestReason,
      newInteraction.Interaction_Purpose__c,
      'Interaction Purpose should match Contact Request Reason'
    );

    System.assertEquals(
      request.Appointment_date_and_Time__c,
      newInteraction.StartTime,
      'Interaction Start time should match the request appointment date time'
    );

    System.assertEquals(
      testAccount.Id,
      newInteraction.AccountId,
      'Interactions account must equal the contact requests account'
    );

    System.assertEquals(
      expectedEndDate,
      newInteraction.EndTime,
      'The end time of the interaction must be ' +
      duration +
      ' minutes after the start time ' +
      appointmentDate
    );

    System.assertEquals(
      'Test',
      newInteraction.Description,
      'Description on the Interaction must match that of the request.'
    );

    System.assertEquals(
      'Outbound',
      newInteraction.Direction__c,
      'Direction must be "Outbound"'
    );

    string expectedName = requestReason + ' Appointment';
    System.assertEquals(
      expectedName,
      newInteraction.Name,
      'Name should match the Request Reason + " Appointment"'
    );

    System.assertEquals(
      request.Id,
      newInteraction.ContactRequestId__c,
      'Contact Request Id must be populated on Interaction'
    );

    QueueSObject appointmentQueue = getQueue(appointmentQueueName);

    System.assertEquals(
      appointmentQueue.Queue.Id,
      newInteraction.OwnerId,
      'Newly created Interaction must be owned by the queue.'
    );

    System.assertEquals(
      appointmentRecordTypeId,
      newInteraction.RecordTypeId,
      'Record Type must be Appointment'
    );

    System.assertEquals(
      request.PreferredChannel,
      newInteraction.InteractionType,
      'The Interaction Type must match the requests preferred channel'
    );

    System.assertEquals(
      request.Channel_Booked__c,
      newInteraction.Channel_Booked__c,
      'The Interaction Channel Booked field must match the Requests'
    );
  }

  @isTest
  static void testCreateInteractionFromRequestAndInsert() {
    setup();
    Account testAccount = createTestAccount();

    string requestReason = financialWellbeingPurposeName;

    Integer duration = financialWellbeingPurposeDuration;

    DateTime appointmentDate = DateTime.now();
    DateTime expectedEndDate = appointmentDate.addMinutes(duration);

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = requestReason;
    request.WhoId = testAccount.PersonContactId;
    request.RequestDescription = 'Test';
    request.PreferredChannel = 'Call';
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Interaction newInteraction = contactRequestActionHelper.createInteractionFromRequest(
      request
    );

    newInteraction.ContactRequestId__c = null;

    insert newInteraction;

    List<Interaction> newInteractions = [SELECT Id FROM Interaction];
    System.assertEquals(
      2,
      newInteractions.size(),
      'Should have inserted an interaction'
    );
  }

  @isTest
  static void testCreateInteractionFromRequestForLead() {
    setup();
    Lead testLead = createTestLead();

    string requestReason = financialWellbeingPurposeName;

    Integer duration = financialWellbeingPurposeDuration;

    DateTime appointmentDate = DateTime.now();
    DateTime expectedEndDate = appointmentDate.addMinutes(duration);

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = requestReason;
    request.WhoId = testLead.Id;
    request.RequestDescription = 'Test';
    request.PreferredChannel = 'Call';
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Test.startTest();

    Interaction newInteraction = contactRequestActionHelper.createInteractionFromRequest(
      request
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      newInteraction,
      'A new Interaction should be created'
    );

    System.assertEquals(
      defaultInteractionStatus,
      newInteraction.Status__c,
      'Interaction Status must default to Unassigned'
    );

    System.assertEquals(
      requestReason,
      newInteraction.Interaction_Purpose__c,
      'Interaction Purpose should match Contact Request Reason'
    );

    System.assertEquals(
      request.Appointment_date_and_Time__c,
      newInteraction.StartTime,
      'Interaction Start time should match the request appointment date time'
    );

    System.assertEquals(
      testLead.Id,
      newInteraction.Lead__c,
      'Interactions Lead must equal the contact requests Lead record'
    );

    System.assertEquals(
      expectedEndDate,
      newInteraction.EndTime,
      'The end time of the interaction must be ' +
      duration +
      ' minutes after the start time ' +
      appointmentDate
    );

    System.assertEquals(
      'Test',
      newInteraction.Description,
      'Description on the Interaction must match that of the request.'
    );

    System.assertEquals(
      'Outbound',
      newInteraction.Direction__c,
      'Direction must be "Outbound"'
    );

    string expectedName = requestReason + ' Appointment';
    System.assertEquals(
      expectedName,
      newInteraction.Name,
      'Name should match the Request Reason + " Appointment"'
    );
  }

  @isTest
  static void testHandleNullAppointmentDate() {
    setup();
    Account testAccount = createTestAccount();

    string requestReason = financialWellbeingPurposeName;

    Integer duration = financialWellbeingPurposeDuration;

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = null;
    request.RequestReason = requestReason;
    request.WhoId = testAccount.PersonContactId;
    request.RequestDescription = 'Test';
    request.PreferredChannel = 'Call';

    Boolean exceptionThrown = false;
    try {
      insert request;
    } catch (Exception exc) {
      exceptionThrown = true;
    }

    System.assertEquals(
      true,
      exceptionThrown,
      'An exception should be thrown if you try to create a Contact Request with no appointment date'
    );
  }

  @isTest
  static void testAutomatedPurposeCheck() {
    setup();
    Account testAccount = createTestAccount();
    string nonAutomatedPurposeName = 'Financial Wellbeing';
    string automatedPurposeName = 'Other';

    Automated_Request_Purpose__mdt notautomatedPurpose = new Automated_Request_Purpose__mdt();
    notautomatedPurpose.MasterLabel = nonAutomatedPurposeName;

    Automated_Request_Purpose__mdt automatedPurpose = new Automated_Request_Purpose__mdt();
    automatedPurpose.MasterLabel = automatedPurposeName;
    automatedPurpose.Duration__c = otherPurposeDuration;

    ContactRequest autoRequest = new ContactRequest();
    autoRequest.RequestReason = automatedPurposeName;
    autoRequest.Appointment_date_and_Time__c = DateTime.now();
    autoRequest.PreferredChannel = 'Call';
    autoRequest.WhoId = testAccount.PersonContactId;

    ContactRequest notAutoRequest = new ContactRequest();
    notAutoRequest.RequestReason = nonAutomatedPurposeName;
    notAutoRequest.Appointment_date_and_Time__c = DateTime.now();
    notAutoRequest.PreferredChannel = 'Call';
    notAutoRequest.WhoId = testAccount.PersonContactId;

    List<ContactRequest> requests = new List<ContactRequest>();
    requests.add(autoRequest);
    requests.add(notAutoRequest);
    insert requests;

    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(automatedPurposeName, automatedPurpose);

    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    List<ContactRequest> requestsWithAutomatedPurpose = contactRequestActionHelper.returnRequestsWithAutomatedPurpose(
      requests
    );

    System.assertEquals(
      1,
      requestsWithAutomatedPurpose.size(),
      'Should only return one request'
    );

    List<ContactRequest> processedRequests = contactRequestActionHelper.acceptContactRequests(
      requests
    );
    System.assertEquals(
      1,
      processedRequests.size(),
      'One request should have been processed'
    );
  }

  @isTest
  static void getWhoIdContactMap() {
    Account testAccount = createTestAccount();
    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    string requestReason = 'Financial Wellbeing';

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = DateTime.now();
    request.RequestReason = requestReason;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = 'Call';
    insert request;

    Map<Id, Id> contactIdAccountIdMap = contactRequestActionHelper.getWhoIdAccountMap(
      new List<ContactRequest>{ request }
    );

    System.AssertNotEquals(
      null,
      contactIdAccountIdMap,
      'A map should be returned'
    );

    System.AssertEquals(
      true,
      contactIdAccountIdMap.containsKey(testAccount.PersonContactId),
      'The contact Id should be present as a key'
    );

    System.AssertEquals(
      testAccount.Id,
      contactIdAccountIdMap.get(testAccount.PersonContactId),
      'The account Id should be that of the account'
    );
  }

  @isTest
  static void testEventCreation() {
    setup();
    DateTime appointmentDateTime = DateTime.Now();
    DateTime endDateTime = appointmentDateTime.addMinutes(otherPurposeDuration);

    Account testAccount = createTestAccount();

    Interaction testInteraction = new Interaction();
    testInteraction.Name = otherPurposeName + ' Appointment';
    testInteraction.AccountId = testAccount.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    insert testInteraction;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Event testEvent = contactRequestActionHelper.createEventFromInteraction(
      testInteraction
    );

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
    testInteraction.Name = otherPurposeName + ' Appointment';
    testInteraction.Lead__c = testLead.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    testInteraction.Interaction_Purpose__c = otherPurposeName;
    insert testInteraction;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Event testEvent = contactRequestActionHelper.createEventFromInteraction(
      testInteraction
    );

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

  @isTest
  static void testCreateInteractionSummaryForLead() {
    setup();

    DateTime appointmentDateTime = DateTime.Now();
    DateTime endDateTime = appointmentDateTime.addMinutes(otherPurposeDuration);

    Lead testLead = createTestLead();

    List<InteractionSummary> summaries = [SELECT Id FROM InteractionSummary];

    system.assertEquals(
      0,
      summaries.size(),
      'No interaction summary should be available'
    );

    Interaction testInteraction = new Interaction();
    testInteraction.Name = otherPurposeName + ' Appointment';
    testInteraction.Lead__c = testLead.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    testInteraction.Interaction_Purpose__c = otherPurposeName;
    insert testInteraction;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    InteractionSummary testInteractionSummary = contactRequestActionHelper.createInteractionSummaryFromInteraction(
      testInteraction
    );

    summaries = [SELECT Id FROM InteractionSummary];

    system.assertNotEquals(null, summaries, 'Summaries should not be null');
    system.assertNotEquals(
      0,
      summaries.size(),
      'At least 1 summary must be created'
    );

    System.assertNotEquals(
      null,
      testInteractionSummary,
      'Must return an Interaction Summary'
    );

    System.assertEquals(
      otherPurposeName + ' Appointment Summary',
      testInteractionSummary.Name,
      'Interaction Summary Name must be the purpose + Appointment Summary'
    );

    System.assertEquals(
      'In Progress',
      testInteractionSummary.Status,
      'Status must equal In Progress'
    );

    System.assertEquals(
      testInteraction.Id,
      testInteractionSummary.InteractionId,
      'Interaction must be set on the Interaction Summary'
    );

    System.assertEquals(
      testInteraction.OwnerId,
      testInteractionSummary.OwnerId,
      'Owner Id must be set on the Interactions OwnerId'
    );

    System.assertEquals(
      '',
      testInteractionSummary.Meeting_Notes__c,
      'Meeting Notes must be blank'
    );
  }

  @isTest
  static void testCreateInteractionSummary() {
    setup();

    DateTime appointmentDateTime = DateTime.Now();
    DateTime endDateTime = appointmentDateTime.addMinutes(otherPurposeDuration);

    Account testAccount = createTestAccount();

    Interaction testInteraction = new Interaction();
    testInteraction.Name = otherPurposeName + ' Appointment';
    testInteraction.AccountId = testAccount.Id;
    testInteraction.StartTime = appointmentDateTime;
    testInteraction.EndTime = endDateTime;
    testInteraction.Interaction_Purpose__c = otherPurposeName;
    insert testInteraction;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    InteractionSummary testInteractionSummary = contactRequestActionHelper.createInteractionSummaryFromInteraction(
      testInteraction
    );

    System.assertNotEquals(
      null,
      testInteractionSummary,
      'Must return an Interaction Summary'
    );

    System.assertEquals(
      otherPurposeName + ' Appointment Summary',
      testInteractionSummary.Name,
      'Interaction Summary Name must be the purpose + Appointment Summary'
    );

    System.assertEquals(
      'In Progress',
      testInteractionSummary.Status,
      'Status must equal In Progress'
    );

    System.assertEquals(
      testInteraction.Id,
      testInteractionSummary.InteractionId,
      'Interaction must be set on the Interaction Summary'
    );

    System.assertEquals(
      testInteraction.AccountId,
      testInteractionSummary.AccountId,
      'Account must be set on the Interactions Account'
    );

    System.assertEquals(
      testInteraction.OwnerId,
      testInteractionSummary.OwnerId,
      'Owner Id must be set on the Interactions OwnerId'
    );

    System.assertEquals(
      '',
      testInteractionSummary.Meeting_Notes__c,
      'Meeting Notes must be blank'
    );
  }

  @isTest
  static void testGettingDuration() {
    setup();
    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Integer testOtherDuration = contactRequestActionHelper.getDuration(
      otherPurposeName
    );
    Integer testFWDuration = contactRequestActionHelper.getDuration(
      financialWellbeingPurposeName
    );

    System.assertEquals(
      otherPurposeDuration,
      testOtherDuration,
      'Other duration should be 30 minutes'
    );

    System.assertEquals(
      financialWellbeingPurposeDuration,
      testFWDuration,
      'Financial Wellbeing duration should be 45 minutes'
    );

    Integer nonExistantReasonDuration = contactRequestActionHelper.getDuration(
      'DOESNOTEXIST'
    );

    System.assertEquals(
      0,
      nonExistantReasonDuration,
      'If the reason doesnt exist, 0 should be returned'
    );
  }

  @isTest
  static void returnInteractionsWithAutomatedPurpose() {
    setup();
    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Interaction automatedInteraction = new Interaction(
      Interaction_Purpose__c = otherPurposeName
    );
    Interaction nonAutomatedInteraction = new Interaction(
      Interaction_Purpose__c = 'NotAutomated'
    );

    List<Interaction> interactions = new List<Interaction>{
      automatedInteraction,
      nonAutomatedInteraction
    };

    test.startTest();
    List<Interaction> automatedInteractions = contactRequestActionHelper.returnInteractionsWithAutomatedPurpose(
      interactions
    );
    test.stopTest();

    system.assertEquals(
      1,
      automatedInteractions.size(),
      'Should only return automated interactions'
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
    testAccount.RecordTypeId = personAccountRecordTypeId;
    insert testAccount;

    testAccount = [
      SELECT Id, PersonContactId
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

  /**
   * @description gets a queue by name
   * @param name string name of the queue to retrieve
   * @return QueueSObject the instance of the found queue.
   */
  static QueueSObject getQueue(string name) {
    List<QueueSObject> foundQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :name
    ];

    return foundQueue[0];
  }
}
