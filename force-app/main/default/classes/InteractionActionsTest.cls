/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Testing Interaction Actions
 */
@isTest
public with sharing class InteractionActionsTest {
  /**
   * @description test for interaction assigned back to Queue.
   */
  @isTest
  static void testInteractionAssignedBacktoQueue() {
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue[0].Queue.Id;
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = 'Call';
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c
      FROM Interaction
    ];

    System.assertEquals(
      'Unassigned',
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE Type = 'Queue' AND Name = :'Appointments Queue'
    ];

    System.assertEquals(
      interactionQueue.Id,
      testInteraction.OwnerId,
      'The owner of the new interaction should be Appointment Queue'
    );

    System.assertEquals(
      testInteraction.ContactRequestId__c,
      request.Id,
      'The Contact request Id should be updated on the Interaction record.'
    );

    List<Event> events = [SELECT Id FROM Event];

    System.assertEquals(1, events.size(), 'One event must be created');

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

    testInteraction = [SELECT Id, Status__c, OwnerId FROM Interaction];

    System.assertEquals(
      'Scheduled',
      testInteraction.Status__c,
      'The status of the interaction should be updated to Scheduled'
    );

    Test.startTest();
    testInteraction.OwnerId = interactionQueue.Id;
    update testInteraction;
    Test.stopTest();

    testInteraction = [SELECT Id, Status__c, OwnerId FROM Interaction];

    System.assertEquals(
      'Unassigned',
      testInteraction.Status__c,
      'The status of the interaction should be updated back to Unassigned'
    );

    events = [SELECT Id FROM Event];

    System.assertEquals(0, events.size(), 'All events must be deleted');
  }

  /**
   * @description test for bulk cancelling an Interaction
   */
  @isTest
  static void testBulkCancellingAnInteraction() {
    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 100;
    apptCommt.Confirmed__c = 0;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    insert apptCommt;

    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    List<Account> personAccountList = new List<Account>();

    Account testAccount1 = createTestAccount('Joe', 'Bloggs', 'afr123');
    Account testAccount2 = createTestAccount('John', 'Smith', 'jsm666');

    personAccountList.add(testAccount1);
    personAccountList.add(testAccount2);
    insert personAccountList;

    List<Account> testAccounts = [SELECT Id, PersonContactId FROM Account];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.OwnerId = contactRequestQueue[0].Queue.Id;
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = testAccounts[0].PersonContactId;
      request.Appointment_Commitment__c = apptCommt.Id;
      request.PreferredChannel = 'Call';
      contactRequestList.add(request);
    }

    insert contactRequestList;

    List<ContactRequest> crList = [SELECT ID, OwnerId FROM ContactRequest];

    for (ContactRequest contReq : crList) {
      contReq.OwnerId = UserInfo.getUserId();
      contactRequestList.add(contReq);
    }

    update crList;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c
      FROM Interaction
    ];

    System.assertEquals(
      100,
      testInteraction.size(),
      '100 Interaction records should be created'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE Type = 'Queue' AND Name = :'Appointments Queue'
    ];

    for (Interaction inter : testInteraction) {
      System.assertEquals(
        'Unassigned',
        inter.Status__c,
        'The new interaction should have the status as Unassigned'
      );

      System.assertEquals(
        interactionQueue.Id,
        inter.OwnerId,
        'The owner of the new interaction should be Appointment Queue'
      );
    }

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      100,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be 100 since 100 new interactions were associated with the same appointment commitment'
    );

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertEquals(100, events.size(), '100 events must be created');

    Map<Id, SObject> oldMap = new Map<Id, SObject>();

    for (Interaction oldInteract : testInteraction) {
      Interaction oldInteraction = new Interaction(
        Id = oldInteract.Id,
        Status__c = oldInteract.Status__c
      );

      oldMap.put(oldInteraction.Id, oldInteraction);
    }

    test.startTest();
    List<Interaction> updatedInteractions = new List<Interaction>();
    InteractionActions actions = new InteractionActions();

    for (Interaction updateInteraction : testInteraction) {
      updateInteraction.Status__c = 'Cancelled';
      updatedInteractions.add(updateInteraction);
    }
    update updatedInteractions;

    List<Interaction> interactions = actions.findCancelledInteractions(
      oldMap,
      updatedInteractions
    );

    System.assertEquals(
      100,
      interactions.size(),
      'The interaction must be returned'
    );

    actions.deleteInteractionEvents(interactions);

    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');

    apptCommitRec = [SELECT Id, Confirmed__c FROM Appointment_Commitment__c];

    System.assertEquals(
      0,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be 0 after interaction cancellation'
    );
  }

  @isTest
  static void testCancellingAnInteraction() {
    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 5;
    apptCommt.Confirmed__c = 2;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    insert apptCommt;

    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue[0].Queue.Id;
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.Appointment_Commitment__c = apptCommt.Id;
    request.PreferredChannel = 'Call';
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c
      FROM Interaction
    ];

    System.assertEquals(
      'Unassigned',
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE Type = 'Queue' AND Name = :'Appointments Queue'
    ];

    System.assertEquals(
      interactionQueue.Id,
      testInteraction.OwnerId,
      'The owner of the new interaction should be Appointment Queue'
    );

    System.assertEquals(
      testInteraction.ContactRequestId__c,
      request.Id,
      'The Contact request Id should be updated on the Interaction record.'
    );

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      3,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be increased by 1'
    );

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertEquals(1, events.size(), 'One event must be created');

    Interaction oldInteraction = new Interaction(
      Id = testInteraction.Id,
      Status__c = testInteraction.Status__c
    );
    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(oldInteraction.Id, oldInteraction);

    test.startTest();
    testInteraction.Status__c = 'Cancelled';
    InteractionActions actions = new InteractionActions();
    List<Interaction> updatedInteractions = new List<Interaction>();
    updatedInteractions.add(testInteraction);
    update updatedInteractions;

    List<Interaction> interactions = actions.findCancelledInteractions(
      oldMap,
      updatedInteractions
    );

    System.assertEquals(
      1,
      interactions.size(),
      'The interaction must be returned'
    );

    actions.deleteInteractionEvents(interactions);

    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');

    apptCommitRec = [SELECT Id, Confirmed__c FROM Appointment_Commitment__c];

    System.assertEquals(
      2,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be decreased by 1 after interaction cancellation'
    );
  }

  @isTest
  static void testDoesntFindNotOrStillCancelledInteractions() {
    Interaction notCancelledInteraction = new Interaction(
      Name = 'Not Cancelled Interaction',
      Status__c = 'Scheduled'
    );

    Interaction stillCancelledInteraction = new Interaction(
      Name = 'Still Cancelled Interaction',
      Status__c = 'Cancelled'
    );

    List<Interaction> oldInteractions = new List<Interaction>();
    oldInteractions.add(notCancelledInteraction);
    oldInteractions.add(stillCancelledInteraction);

    insert oldInteractions;

    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    for (Interaction currentInteraction : oldInteractions) {
      oldMap.put(currentInteraction.Id, currentInteraction);
    }

    List<Interaction> newInteractions = new List<Interaction>();
    for (Interaction currentInteraction : oldInteractions) {
      Interaction newInteraction = new Interaction(
        Name = currentInteraction.Name,
        Id = currentInteraction.Id,
        Status__c = currentInteraction.Status__c
      );
    }

    InteractionActions actions = new InteractionActions();
    List<Interaction> cancelledInteractions = actions.findCancelledInteractions(
      oldMap,
      newInteractions
    );
    System.assertEquals(
      true,
      cancelledInteractions.isEmpty(),
      'No Interactions have been cancelled so none should return'
    );
  }

  /**
   * @description test for validating if the status is updated to Scheduled when the Owner is updated from Queue to User
   */

  @isTest
  static void testStatusChangetoScheduled() {
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.Name = :contactRequestQueueName
    ];

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.OwnerId = contactRequestQueue[0].Queue.Id;
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = 'Call';
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId
      FROM Interaction
    ];

    System.assertEquals(
      'Unassigned',
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE Type = 'Queue' AND Name = :'Appointments Queue'
    ];

    System.assertEquals(
      interactionQueue.Id,
      testInteraction.OwnerId,
      'The owner of the new interaction should be Appointment Queue'
    );

    testInteraction.OwnerID = UserInfo.getUserId();

    update testInteraction;

    testInteraction = [SELECT Id, Status__c, OwnerId FROM Interaction];

    System.assertEquals(
      'Scheduled',
      testInteraction.Status__c,
      'The status of the interaction should be updated to Scheduled'
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
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.RecordTypeId = personAccountRecordTypeId;

    return testAccount;
  }
}
