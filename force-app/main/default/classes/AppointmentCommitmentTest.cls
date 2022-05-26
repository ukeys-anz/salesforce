/**
 * @description Class for tests involving Appointment Commitment
 * @since 20220526
 * @author Adam Phillip Smith
 */
@isTest
public with sharing class AppointmentCommitmentTest {
  @isTest
  public static void testCantBookMoreThanAvailable() {
    DateTime startDate = DateTime.newInstance(
      DateTime.now().year() + 1,
      3,
      10,
      12,
      45,
      0
    );

    Appointment_Commitment__c appointmentCommitment = new Appointment_Commitment__c(
      Available__c = 2,
      Type__c = 'Financial Wellbeing',
      Date_and_Time__c = startDate,
      Appointment_Channel__c = 'Call'
    );
    insert appointmentCommitment;

    ContactRequest testRequest1 = createRequest(appointmentCommitment);
    ContactRequest testRequest2 = createRequest(appointmentCommitment);
    insert testRequest1;
    insert testRequest2;

    ContactRequest testRequest3 = createRequest(appointmentCommitment);

    test.startTest();
    Exception thrownException;
    try {
      insert testRequest3;
    } catch (Exception exc) {
      thrownException = exc;
    }

    List<ContactRequest> createdRequests = [SELECT Id FROM ContactRequest];

    System.assertEquals(
      2,
      createdRequests.size(),
      'There should only be two appointments created'
    );
  }

  /**
   * @description Creates a Contact Request linked to an appointmentCommitment
   * @param appointmentCommitment to be linked to
   * @return ContactRequest newly created.
   */
  public static ContactRequest createRequest(
    Appointment_Commitment__c appointmentCommitment
  ) {
    ContactRequest request = new ContactRequest(
      Appointment_Commitment__c = appointmentCommitment.Id
    );
    return request;
  }
}
