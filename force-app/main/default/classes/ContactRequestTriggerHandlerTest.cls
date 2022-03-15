@isTest
private class ContactRequestTriggerHandlerTest {
  //Test data setup
  @testSetup
  static void testDataSetup() {
    //Insert appointment commitment records
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

    //Check the count of the confirmed field before appointment commitment record is created.
    System.assertEquals(
      apptCommtRec.Confirmed__c,
      2,
      'Confirmed Count before Contact Request is created.'
    );

    Test.startTest();

    //Insert contact request for that appointment commitment record.
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

    //Assert the count of the confirmed field after appointment commitment creation.
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

    //Insert contact request for that appointment commitment record.
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

    //Assert the count of the confirmed field after appointment commitment creation.
    System.assertEquals(
      apptCommtRec2.Confirmed__c,
      1,
      'Confirmed count should be updated after contact request creation'
    );
  }
}
