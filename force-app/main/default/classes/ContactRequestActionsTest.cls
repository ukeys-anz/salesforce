@isTest
public with sharing class ContactRequestActionsTest {
  private static string contactRequestQueueName = 'Contact Request';
  private static string otherPurposeName = 'Other';
  private static string financialWellbeingPurposeName = 'Financial Wellbeing';

  private static Integer otherPurposeDuration = 30;
  private static Integer financialWellbeingPurposeDuration = 45;

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
    ContactRequest request = new ContactRequest();
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
    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    System.AssertEquals(
      1,
      contactRequestQueue.size(),
      'Cannot find the Contact Request Queue'
    );

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue[0].Queue.Id;
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
    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    ContactRequest okRequest = new ContactRequest();
    okRequest.OwnerId = contactRequestQueue[0].Queue.Id;
    ContactRequest notOkRequest = new ContactRequest();
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
  static void testAcceptContactRequest() {
    setup();
    string requestReason = 'Financial Wellbeing';

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = DateTime.now();
    request.RequestReason = requestReason;
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    List<ContactRequest> requests = contactRequestActionHelper
      .acceptContactRequests(new List<ContactRequest>{ request });

    System.assertEquals(1, requests.size(), 'Should return a request');
    System.assertEquals(
      'Accepted',
      requests[0].Status,
      'Status need to be changed to "Accepted"'
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

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = requestReason;
    request.WhoId = testAccount.PersonContactId;
    request.RequestDescription = 'Test';
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Interaction newInteraction = contactRequestActionHelper.createInteractionFromRequest(
      request
    );

    System.assertNotEquals(
      null,
      newInteraction,
      'A new Interaction should be created'
    );

    System.assertEquals(
      'Scheduled',
      newInteraction.Status__c,
      'Interaction Status must default to Scheduled'
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
    insert request;

    ContactRequestActions contactRequestActionHelper = new ContactRequestActions();

    Interaction newInteraction = contactRequestActionHelper.createInteractionFromRequest(
      request
    );

    List<Interaction> interactions = contactRequestActionHelper.createInteractionsFromRequests(
      new List<ContactRequest>{ request }
    );

    System.assertEquals(
      null,
      newInteraction,
      'No Interaction should be created'
    );

    System.assertEquals(
      true,
      interactions.isEmpty(),
      'No Interactions should be created'
    );
  }

  @isTest
  static void testAutomatedPurposeCheck() {
    setup();
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
    ContactRequest notAutoRequest = new ContactRequest();
    notAutoRequest.RequestReason = nonAutomatedPurposeName;
    notAutoRequest.Appointment_date_and_Time__c = DateTime.now();

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
      testInteraction.Id,
      testEvent.WhatId,
      'The interaction must be set to the creating Interaction'
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
}
