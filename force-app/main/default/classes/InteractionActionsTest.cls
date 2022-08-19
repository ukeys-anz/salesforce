/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Testing Interaction Actions
 */
@isTest
public with sharing class InteractionActionsTest {
  private static Integer otherPurposeDuration = 30;
  private static Integer financialWellbeingPurposeDuration = 45;
  private static final String APPOINTMENT_RW_PS = 'Appointment_Booking_Read_Write';
  private static final String NOT_AUTOMATED_PURPOSE = 'NotAutomated';

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

  /**
   * @description test for interaction assigned back to Queue.
   */
  @isTest
  static void testInteractionAssignedBacktoQueue() {
    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    Account testAccount = createTestAccount();
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

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = InteractionConstants.CALL;
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c
      FROM Interaction
    ];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
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

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

    List<Event> events = [SELECT Id FROM Event];

    System.assertEquals(1, events.size(), 'One event must be created');

    testInteraction = [SELECT Id, Status__c, OwnerId FROM Interaction];

    System.assertEquals(
      InteractionConstants.SCHEDULED_STATUS,
      testInteraction.Status__c,
      'The status of the interaction should be updated to Scheduled'
    );

    Test.startTest();
    testInteraction.OwnerId = interactionQueue.Id;
    update testInteraction;
    Test.stopTest();

    testInteraction = [SELECT Id, Status__c, OwnerId FROM Interaction];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction.Status__c,
      'The status of the interaction should be updated back to Unassigned'
    );

    events = [SELECT Id FROM Event];

    System.assertEquals(0, events.size(), 'All events must be deleted');
  }

  @isTest
  static void testFindingInteractionsWithoutMobile() {
    Faker faker = new Faker('AU');
    Interaction interactionWithoutPhoneNumber = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = faker.randomString(10)
    );
    Interaction interactionWithPhoneNumber = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = faker.randomString(10),
      Contact_Mobile__c = String.valueOf(faker.randomDecimal(10, 0))
    );
    List<Interaction> interactions = new List<Interaction>{
      interactionWithPhoneNumber,
      interactionWithoutPhoneNumber
    };
    InteractionActions actions = new InteractionActions();

    List<Interaction> interactionsWithtoutMobile = InteractionFilter.findInteractionsWithoutMobile(
      interactions
    );

    System.assertEquals(
      false,
      interactionsWithtoutMobile.isEmpty(),
      'At least one interactions should be returned'
    );
    System.assertEquals(
      interactionWithoutPhoneNumber.Name,
      interactionsWithtoutMobile[0].Name,
      'The interaction without mobile should be returned'
    );
  }

  /**
   * @description test for bulk cancelling an Interaction
   */
  @isTest
  static void testBulkCancellingAnInteraction() {
    Faker faker = new Faker('AU');
    Schema.Location loc = new Schema.location();
    loc.Name = faker.randomString(10);
    loc.LocationType = InteractionConstants.STORE;
    insert loc;

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 100;
    apptCommt.Confirmed__c = 0;
    apptCommt.Type__c = InteractionConstants.OTHER_PURPOSE_NAME;
    apptCommt.Location__c = loc.Id;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    apptCommt.Appointment_Channel__c = InteractionConstants.STORE;
    insert apptCommt;

    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    List<Account> personAccountList = new List<Account>();

    Account testAccount1 = createTestAccount();
    Account testAccount2 = createTestAccount();

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

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = testAccounts[0].PersonContactId;
      request.Appointment_Commitment__c = apptCommt.Id;
      request.PreferredChannel = InteractionConstants.CALL;
      contactRequestList.add(request);
    }

    insert contactRequestList;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, RecordTypeId
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
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
    ];

    for (Interaction inter : testInteraction) {
      System.assertEquals(
        InteractionConstants.UNASSIGNED_STATUS,
        inter.Status__c,
        'The new interaction should have the status as Unassigned'
      );

      System.assertEquals(
        interactionQueue.Id,
        inter.OwnerId,
        'The owner of the new interaction should be Appointment Queue'
      );
    }

    for (Interaction currentInteraction : testInteraction) {
      currentInteraction.OwnerId = UserInfo.getUserId();
    }
    update testInteraction;

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c, Appointment_Channel__c
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
        RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
        Id = oldInteract.Id,
        Status__c = oldInteract.Status__c
      );

      oldMap.put(oldInteraction.Id, oldInteraction);
    }

    test.startTest();
    List<Interaction> updatedInteractions = new List<Interaction>();

    for (Interaction updateInteraction : testInteraction) {
      updateInteraction.Status__c = InteractionConstants.CANCELLED;
      updatedInteractions.add(updateInteraction);
    }
    update updatedInteractions;

    List<Interaction> interactions = InteractionActions.findCancelledInteractions(
      oldMap,
      updatedInteractions
    );

    System.assertEquals(
      100,
      interactions.size(),
      'The interaction must be returned'
    );

    InteractionActions.deleteInteractionEvents(interactions);

    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');

    apptCommitRec = [
      SELECT Id, Confirmed__c, Appointment_Channel__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      0,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be 0 after interaction cancellation'
    );
  }

  @isTest
  static void testCancellingAnInteraction() {
    Faker faker = new Faker('AU');
    Schema.Location loc = new Schema.location();
    loc.Name = faker.randomString(10);
    loc.LocationType = InteractionConstants.STORE;
    insert loc;

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 5;
    apptCommt.Confirmed__c = 2;
    apptCommt.Type__c = InteractionConstants.OTHER_PURPOSE_NAME;
    apptCommt.Location__c = loc.Id;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    apptCommt.Appointment_Channel__c = InteractionConstants.STORE;
    insert apptCommt;

    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    Account testAccount = createTestAccount();
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

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.WhoId = testAccount.PersonContactId;
    request.Appointment_Commitment__c = apptCommt.Id;
    request.PreferredChannel = InteractionConstants.CALL;
    insert request;

    request = [SELECT Id, RequestReason FROM ContactRequest];

    System.assertEquals(
      request.RequestReason,
      apptCommt.Type__c,
      'The request reason should match the type on Appointment Commitment'
    );

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, RecordTypeId
      FROM Interaction
    ];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
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

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

    Appointment_Commitment__c apptCommitRec = [
      SELECT Id, Confirmed__c, Appointment_Channel__c
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
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Id = testInteraction.Id,
      Status__c = testInteraction.Status__c
    );
    Map<Id, SObject> oldMap = new Map<Id, SObject>();
    oldMap.put(oldInteraction.Id, oldInteraction);

    test.startTest();
    testInteraction.Status__c = InteractionConstants.CANCELLED;

    List<Interaction> updatedInteractions = new List<Interaction>();
    updatedInteractions.add(testInteraction);
    update updatedInteractions;

    List<Interaction> interactions = InteractionActions.findCancelledInteractions(
      oldMap,
      updatedInteractions
    );

    System.assertEquals(
      1,
      interactions.size(),
      'The interaction must be returned'
    );

    InteractionActions.deleteInteractionEvents(interactions);

    test.stopTest();

    events = [SELECT Id FROM Event];

    System.assertEquals(true, events.isEmpty(), 'All events must be deleted');

    apptCommitRec = [
      SELECT Id, Confirmed__c, Appointment_Channel__c
      FROM Appointment_Commitment__c
    ];

    System.assertEquals(
      2,
      apptCommitRec.Confirmed__c,
      'The confirmed count should be decreased by 1 after interaction cancellation'
    );
  }

  @isTest
  static void testDoesntFindNotOrStillCancelledInteractions() {
    Faker faker = new Faker('AU');
    Interaction notCancelledInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = faker.randomString(10),
      Status__c = InteractionConstants.SCHEDULED_STATUS
    );

    Interaction stillCancelledInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = faker.randomString(10),
      Status__c = InteractionConstants.CANCELLED
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
        RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
        Name = currentInteraction.Name,
        Id = currentInteraction.Id,
        Status__c = currentInteraction.Status__c
      );
    }

    List<Interaction> cancelledInteractions = InteractionActions.findCancelledInteractions(
      oldMap,
      newInteractions
    );
    System.assertEquals(
      true,
      cancelledInteractions.isEmpty(),
      'No Interactions have been cancelled so none should return'
    );
  }

  @isTest
  static void testUnassigningInteraction() {
    Faker faker = new Faker('AU');
    Interaction testInteraction = new Interaction(
      OwnerId = UserInfo.getUserId(),
      Name = faker.randomString(10),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID
    );
    insert testInteraction;

    testInteraction.Status__c = InteractionConstants.ASSIGNED_STATUS;

    Interaction unassignedInteraction = new Interaction(
      Id = testInteraction.Id,
      Status__c = InteractionConstants.UNASSIGNED_STATUS,
      OwnerId = UserInfo.getUserId(),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID
    );

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>();
    oldMap.put(testInteraction.Id, testInteraction);

    List<Interaction> records = new List<Interaction>{ unassignedInteraction };

    List<Interaction> unassignedInteractions = InteractionActions.unassignInteractions(
      oldMap,
      records
    );

    System.assertEquals(
      false,
      unassignedInteractions.isEmpty(),
      'Should return an Interaction'
    );

    System.assertEquals(
      1,
      unassignedInteractions.size(),
      'One Interaction must be returned'
    );

    Id groupId = CommonUtil.getGroupId(InteractionConstants.APPOINTMENTS_QUEUE);

    System.assertEquals(
      groupId,
      unassignedInteractions[0].OwnerId,
      'Owner Id must be set to the Appointment Queue'
    );
  }

  /**
   * @description test for validating if the status is updated to Scheduled when the Owner is updated from Queue to User
   */
  @isTest
  static void testStatusChangetoScheduled() {
    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    Account testAccount = createTestAccount();
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

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = InteractionConstants.CALL;
    insert request;

    request.OwnerId = UserInfo.getUserId();

    update request;

    Interaction testInteraction = [
      SELECT Id, Status__c, OwnerId
      FROM Interaction
    ];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction.Status__c,
      'The new interaction should have the status as Unassigned'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
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
      InteractionConstants.SCHEDULED_STATUS,
      testInteraction.Status__c,
      'The status of the interaction should be updated to Scheduled'
    );
  }

  @isTest
  static void testFindInteractionOwnershipChanged() {
    Faker faker = new Faker('AU');
    Id myId = UserInfo.getUserId();
    Id groupId = CommonUtil.getGroupId(InteractionConstants.APPOINTMENTS_QUEUE);

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = faker.randomString(10),
      OwnerId = groupId
    );
    insert testInteraction;

    Interaction newInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Name = testInteraction.Name,
      Id = testInteraction.Id,
      OwnerId = myId
    );

    Map<Id, SObject> oldMap = new Map<Id, SObject>(
      new List<Interaction>{ testInteraction }
    );

    List<Interaction> records = new List<Interaction>{ newInteraction };

    List<Interaction> result = InteractionActions.findInteractionsOwnershipChanged(
      oldMap,
      records
    );

    System.assertEquals(
      false,
      result.isEmpty(),
      'The interaction should be returned.'
    );

    newInteraction.OwnerId = groupId;
    records = new List<Interaction>{ newInteraction };

    result = InteractionActions.findInteractionsOwnershipChanged(
      oldMap,
      records
    );

    System.assertEquals(
      true,
      result.isEmpty(),
      'The interaction should not be returned.'
    );
  }

  /**
   * @description test for creating new coaching summary
   */
  @isTest
  static void testCoachingSummaryCreation() {
    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    List<Account> personAccountList = new List<Account>();

    Account testAccount1 = createTestAccount();
    Account testAccount2 = createTestAccount();

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

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = testAccounts[0].PersonContactId;
      request.PreferredChannel = InteractionConstants.CALL;
      contactRequestList.add(request);
    }

    insert contactRequestList;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, Coaching_Summary__c
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
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
    ];

    for (Interaction inter : testInteraction) {
      System.assertEquals(
        InteractionConstants.UNASSIGNED_STATUS,
        inter.Status__c,
        'The new interaction should have the status as Unassigned'
      );

      System.assertEquals(
        interactionQueue.Id,
        inter.OwnerId,
        'The owner of the new interaction should be Appointment Queue'
      );
    }

    for (Interaction currentInteraction : testInteraction) {
      currentInteraction.OwnerId = UserInfo.getUserId();
    }
    update testInteraction;

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertEquals(100, events.size(), '100 events must be created');

    List<Coaching_Summary__c> coachingSummaryList = [
      SELECT Id, Name__c, Account__c
      FROM Coaching_Summary__c
    ];

    System.assertEquals(
      100,
      coachingSummaryList.size(),
      '100 coaching summary records must be created'
    );

    testInteraction = [
      SELECT
        Id,
        Status__c,
        OwnerId,
        AccountId,
        ContactRequestId__c,
        Coaching_Summary__c,
        Interaction_Purpose__c
      FROM Interaction
    ];

    for (Integer i = 0; i < 100; i++) {
      System.assertEquals(
        testInteraction[i].Coaching_Summary__c,
        coachingSummaryList[i].Id,
        'The coaching summary Id should be updated on the interaction'
      );

      System.assertEquals(
        testInteraction[i].AccountId,
        coachingSummaryList[i].Account__c,
        'The coaching summary account should be matched with interaction account'
      );

      System.assertEquals(
        testInteraction[i].Interaction_Purpose__c +
        InteractionConstants.COACHING_SUMMARY_LABEL,
        coachingSummaryList[i].Name__c,
        'The coaching summary name should be matched with interaction purpose'
      );
    }
  }

  /**
   * @description test for updating coaching summary owner
   */
  @isTest
  static void testCoachingSummaryOwnerUpdate() {
    Faker faker = new Faker('AU');
    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;
    List<Account> personAccountList = new List<Account>();

    Account testAccount1 = createTestAccount();
    insert testAccount1;

    List<Account> testAccounts = [SELECT Id, PersonContactId FROM Account];

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = otherPurposeName;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(otherPurposeName, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = otherPurposeName;
    request.WhoId = testAccounts[0].PersonContactId;
    request.PreferredChannel = InteractionConstants.CALL;
    contactRequestList.add(request);

    insert request;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, Coaching_Summary__c
      FROM Interaction
    ];

    System.assertEquals(
      1,
      testInteraction.size(),
      '1 Interaction record should be created'
    );

    Group interactionQueue = [
      SELECT ID
      FROM Group
      WHERE
        Type = 'Queue'
        AND Name = :InteractionConstants.APPOINTMENT_QUEUE_NAME
    ];

    System.assertEquals(
      InteractionConstants.UNASSIGNED_STATUS,
      testInteraction[0].Status__c,
      'The new interaction should have the status as Unassigned'
    );

    System.assertEquals(
      interactionQueue.Id,
      testInteraction[0].OwnerId,
      'The owner of the new interaction should be Appointment Queue'
    );

    testInteraction[0].OwnerId = UserInfo.getUserId();

    update testInteraction;

    List<Event> events = [SELECT Id FROM Event];

    System.assertNotEquals(null, testInteraction, 'An Interaction must exist');
    System.assertEquals(1, events.size(), '1 event must be created');

    List<Coaching_Summary__c> coachingSummaryList = [
      SELECT Id, Name__c, Account__c, OwnerId
      FROM Coaching_Summary__c
    ];

    System.assertEquals(
      1,
      coachingSummaryList.size(),
      '1 coaching summary record must be created'
    );

    System.assertEquals(
      UserInfo.getUserId(),
      coachingSummaryList[0].OwnerId,
      'The coaching summary owner should be current user'
    );

    Profile profile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole coachRole = CommonUtil.getUserRoleByDevName('Coach');
    User coach = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => faker.randomString(10),
        'ProfileId' => profile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coach;

    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :APPOINTMENT_RW_PS
    ];

    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coach.id,
      PermissionSetId = ps.Id
    );

    insert psa;

    Interaction interactNew = new Interaction();
    interactNew.RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID;
    interactNew.Coaching_Summary__c = coachingSummaryList[0].Id;
    String randInteractName = faker.randomString(10);
    interactNew.Name = randInteractName;
    interactNew.AccountId = testAccount1.Id;
    interactNew.StartTime = System.now().addDays(30);
    interactNew.EndTime = interactNew.StartTime.addMinutes(30);
    insert interactNew;

    interactNew = [
      SELECT Id, OwnerId
      FROM Interaction
      WHERE Name = :randInteractName
    ];

    Test.startTest();

    interactNew.OwnerId = coach.Id;
    update interactNew;

    Test.stopTest();

    coachingSummaryList = [
      SELECT Id, Name__c, Account__c, OwnerId
      FROM Coaching_Summary__c
    ];

    System.assertEquals(
      coach.Id,
      coachingSummaryList[0].OwnerId,
      'The existing coaching summary owner should be updated with the new interaction owner'
    );
  }

  /**
   *@description A customer cannot request an interaction at the same time they have another
   */
  @isTest
  static void testCustomerCreatingOverlappingInteraction() {
    Account testAccount1 = createTestAccount();
    insert testAccount1;

    Account testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount1.Id
    ];

    string finacialWellbeingPurposeName = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    DateTime appointmentDate = DateTime.newInstance(2022, 10, 20, 10, 30, 0);

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = finacialWellbeingPurposeName;
    request.WhoId = testAccount.PersonContactId;
    request.PreferredChannel = InteractionConstants.CALL;
    insert request;

    List<Interaction> testInteraction = [
      SELECT
        Id,
        Status__c,
        OwnerId,
        ContactRequestId__c,
        Coaching_Summary__c,
        Interaction_External_Id__c
      FROM Interaction
    ];

    System.assertEquals(
      1,
      testInteraction.size(),
      '1 Interaction record should be created'
    );

    testInteraction[0].OwnerId = UserInfo.getUserId();
    update testInteraction;

    Test.startTest();

    DateTime newAppointmentDate = DateTime.newInstance(2022, 10, 20, 11, 0, 0);

    ContactRequest request2 = new ContactRequest();
    request2.Appointment_date_and_Time__c = newAppointmentDate;
    request2.RequestReason = finacialWellbeingPurposeName;
    request2.WhoId = testAccount.PersonContactId;
    request2.PreferredChannel = InteractionConstants.CALL;

    Exception thrownException;
    try {
      insert request2;
    } catch (Exception e) {
      thrownException = e;
    }
    Test.stopTest();

    System.assertNotEquals(
      null,
      thrownException,
      'An exception must have been thrown'
    );

    System.assert(
      thrownException.getMessage()
        .contains(System.Label.Interaction_User_Created_Error_Message),
      'The error message should be available in the body'
    );

    System.assert(
      thrownException.getMessage()
        .contains(testInteraction[0].Interaction_External_Id__c),
      'The error message should contain the External Id'
    );
  }

  /**
   *@description A lead cannot request an interaction at the same time they have another
   */
  @isTest
  static void testLeadCreatingOverlappingInteraction() {
    Faker faker = new Faker('AU');
    Lead testLead = new Lead(
      LastName = faker.randomString(10),
      RecordTypeId = GetHelpConstants.LEAD_GENERAL_RT_ID
    );
    testLead.MobilePhone = String.valueOf(faker.randomDecimal(10, 0));
    insert testLead;

    string finacialWellbeingPurposeName = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    DateTime appointmentDate = DateTime.newInstance(2022, 10, 20, 10, 30, 0);

    ContactRequest request = new ContactRequest();
    request.Appointment_date_and_Time__c = appointmentDate;
    request.RequestReason = finacialWellbeingPurposeName;
    request.WhoId = testLead.Id;
    request.PreferredChannel = InteractionConstants.CALL;
    insert request;

    List<Interaction> testInteraction = [
      SELECT Id, Status__c, OwnerId, ContactRequestId__c, Coaching_Summary__c
      FROM Interaction
    ];

    System.assertEquals(
      1,
      testInteraction.size(),
      '1 Interaction record should be created'
    );

    testInteraction[0].OwnerId = UserInfo.getUserId();
    update testInteraction;

    Test.startTest();

    DateTime newAppointmentDate = DateTime.newInstance(2022, 10, 20, 11, 0, 0);

    ContactRequest request2 = new ContactRequest();
    request2.Appointment_date_and_Time__c = newAppointmentDate;
    request2.RequestReason = finacialWellbeingPurposeName;
    request2.WhoId = testLead.Id;
    request2.PreferredChannel = InteractionConstants.CALL;

    Exception thrownException;
    try {
      insert request2;
    } catch (Exception e) {
      thrownException = e;
    }
    Test.stopTest();

    System.assertNotEquals(
      null,
      thrownException,
      'An exception must have been thrown'
    );

    System.assert(
      thrownException.getMessage()
        .contains(System.Label.Interaction_User_Created_Error_Message),
      'The error message should be available in the body: ' +
      thrownException.getMessage()
    );
  }

  /**
   * @description testing that a coach cannot create an interaction for the same customer
   * at the same time.
   */
  @isTest
  static void testCoachCreatingOverlappingInteraction() {
    Faker faker = new Faker('AU');

    Account testAccount1 = createTestAccount();
    insert testAccount1;

    Account testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount1.Id
    ];

    string finacialWellbeingPurposeName = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    DateTime appointmentDate = DateTime.newInstance(2022, 10, 20, 5, 30, 0);
    DateTime endDate = appointmentDate.addMinutes(45);

    Interaction existingInteraction = new Interaction(
      Name = faker.randomString(10),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount1.Id,
      Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      OwnerId = UserInfo.getUserId(),
      Status__c = InteractionConstants.SCHEDULED_STATUS,
      StartTime = appointmentDate,
      EndTime = endDate
    );
    insert existingInteraction;
    Test.startTest();

    Interaction testInteraction2;
    testInteraction2 = new Interaction(
      Name = faker.randomString(10),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount1.Id,
      Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      StartTime = appointmentDate,
      EndTime = endDate
    );
    Exception thrownException;
    try {
      insert testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    Test.stopTest();

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown to prevent the creation of the second interaction'
    );
  }

  /**
   * @description testing that a coach cannot take ownership of an interaction
   * at the same time as another interaction they have ownership.
   */
  @isTest
  static void testCoachUpdatingOverlappingInteraction() {
    Faker faker = new Faker('AU');

    Account testAccount1 = createTestAccount();
    insert testAccount1;
    Account testAccount2 = createTestAccount();
    insert testAccount2;

    Account testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount1.Id
    ];

    testAccount2 = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount2.Id
    ];

    string finacialWellbeingPurposeName = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    DateTime appointmentDate = DateTime.newInstance(2022, 10, 20, 5, 30, 0);
    DateTime endDate = appointmentDate.addMinutes(45);

    Interaction existingInteraction = new Interaction(
      Name = faker.randomString(10),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount1.Id,
      Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      OwnerId = UserInfo.getUserId(),
      Status__c = InteractionConstants.SCHEDULED_STATUS,
      StartTime = appointmentDate,
      EndTime = endDate
    );
    insert existingInteraction;

    existingInteraction.OwnerId = UserInfo.getUserId();
    update existingInteraction;

    existingInteraction = [
      SELECT Id, Status__c
      FROM Interaction
      WHERE Id = :existingInteraction.Id
    ];
    System.assertEquals(
      InteractionConstants.SCHEDULED_STATUS,
      existingInteraction.Status__c,
      'Status should be set'
    );
    Test.startTest();

    Interaction testInteraction2;
    testInteraction2 = new Interaction(
      Name = faker.randomString(10),
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount2.Id,
      Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      StartTime = appointmentDate,
      EndTime = endDate
    );
    insert testInteraction2;

    testInteraction2 = [
      SELECT Id, OwnerId
      FROM Interaction
      WHERE Id = :testInteraction2.Id
    ];

    Map<Id, List<Interaction>> interactionMap = InteractionActions.getCoachExistingInteractions(
      new Set<Id>{ UserInfo.getUserId() }
    );
    System.assertEquals(
      1,
      interactionMap.values().size(),
      'There should be an existing interaction for the coach'
    );

    testInteraction2.OwnerId = UserInfo.getUserId();

    Exception thrownException;
    try {
      update testInteraction2;
    } catch (Exception exc) {
      thrownException = exc;
    }
    Test.stopTest();

    testInteraction2 = [
      SELECT Id, OwnerId
      FROM Interaction
      WHERE Id = :testInteraction2.Id
    ];
    System.assertNotEquals(
      UserInfo.getUserId(),
      testInteraction2.OwnerId,
      'Update should have not allowed the owner to change.'
    );

    System.assertNotEquals(
      null,
      thrownException,
      'An exception should have been thrown'
    );

    System.assert(
      thrownException.getMessage()
        .contains(System.Label.Coach_Existing_Interaction_Error_Message),
      'Error message should be what is expected'
    );
  }

  /**
   * @description testing that a appointment rt record will have
   * the name populated for manual creations.
   */
  @isTest
  static void testsetNameOfAppointments() {
    InteractionActions actions = new InteractionActions();

    Account testAccount1 = createTestAccount();
    insert testAccount1;
    Account testAccount2 = createTestAccount();
    insert testAccount2;

    Account testAccount = [
      SELECT Id, PersonContactId
      FROM Account
      WHERE Id = :testAccount1.Id
    ];

    string finacialWellbeingPurposeName = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    DateTime appointmentDate = DateTime.newInstance(2022, 10, 20, 5, 30, 0);
    DateTime endDate = appointmentDate.addMinutes(45);
    Interaction newInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      AccountId = testAccount1.Id,
      Interaction_Purpose__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
      Status__c = InteractionConstants.UNASSIGNED_STATUS,
      StartTime = appointmentDate
    );
    Test.startTest();
    insert newInteraction;
    Test.stopTest();

    Interaction testInteraction = [
      SELECT Id, Name
      FROM Interaction
      WHERE Id = :newInteraction.Id
    ];

    System.assertEquals(
      'Financial Wellbeing Appointment',
      testInteraction.Name,
      'Interaction record must have the name set.'
    );

    System.assertNotEquals(
      'Appointment',
      testInteraction.Name,
      'Interaction record name must match.'
    );
  }

  /**
   * @description helper method to create a person account with random strings
   * @return Account a Person Account with random name and OCV Ids
   */
  static Account createTestAccount() {
    Faker faker = new Faker('AU');
    return createTestAccount(
      faker.randomString(5),
      faker.randomString(5),
      faker.randomString(10)
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
    Faker faker = new Faker('AU');
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAccount = new Account();
    testAccount.FirstName = firstName;
    testAccount.LastName = lastName;
    testAccount.OCV_ID__c = ocvId;
    testAccount.RecordTypeId = personAccountRecordTypeId;
    testAccount.PersonMobilePhone = String.valueOf(faker.randomDecimal(10, 0));

    return testAccount;
  }

  @isTest
  static void returnInteractionsWithAutomatedPurpose() {
    setup();
    InteractionActions actions = new InteractionActions();

    Interaction automatedInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Interaction_Purpose__c = InteractionConstants.OTHER_PURPOSE_NAME
    );
    Interaction nonAutomatedInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_APPT_RT_ID,
      Interaction_Purpose__c = NOT_AUTOMATED_PURPOSE
    );

    List<Interaction> interactions = new List<Interaction>{
      automatedInteraction,
      nonAutomatedInteraction
    };

    test.startTest();
    List<Interaction> automatedInteractions = InteractionFilter.returnInteractionsWithAutomatedPurpose(
      interactions
    );
    test.stopTest();

    system.assertEquals(
      1,
      automatedInteractions.size(),
      'Should only return automated interactions'
    );
  }
}
