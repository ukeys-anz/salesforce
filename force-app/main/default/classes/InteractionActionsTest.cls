/**
 * @author Adam Smith
 * @since 20220411
 * @description class for Testing Interaction Actions
 */
@isTest
public with sharing class InteractionActionsTest {
  private final static string APPOINTMENT_QUEUE_NAME = 'Appointments_Queue';
  private final static string TEST_MOBILE = '01189998819991197253';
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

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

    List<Event> events = [SELECT Id FROM Event];

    System.assertEquals(1, events.size(), 'One event must be created');

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

  @isTest
  static void testSettingContactMobileFromAccount() {
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    insert testAccount;
    testAccount = [
      SELECT Id, PersonContactId, PersonMobilePhone
      FROM Account
      WHERE Id = :testAccount.Id
    ];
    Interaction newInteraction = new Interaction(AccountId = testAccount.Id);

    InteractionActions actions = new InteractionActions();
    actions.setInteractionsMobile(new List<Interaction>{ newInteraction });
    System.assertEquals(
      testAccount.PersonMobilePhone,
      newInteraction.Contact_Mobile__c,
      'Mobile number must be set'
    );
  }

  @isTest
  static void testSettingContactMobileFromLead() {
    Id generalLeadRTID = Schema.sOBjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('General')
      .getRecordTypeId();
    Lead testLead = new Lead(
      LastName = 'Bloggs',
      RecordTypeId = generalLeadRTID
    );
    testLead.MobilePhone = TEST_MOBILE;
    insert testLead;
    Interaction newInteraction = new Interaction(Lead__c = testLead.Id);

    InteractionActions actions = new InteractionActions();
    actions.setInteractionsMobile(new List<Interaction>{ newInteraction });
    System.assertEquals(
      testLead.MobilePhone,
      newInteraction.Contact_Mobile__c,
      'Mobile number must be set'
    );
  }

  @isTest
  static void testFindingInteractionsWithoutMobile() {
    Interaction interactionWithoutPhoneNumber = new Interaction(
      Name = 'interactionWithoutNumber'
    );
    Interaction interactionWithPhoneNumber = new Interaction(
      Name = 'interactionWithNumber',
      Contact_Mobile__c = TEST_MOBILE
    );
    List<Interaction> interactions = new List<Interaction>{
      interactionWithPhoneNumber,
      interactionWithoutPhoneNumber
    };
    InteractionActions actions = new InteractionActions();

    List<Interaction> interactionsWithtoutMobile = actions.findInteractionsWithoutMobile(
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
    apptCommt.Appointment_Channel__c = 'Store';
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

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = testAccounts[0].PersonContactId;
      request.Appointment_Commitment__c = apptCommt.Id;
      request.PreferredChannel = 'Call';
      contactRequestList.add(request);
    }

    insert contactRequestList;

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

    for (Interaction currentInteraction : testInteraction) {
      currentInteraction.OwnerId = UserInfo.getUserId();
    }
    update testInteraction;

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
    apptCommt.Appointment_Channel__c = 'Store';
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

    DateTime appointmentDate = DateTime.now();

    ContactRequest request = new ContactRequest();
    request.WhoId = testAccount.PersonContactId;
    request.Appointment_Commitment__c = apptCommt.Id;
    request.PreferredChannel = 'Call';
    insert request;

    request = [SELECT Id, RequestReason FROM ContactRequest];

    System.assertEquals(
      request.RequestReason,
      apptCommt.Type__c,
      'The request reason should match the type on Appointment Commitment'
    );

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

    testInteraction.OwnerId = UserInfo.getUserId();
    update testInteraction;

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

  @isTest
  static void testUnassigningInteraction() {
    Id appointmentRTID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
      .get('Appointment')
      .getRecordTypeId();

    Interaction testInteraction = new Interaction(
      OwnerId = UserInfo.getUserId(),
      Name = 'Test Interaction',
      RecordTypeId = appointmentRTID
    );
    insert testInteraction;

    testInteraction.Status__c = 'Assigned';

    Interaction unassignedInteraction = new Interaction(
      Id = testInteraction.Id,
      Status__c = 'Unassigned',
      OwnerId = UserInfo.getUserId(),
      RecordTypeId = appointmentRTID
    );

    Map<Id, Interaction> oldMap = new Map<Id, Interaction>();
    oldMap.put(testInteraction.Id, testInteraction);

    List<Interaction> records = new List<Interaction>{ unassignedInteraction };

    InteractionActions actions = new InteractionActions();

    List<Interaction> unassignedInteractions = actions.unassignInteractions(
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

    Id groupId = CommonUtil.getGroupId(APPOINTMENT_QUEUE_NAME);

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

  @isTest
  static void testFindInteractionOwnershipChanged() {
    InteractionActions actions = new InteractionActions();
    Id myId = UserInfo.getUserId();
    Id groupId = CommonUtil.getGroupId(APPOINTMENT_QUEUE_NAME);

    Interaction testInteraction = new Interaction(
      Name = 'Test Interaction',
      OwnerId = groupId
    );
    insert testInteraction;

    Interaction newInteraction = new Interaction(
      Name = testInteraction.Name,
      Id = testInteraction.Id,
      OwnerId = myId
    );

    Map<Id, SObject> oldMap = new Map<Id, SObject>(
      new List<Interaction>{ testInteraction }
    );

    List<Interaction> records = new List<Interaction>{ newInteraction };

    List<Interaction> result = actions.findInteractionsOwnershipChanged(
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

    result = actions.findInteractionsOwnershipChanged(oldMap, records);

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

    DateTime appointmentDate = DateTime.now();

    List<ContactRequest> contactRequestList = new List<ContactRequest>();

    for (Integer i = 0; i < 100; i++) {
      ContactRequest request = new ContactRequest();
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = testAccounts[0].PersonContactId;
      request.PreferredChannel = 'Call';
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
        testInteraction[i].Interaction_Purpose__c + ' Coaching Summary',
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
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    List<Account> personAccountList = new List<Account>();

    Account testAccount1 = createTestAccount('Joe', 'Bloggs', 'afr123');
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
    request.PreferredChannel = 'Call';
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
      WHERE Type = 'Queue' AND Name = :'Appointments Queue'
    ];

    System.assertEquals(
      'Unassigned',
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
        'FirstName' => 'CoachTest',
        'ProfileId' => profile.Id,
        'UserRoleId' => coachRole.Id
      }
    );
    insert coach;

    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = 'Appointment_Booking_Read_Write'
    ];

    PermissionSetAssignment psa = new PermissionSetAssignment(
      AssigneeId = coach.id,
      PermissionSetId = ps.Id
    );

    insert psa;

    Interaction interactNew = new Interaction();
    interactNew.Coaching_Summary__c = coachingSummaryList[0].Id;
    interactNew.Name = 'TestNewInteraction';
    interactNew.AccountId = testAccount1.Id;
    interactNew.StartTime = System.now().addDays(30);
    interactNew.EndTime = interactNew.StartTime.addMinutes(30);
    insert interactNew;

    interactNew = [
      SELECT Id, OwnerId
      FROM Interaction
      WHERE Name = 'TestNewInteraction'
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
    testAccount.PersonMobilePhone = TEST_MOBILE;

    return testAccount;
  }
}
