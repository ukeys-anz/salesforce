@isTest
private class ContactRequestTriggerHandlerTest {
  static Integer otherPurposeDuration = 30;
  /*
    Test data setup 
  */

  @testSetup
  static void testDataSetup() {
    /*
      Insert appointment commitment records
    */

    DateTime start = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);
    Faker faker = new Faker('AU');

    Schema.Location loc = new Schema.location();
    loc.Name = faker.randomString(10);
    loc.LocationType = InteractionConstants.STORE;
    insert loc;

    List<Appointment_Commitment__c> apptCommtRecords = new List<Appointment_Commitment__c>();

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 5;
    apptCommt.Confirmed__c = 2;
    apptCommt.Type__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    apptCommt.Location__c = loc.Id;
    apptCommt.Date_and_Time__c = DateTime.newInstance(2022, 3, 10, 12, 45, 0);
    apptCommt.Appointment_Channel__c = InteractionConstants.STORE;
    apptCommtRecords.add(apptCommt);

    Appointment_Commitment__c apptCommt2 = new Appointment_Commitment__c();
    apptCommt2.Available__c = 5;
    apptCommt2.Date_and_Time__c = DateTime.newInstance(2022, 3, 11, 1, 45, 0);
    apptCommt2.Appointment_Channel__c = InteractionConstants.STORE;
    apptCommtRecords.add(apptCommt2);

    insert apptCommtRecords;
    Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account account = new Account(
      FirstName = faker.person.firstName(),
      LastName = faker.person.lastName(),
      OCV_ID__c = faker.randomString(10),
      ANZx_Customer__c = true,
      RecordTypeId = personAccountRecordTypeId
    );

    insert account;

    account = [SELECT Id, PersonContactId FROM Account WHERE Id = :account.Id];

    Schema.Location testLocation = new Schema.Location();
    testLocation.Name = faker.randomString(10);
    testLocation.LocationType = InteractionConstants.STORE;
    insert testLocation;

    List<ContactRequest> contactRequestList = new List<ContactRequest>();
    List<Interaction> interactionList = new List<Interaction>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      Interaction interaction = new Interaction(
        AccountId = account.Id,
        Name = faker.randomString(10) + i,
        Status__c = InteractionConstants.NEW_STATUS
      );

      interactionList.add(interaction);

      ContactRequest contactReq = new ContactRequest(
        PreferredChannel = InteractionConstants.STORE,
        RequestReason = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME,
        Status = InteractionConstants.NEW_STATUS,
        Appointment_Date_And_Time__c = start,
        WhoId = account.PersonContactId,
        Location__c = testLocation.Id
      );

