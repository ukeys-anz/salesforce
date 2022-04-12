@isTest
private class ContactRequestTriggerHandlerTest {
  static string otherPurposeName = 'Other';
  static Integer otherPurposeDuration = 30;
  static string contactRequestQueueName = 'Contact Request';
  /*
    Test data setup 
  */

  @testSetup
  static void testDataSetup() {
    /*
      Insert appointment commitment records
    */

    Faker faker = new Faker('AU');

    List<Appointment_Commitment__c> apptCommtRecords = new List<Appointment_Commitment__c>();

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 5;
    apptCommt.Confirmed__c = 2;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    apptCommtRecords.add(apptCommt);

    Appointment_Commitment__c apptCommt2 = new Appointment_Commitment__c();
    apptCommt2.Available__c = 5;
    apptCommt2.Date_and_Time__c = DateTime.newInstance(2022, 3, 11, 1, 45, 0);
    apptCommtRecords.add(apptCommt2);

    insert apptCommtRecords;

    Account account = new Account(
      FirstName = faker.person.firstName(),
      LastName = faker.person.lastName(),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true
    );

    insert account;

    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Interaction interaction = new Interaction(
        AccountId = account.Id,
        Name = 'Test Interaction' + i,
        Status__c = 'New'
      );

      interactionList.add(interaction);

      ContactRequest contactReq = new ContactRequest(
        PreferredChannel = 'Call',
        RequestReason = 'Financial Wellbeing',
        Status = 'New'
      );

      contactRequestList.add(contactReq);
    }

