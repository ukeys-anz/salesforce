@isTest
private class ContactRequestTriggerHandlerTest {
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
    apptCommt.Date_AEDT__c = Date.newInstance(2022, 3, 10);
    apptCommt.Time__c = Time.newInstance(12, 45, 0, 0);
    apptCommtRecords.add(apptCommt);

    Appointment_Commitment__c apptCommt2 = new Appointment_Commitment__c();
    apptCommt2.Available__c = 5;
    apptCommt2.Date_AEDT__c = Date.newInstance(2022, 3, 11);
    apptCommt2.Time__c = Time.newInstance(1, 45, 0, 0);
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
        PreferredChannel = 'Phone',
        RequestReason = 'Financial Wellbeing',
        Status = 'New'
      );

      contactRequestList.add(contactReq);
    }

    insert contactRequestList;
  }

  @isTest
  static void testSuccessfulConfirmCountUpdate() {
    Date dateVal = Date.newInstance(2022, 3, 10);
    Time timeVal = Time.newInstance(12, 45, 0, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_AEDT__c = :dateVal AND Time__c = :timeVal
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
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_AEDT__c = :dateVal AND Time__c = :timeVal
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
    Date dateVal = Date.newInstance(2022, 3, 11);
    Time timeVal = Time.newInstance(1, 45, 0, 0);

    Appointment_Commitment__c apptCommtRec = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_AEDT__c = :dateVal AND Time__c = :timeVal
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
    insert contReq;

    Test.stopTest();

    Appointment_Commitment__c apptCommtRec2 = [
      SELECT ID, Confirmed__c
      FROM Appointment_Commitment__c
      WHERE Date_AEDT__c = :dateVal AND Time__c = :timeVal
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
}