      contactRequestList.add(contactReq);
    }

    insert contactRequestList;
  }

  /*
   * Test method for contact request prepopulation
   */

  @isTest
  static void testContactRequestPrepopulation() {
    Account testAccount = createTestAccounts(1)[0];
    Datetime dateTimeVal = DateTime.newInstance(2022, 3, 10, 12, 45, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT
        ID,
        Confirmed__c,
        Type__c,
        Location__c,
        Date_and_Time__c,
        Appointment_Channel__c
      FROM Appointment_Commitment__c
      WHERE Date_and_Time__c = :dateTimeVal
    ];

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
    contReq.WhoId = testAccount.PersonContactId;
    insert contReq;

    contReq = [
      SELECT
        Id,
        Name,
        Contact_Request_Auto_Number__c,
        RequestReason,
        Appointment_date_and_Time__c,
        Location__c,
        PreferredChannel
      FROM ContactRequest
      WHERE Id = :contReq.Id
    ];

    System.assertEquals(
      contReq.RequestReason,
      apptCommtRec.Type__c,
      'The request reason should be updated with the appointment commitment type'
    );

    System.assertEquals(
      contReq.Appointment_date_and_Time__c,
      apptCommtRec.Date_and_Time__c,
      'The date and time should be updated with the appointment commitment date and time'
    );

    System.assertEquals(
      contReq.Location__c,
      apptCommtRec.Location__c,
      'The location should be updated with the appointment commitment location'
    );

    System.assertEquals(
      apptCommtRec.Appointment_Channel__c,
      contReq.PreferredChannel,
      'The PreferredChannel should be updated with the appointment commitment Channel'
    );
  }

  @isTest
  static void testBulkContactRequestPrepopulation() {
    Faker faker = new Faker('AU');
    Schema.Location loc = new Schema.location();
    loc.Name = faker.randomString(10);
    loc.LocationType = InteractionConstants.STORE;
    insert loc;

    Account testAccount = createTestAccounts(1)[0];
    Datetime dateTimeVal = DateTime.newInstance(2022, 5, 12, 12, 45, 0);

    Appointment_Commitment__c apptCommt = new Appointment_Commitment__c();
    apptCommt.Available__c = 100;
    apptCommt.Confirmed__c = 0;
    apptCommt.Type__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    apptCommt.Location__c = loc.Id;
    apptCommt.Appointment_Channel__c = InteractionConstants.CALL;
    apptCommt.Date_and_Time__c = dateTimeVal;
    insert apptCommt;

    List<ContactRequest> crList = new List<ContactRequest>();
    for (Integer i = 0; i < 100; i++) {
      ContactRequest contReq = new ContactRequest();
      contReq.Appointment_Commitment__c = apptCommt.Id;
      contReq.WhoId = testAccount.PersonContactId;
      crList.add(contReq);
    }

    insert crList;

    crList = [
      SELECT Id, RequestReason, Appointment_date_and_Time__c, Location__c
      FROM ContactRequest
      WHERE PreferredChannel = :InteractionConstants.CALL
    ];

    Integer counter = 0;

    for (ContactRequest contReq : crList) {
      System.assertEquals(
        contReq.RequestReason,
        apptCommt.Type__c,
        'The request reason should be updated with the appointment commitment type ' +
        counter
      );

      System.assertEquals(
        contReq.Appointment_date_and_Time__c,
        apptCommt.Date_and_Time__c,
        'The date and time should be updated with the appointment commitment date and time ' +
        counter
      );

      System.assertEquals(
        contReq.Location__c,
        apptCommt.Location__c,
        'The location should be updated with the appointment commitment location ' +
        counter
      );

      counter++;
    }
  }

  @isTest
  static void testSuccessfulConfirmCountUpdate() {
    Account testAccount = createTestAccounts(1)[0];
    Datetime dateTimeVal = DateTime.newInstance(2022, 3, 10, 12, 45, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT ID, Confirmed__c, Appointment_Channel__c
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
    contReq.PreferredChannel = InteractionConstants.CALL;
    contReq.WhoId = testAccount.PersonContactId;
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c, Appointment_Channel__c
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
    Account testAccount = createTestAccounts(1)[0];
    DateTime dateTimeVal = DateTime.newInstance(2022, 3, 11, 1, 45, 0);

    Appointment_Commitment__c apptCommtRec = new Appointment_Commitment__c();
    apptCommtRec.Available__c = 5;
    apptCommtRec.Confirmed__c = 2;
    apptCommtRec.Type__c = InteractionConstants.FINANCIAL_WELLBEING_PURPOSE_NAME;
    apptCommtRec.Date_and_Time__c = DateTime.newInstance(
      2022,
      3,
      10,
      12,
      45,
      0
    );
    apptCommtRec.Appointment_Channel__c = InteractionConstants.CALL;
    insert apptCommtRec;

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
    contReq.PreferredChannel = InteractionConstants.CALL;
    contReq.WhoId = testAccount.PersonContactId;
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c, Appointment_Channel__c
      FROM Appointment_Commitment__c
      WHERE Id = :apptCommtRec.Id
    ];

    /*
      Assert the count of the confirmed field after appointment commitment creation.
    */

    System.assertEquals(
      3,
      apptCommtRec2.Confirmed__c,
      'Confirmed count should be updated after contact request creation'
    );
  }

  static void testContactRequestCancellation() {
    List<ContactRequest> contactRequestList = [
      SELECT Id, Status
      FROM ContactRequest
      WHERE Status = :InteractionConstants.NEW_STATUS
    ];

    List<ContactRequest> updatedRequests = new List<ContactRequest>();
    for (ContactRequest contactRequest : [
      SELECT Id, Status
      FROM ContactRequest
      WHERE Status = :InteractionConstants.NEW_STATUS
    ]) {
      contactRequest.Status = InteractionConstants.CANCELLED;
      updatedRequests.add(contactRequest);
    }

    update updatedRequests;

    List<Interaction> interactionList = [
      SELECT Id
      FROM Interaction
      WHERE Status__c = :InteractionConstants.NEW_STATUS
    ];
    System.assertEquals(0, interactionList.size());
  }

  @isTest
  static void testAutomaticInteractionCreation() {
    string otherPurposeName = InteractionConstants.OTHER_PURPOSE_NAME;
    Integer otherPurposeDuration = 30;

    Account testAccount = createTestAccounts(1)[0];

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
    test.startTest();
    insert request;
    test.stopTest();

    request = [
      SELECT Id, Status, Interaction__c
      FROM ContactRequest
      WHERE Id = :request.Id
    ];

    List<Interaction> interactions = [
      SELECT Id
      FROM Interaction
      WHERE Id = :request.Interaction__c
    ];

    System.assertEquals(
      interactions[0].Id,
      request.Interaction__c,
      'Interaction must be set on Contact Request'
    );

    system.assertNotEquals(
      null,
      interactions,
      'Interactions should not be null'
    );

    //failing as not setting the interaction id on the contact request
    system.assertNotEquals(
      0,
      interactions.size(),
      'At least 1 interaction must be created'
    );

    List<Event> events = [SELECT Id FROM Event];

    system.assertEquals(
      true,
      events.isEmpty(),
      'Events should not be created at this point'
    );
  }

  @isTest
  static void testBulkAutomaticInteractionCreation() {
    Integer sizeTest = 200;
    List<Account> accounts = createTestAccounts(sizeTest);

    Automated_Request_Purpose__mdt otherPurpose = new Automated_Request_Purpose__mdt();
    otherPurpose.MasterLabel = InteractionConstants.OTHER_PURPOSE_NAME;
    otherPurpose.Duration__c = otherPurposeDuration;
    Map<String, Automated_Request_Purpose__mdt> purposeMap = new Map<String, Automated_Request_Purpose__mdt>();
    purposeMap.put(InteractionConstants.OTHER_PURPOSE_NAME, otherPurpose);
    AutomatedRequestMetadataProvider.getInstance().setMap(purposeMap);

    List<QueueSObject> contactRequestQueue = [
      SELECT Queue.Id, Queue.Name, Queue.Type
      FROM QueueSObject
      WHERE
        Queue.Type = 'Queue'
        AND Queue.Name = :InteractionConstants.CONTACT_REQUEST_QUEUE
    ];

    List<ContactRequest> requests = createContactRequests(
      accounts,
      UserInfo.getUserId()
    );
    test.startTest();
    insert requests;
    test.stopTest();

    List<Interaction> interactions = [
      SELECT Id, Interaction_Summary__c
      FROM Interaction
    ];

    Integer expected = sizeTest + 2; //there are two in the setup.
    System.assertEquals(
      expected,
      interactions.size(),
      'Should have created equal number of interactions to Contact Requests'
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
      request.RequestReason = InteractionConstants.OTHER_PURPOSE_NAME;
      request.WhoId = currentAccount.PersonContactId;
      request.PreferredChannel = InteractionConstants.CALL;
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
    Faker faker = new Faker('AU');
    return createTestAccount(
      faker.randomString(5),
      faker.randomString(5),
      faker.randomString(6)
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