    insert contactRequestList;
  }

  @isTest
  static void testSuccessfulConfirmCountUpdate() {
    Datetime dateTimeVal = DateTime.newInstance(2022, 3, 10, 12, 45, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_and_Time__c = :dateTimeVal
    ];

    /*
      Check the count of the confirmed field before appointment commitment record is created.
    */
    System.assertEquals(
      apptCommtRec.Confirmed__c,
      2,
      'Confirmed Count before Contact Request is created.'
    );

    Test.startTest();

    /*
      Insert contact request for that appointment commitment record.
    */

    ContactRequest contReq = new ContactRequest();
    contReq.Appointment_date_and_time__c = DateTime.newInstance(
      2022,
      3,
      10,
      12,
      45,
      0
    );
    contReq.Appointment_Commitment__c = apptCommtRec.Id;
    contReq.PreferredChannel = 'Call';
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_and_Time__c = :dateTimeVal
    ];

    /*
      Assert the count of the confirmed field after appointment commitment creation.
    */

    System.assertEquals(
      apptCommtRec2.Confirmed__c,
      3,
      'Confirmed count should be updated after contact request creation'
    );
  }

  @isTest
  static void testSuccessfulConfirmCountUpdateConfirmedNull() {
    DateTime dateTimeVal = DateTime.newInstance(2022, 3, 11, 1, 45, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_and_Time__c = :dateTimeVal
    ];

    Test.startTest();

    /*
      Insert contact request for that appointment commitment record.
    */

    ContactRequest contReq = new ContactRequest();
    contReq.Appointment_date_and_time__c = DateTime.newInstance(
      2022,
      3,
      11,
      1,
      45,
      0
    );
    contReq.Appointment_Commitment__c = apptCommtRec.Id;
    contReq.PreferredChannel = 'Call';
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_and_Time__c = :dateTimeVal
    ];

    /*
      Assert the count of the confirmed field after appointment commitment creation.
    */

    System.assertEquals(
      apptCommtRec2.Confirmed__c,
      1,
      'Confirmed count should be updated after contact request creation'
    );
  }

  @isTest
  static void testContactRequestQueueOwnerAssignment() {
    DateTime dateTimeVal = DateTime.newInstance(2022, 3, 11, 1, 45, 0);

    Test.startTest();

    /*
      Insert a new contact request record.
    */

    ContactRequest contReq = new ContactRequest();
    contReq.Appointment_date_and_time__c = dateTimeVal;
    contReq.PreferredChannel = 'Call';
    insert contReq;

    Test.stopTest();

    ContactRequest conReq = [
      SELECT OwnerId
      FROM ContactRequest
      WHERE Appointment_date_and_time__c = :dateTimeVal
    ];

    Group contactRequestQueue = [
      SELECT Id
      FROM Group
      WHERE Type = 'Queue' AND Name = :'Contact Request'
    ];

    /*
      Assert the the owner of the new contact request record
    */

    System.assertEquals(
      conReq.OwnerId,
      contactRequestQueue.Id,
      'Contact request owner should be assigned to Contact Request Queue'
    );
  }

  static void testContactRequestCancellation() {
    List<ContactRequest> contactRequestList = [
      SELECT Id, Status
      FROM ContactRequest
      WHERE Status = 'New'
    ];

    List<ContactRequest> updatedRequests = new List<ContactRequest>();
    for (ContactRequest contactRequest : [
      SELECT Id, Status
      FROM ContactRequest
      WHERE Status = 'New'
    ]) {
      contactRequest.Status = 'Cancelled';
      updatedRequests.add(contactRequest);
    }

    update updatedRequests;

    List<Interaction> interactionList = [
      SELECT Id
      FROM Interaction
      WHERE Status__c = 'New'
    ];
    System.assertEquals(0, interactionList.size());
  }

  @isTest
  static void testAutomaticInteractionCreation() {
    string otherPurposeName = 'Other';
    Integer otherPurposeDuration = 30;
    string contactRequestQueueName = 'Contact Request';
    Account testAccount = createTestAccounts(1)[0];

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

    test.startTest();
    update request;
    test.stopTest();

    request = [
      SELECT Id, Status, Interaction__c
      FROM ContactRequest
      WHERE Id = :request.Id
    ];

    system.assertEquals(
      'Accepted',
      request.Status,
      'The requests status should have been set to Accepted.'
    );

    List<Interaction> interactions = [SELECT Id FROM Interaction];

    system.assertNotEquals(
      null,
      interactions,
      'Interactions should not be null'
    );
    system.assertNotEquals(
      0,
      interactions.size(),
      'At least 1 interaction must be created'
    );

    System.assertEquals(
      interactions[0].Id,
      request.Interaction__c,
      'Interaction must be set on Contact Request'
    );

    List<InteractionSummary> summaries = [SELECT Id FROM InteractionSummary];

    system.assertNotEquals(null, summaries, 'Summaries should not be null');
    system.assertNotEquals(
      0,
      summaries.size(),
      'At least 1 summary must be created'
    );

    List<Event> events = [SELECT Id FROM Event];

    system.assertNotEquals(null, events, 'Events should not be null');
    system.assertNotEquals(
      0,
      events.size(),
      'At least 1 event must be created'
    );
  }

  @isTest
  static void testBulkAutomaticInteractionCreation() {
    Integer sizeTest = 200;
    List<Account> accounts = createTestAccounts(sizeTest);

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

    List<ContactRequest> requests = createContactRequests(
      accounts,
      contactRequestQueue[0].Queue.Id
    );
    insert requests;

    for (ContactRequest request : requests) {
      request.OwnerId = UserInfo.getUserId();
    }

    test.startTest();
    update requests;
    test.stopTest();

    List<Interaction> interactions = [
      SELECT Id, Interaction_Summary__c
      FROM Interaction
    ];
    System.assertEquals(
      sizeTest,
      interactions.size(),
      'Should have created equal number of interactions to Contact Requests'
    );

    System.assertNotEquals(
      null,
      interactions[0].Interaction_Summary__c,
      'Interaction Summary field must be populated on Interaction once it is created'
    );
  }

  /**
   * @description creates a Contact request for each account in a provided list
   * @param accounts List<Account> list of accounts
   * @param ownerId Id the Id of the Owner of the Contact Requests
   * @return List<ContactRequest> resultant contact requests
   */
  static List<ContactRequest> createContactRequests(
    List<Account> accounts,
    Id ownerId
  ) {
    List<ContactRequest> requests = new List<ContactRequest>();
    Faker faker = new Faker('AU');
    for (Account currentAccount : accounts) {
      DateTime appointmentDate = DateTime.newInstance(
        DateTime.now().year() + 1, //Year
        faker.randomIntegerBetween(1, 12), //month
        faker.randomIntegerBetween(1, 28), //date
        faker.randomIntegerBetween(7, 20), //hour
        faker.randomIntegerBetween(0, 1) * 30, //minute
        0 //second
      );

      ContactRequest request = new ContactRequest();
      request.OwnerId = ownerId;
      request.Appointment_date_and_Time__c = appointmentDate;
      request.RequestReason = otherPurposeName;
      request.WhoId = currentAccount.PersonContactId;
      request.PreferredChannel = 'Call';
      requests.add(request);
    }
    return requests;
  }

  /**
   * @description creates multiple person accounts (does insert)
   * @param numberOfAccounts Integer the number of accounts to created
   * @return List<Account> list of created accounts
   */
  static List<Account> createTestAccounts(Integer numberOfAccounts) {
    List<Account> result = new List<Account>();
    Faker faker = new Faker('AU');
    for (Integer i = 0; i < numberOfAccounts; i++) {
      string firstName = faker.person.firstName();
      string lastName = faker.person.lastName();
      string oCVID = faker.randomString(10);

      Account newAccount = createTestAccount(firstName, lastName, oCVID);
      result.add(newAccount);
    }

    insert result;
    Set<Id> accountIds = (new Map<Id, Account>(result)).keySet();

    result = [SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds];

    return result;
  }

  /**
   * @description helper method to create a person account
   * @return Account a Person Account with Name Fred Smith, OCV ID 123456
   */
  static Account createTestAccount() {
    return createTestAccount('Fred', 'Smith', '123456');
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
