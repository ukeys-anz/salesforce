/**
 * @author Adam Smith
 * @since 20220411
 * @description test class for Interaction Trigger Events
 */
@isTest
public with sharing class InteractionTriggerHandlerTest {
  private static string appointmentQueueName = 'Appointments_Queue';
  private static string otherPurposeName = 'Other';
  private static Integer otherPurposeDuration = 30;
  private final static string TEST_MOBILE = '01189998819991197253';
  private final static string TEST_MOBILE2 = '0118999881999119725';

  @isTest
  static void testSwitchingInteractionFromQueueToUser() {
    createPurposeMap();
    QueueSObject appointmentQueue = getGroupByName(appointmentQueueName);
    Id currentUserId = UserInfo.getUserId();

    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    DateTime startTime = DateTime.newInstance(DateTime.now().year(), 1, 1);

    Interaction testInteraction = new Interaction(
      Status__c = 'Unassigned',
      Interaction_Purpose__c = otherPurposeName,
      StartTime = startTime,
      AccountId = testAccount.Id,
      Name = 'Other Appointment',
      EndTime = startTime.addMinutes(otherPurposeDuration),
      OwnerId = appointmentQueue.Queue.Id
    );
    insert testInteraction;

    List<Event> currentEvents = [SELECT Id FROM Event];
    system.assertEquals(
      true,
      currentEvents.isEmpty(),
      'There should not be any events at this stage'
    );

    test.startTest();
    testInteraction.OwnerId = currentUserId;
    update testInteraction;
    test.stopTest();

    currentEvents = [SELECT Id FROM Event];
    system.assertEquals(
      false,
      currentEvents.isEmpty(),
      'There should be an event at this stage'
    );
  }

  /**
   * @description test for cancelling an Interaction
   */
  @isTest
  static void testCancellingAnInteraction() {
    createPurposeMap();

    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = 'Call';
    insert request;

    Interaction testInteraction = [SELECT Id, Status__c FROM Interaction];

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertNotEquals(
      'Cancelled',
      testInteraction.Status__c,
      'Interaction must not start off cancelled.'
    );
    System.assertEquals(
      true,
      events.isEmpty(),
      'No Event should be created at this stage'
    );

    test.startTest();
    testInteraction.Status__c = 'Cancelled';
    update testInteraction;
    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');
  }

  static void createPurposeMap() {
    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);
  }
  /*
   * @description Test method to validate Interaction when the status is updated to Rescheduled
   */
  @isTest
  static void testReschedulingAnInteraction() {
    Schema.Location loc = new Schema.location();
    loc.Name = 'Test Location';
    loc.LocationType = 'Store1';
    insert loc;

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 5;
    apptCommt.Confirmed__c = 2;
    apptCommt.Type__c = 'Other';
    apptCommt.Location__c = loc.Id;
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

    createPurposeMap();

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
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
      testInteraction.Status__c,
      'Unassigned',
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

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      apptCommitRec.Confirmed__c,
      3,
      'The confirmed count should be increased by 1'
    );

    List<Event> events = [SELECT Id, StartDateTime, EndDateTime FROM Event];
    System.assertEquals(1, events.size(), 'An event record must be created');

    Test.startTest();

    testInteraction.Status__c = 'Rescheduled';
    testInteraction.StartTime = System.now().addDays(5);

    update testInteraction;

    Test.stopTest();

    apptCommitRec = [SELECT Id, Confirmed__c FROM Appointment_Commitment__c];

    System.assertEquals(
      apptCommitRec.Confirmed__c,
      2,
      'The confirmed count should be decreased by 1'
    );

    events = [SELECT Id, StartDateTime, EndDateTime FROM Event];

    testInteraction = [
      SELECT
        Id,
        Status__c,
        OwnerId,
        ContactRequestId__c,
        StartTime,
        EndTime,
        Interaction_Purpose__c
      FROM Interaction
    ];

    System.assertEquals(
      testInteraction.StartTime,
      events[0].StartDateTime,
      'The start time on the interaction should match with the event start time'
    );

    Integer duration = AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(testInteraction.Interaction_Purpose__c);

    System.assertEquals(
      testInteraction.StartTime.addMinutes(duration),
      events[0].EndDateTime,
      'The start time on the interaction should match with the event start time'
    );
  }

  @isTest
  static void testInteractionNoShow() {
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Id currentUserId = UserInfo.getUserId();

    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];

    createPurposeMap();

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
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
      testInteraction.Status__c,
      'Unassigned',
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

    testInteraction.OwnerId = currentUserId;
    update testInteraction;

    List<Event> currentEvents = [SELECT Id FROM Event];
    system.assertEquals(
      false,
      currentEvents.isEmpty(),
      'There should be an event at this stage'
    );

    Test.startTest();
    testInteraction.Status__c = 'No Show';
    update testInteraction;
    Test.stopTest();

    currentEvents = [SELECT Id FROM Event];

    System.assertEquals(
      true,
      currentEvents.isEmpty(),
      'All events must be deleted'
    );
  }

  /*
   * @description Test method to validate Interaction when the status is updated to Rescheduled (Bulk)
   */
  @isTest
  static void testBulkReschedulingAnInteraction() {
    Schema.Location loc = new Schema.location();
    loc.Name = 'Test Location';
    loc.LocationType = 'Store1';
    insert loc;

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 100;
    apptCommt.Confirmed__c = 0;
    apptCommt.Type__c = 'Other';
    apptCommt.Location__c = loc.Id;
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

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> crList = new List<ContactRequest>();
    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.WhoId = testAccount.PersonContactId;
      request.Appointment_Commitment__c = apptCommt.Id;
      request.PreferredChannel = 'Call';
      crList.add(request);
    }

    insert crList;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, Interaction_Purpose__c
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

    for (Interaction interact : testInteraction) {
      System.assertEquals(
        'Unassigned',
        interact.Status__c,
        'The new interaction should have the status as Unassigned'
      );

      System.assertEquals(
        interactionQueue.Id,
        interact.OwnerId,
        'The owner of the new interaction should be Appointment Queue'
      );

      interact.OwnerId = UserInfo.getUserId();
    }

    update testInteraction;

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      100,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be increased by 100'
    );

    List<Event> events = [SELECT Id, StartDateTime, EndDateTime FROM Event];

    Test.startTest();

    Datetime startTime = System.now().addDays(5);
    Integer duration = AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(apptCommt.Type__c);
    Datetime endTime = startTime.addMinutes(duration);

    for (Interaction interact : testInteraction) {
      interact.Status__c = 'Rescheduled';
      interact.StartTime = startTime;
    }

    update testInteraction;

    Test.stopTest();

    apptCommitRec = [SELECT Id, Confirmed__c FROM Appointment_Commitment__c];

    System.assertEquals(
      0,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be decreased to 0'
    );

    events = [SELECT Id, StartDateTime, EndDateTime FROM Event];

    for (Event evt : events) {
      System.assertEquals(
        evt.StartDateTime,
        startTime,
        'The start time on the interaction should match with the event start time'
      );

      System.assertEquals(
        evt.EndDateTime,
        endTime,
        'The end time on the interaction should match with the event end time'
      );
    }
  }

  @isTest
  static void testEndTimePopulationOnInsert() {
    Interaction newInteractionWithoutEndtime = new Interaction(
      Name = 'New Interaction',
      Interaction_Purpose__c = 'Financial Wellbeing',
      StartTime = System.now()
    );

    insert newInteractionWithoutEndtime;
    Integer duration = AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(newInteractionWithoutEndtime.Interaction_Purpose__c);

    Interaction testInteraction = [SELECT EndTime FROM Interaction];

    System.assertEquals(
      testInteraction.Endtime,
      newInteractionWithoutEndtime.StartTime.addMinutes(duration),
      'The end time should be updated based on the metadata configuration'
    );
  }

  @isTest
  static void testEndTimePopulationOnUpdate() {
    Interaction newInteractionWithoutEndtime = new Interaction(
      Name = 'New Interaction',
      Interaction_Purpose__c = 'Financial Wellbeing',
      StartTime = System.now()
    );

    insert newInteractionWithoutEndtime;
    Integer duration = AutomatedRequestMetadataProvider.getInstance()
      .getPurposeDuration(newInteractionWithoutEndtime.Interaction_Purpose__c);

    Interaction testInteraction = [SELECT EndTime FROM Interaction];

    System.assertEquals(
      testInteraction.Endtime,
      newInteractionWithoutEndtime.StartTime.addMinutes(duration),
      'The end time should be updated based on the metadata configuration'
    );

    newInteractionWithoutEndtime.StartTime = newInteractionWithoutEndtime.StartTime.addDays(
      10
    );
    update newInteractionWithoutEndtime;

    testInteraction = [SELECT EndTime FROM Interaction];

    System.assertEquals(
      testInteraction.Endtime,
      newInteractionWithoutEndtime.StartTime.addMinutes(duration),
      'The end time should be updated based on the metadata configuration'
    );
  }

  @isTest
  static void testMobileGetsSet() {
    Account testAccount = createTestAccount('Joe', 'Bloggs', '0123456');
    Account testAccount2 = createTestAccount('Jane', 'Bloggs', '0123457');
    testAccount2.PersonMobilePhone = TEST_MOBILE2;
    List<Account> accounts = new List<Account>{ testAccount, testAccount2 };

    insert accounts;

    testAccount = [
      SELECT Id, PersonMobilePhone, PersonContactId
      FROM Account
      WHERE Id = :testAccount.Id
    ];
    testAccount2 = [
      SELECT Id, PersonMobilePhone, PersonContactId
      FROM Account
      WHERE Id = :testAccount2.Id
    ];

    Interaction testInteraction = new Interaction(
      Name = 'Test Interaction',
      AccountId = testAccount.Id
    );
    insert testInteraction;

    testInteraction = [
      SELECT Id, Contact_Mobile__c
      FROM Interaction
      WHERE Id = :testInteraction.Id
    ];

    System.assertEquals(
      TEST_MOBILE,
      testInteraction.Contact_Mobile__c,
      'Contact Mobile must be set from the accounts mobile number'
    );

    testInteraction.AccountId = testAccount2.Id;
    update testInteraction;

    testInteraction = [
      SELECT Id, Contact_Mobile__c
      FROM Interaction
      WHERE Id = :testInteraction.Id
    ];

    System.assertEquals(
      TEST_MOBILE2,
      testInteraction.Contact_Mobile__c,
      'Contact Mobile must be switch when changing linked account'
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
    testAccount.PersonMobilePhone = TEST_MOBILE;
    testAccount.RecordTypeId = personAccountRecordTypeId;

    return testAccount;
  }

  static QueueSObject getGroupByName(string name) {
    List<QueueSObject> result = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE Queue.Type = 'Queue' AND Queue.DeveloperName = :name
    ];
    return result[0];
  }
}
