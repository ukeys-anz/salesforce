/**
 * @author
 * @since August 2022
 * @description InteractionTwilioServiceTest is the test class for InteractionTwilioService Class.
 */
@isTest
private class InteractionTwilioServiceTest {
  @isTest
  static void updateInteractionFail() {
    Test.startTest();
    try {
      InteractionTwilioService.UpdateInteractionPayload payload = new InteractionTwilioService.UpdateInteractionPayload();
      payload.interactionId = '0123456789';
      InteractionTwilioService.updateInteraction(JSON.serialize(payload));
      System.assertEquals(true, false, 'The code should throw an exception');
    } catch (Exception e) {
      System.assertEquals(
        'Invalid id: 0123456789',
        e.getMessage(),
        'Exception message should be as expected'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void updateInteractionSuccess() {
    Faker faker = new Faker('AU');
    Interaction interactionRecord = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      Name = faker.randomString(10)
    );
    insert interactionRecord;

    InteractionTwilioService.UpdateInteractionPayload payload = new InteractionTwilioService.UpdateInteractionPayload();
    payload.interactionId = interactionRecord.Id;
    payload.twilioId = 'TWILIO_ID';
    payload.chatOrCallId = 'CHAT_OR_CALL_ID';
    payload.chatOrCallStatus = 'CHAT_OR_CALL_STATUS';
    payload.callRecordingId = 'CALL_RECORDING_ID';
    payload.queueName = 'QUEUE_NAME';

    Test.startTest();
    InteractionTwilioService.updateInteraction(JSON.serialize(payload));
    Test.stopTest();

    Interaction updatedRecord = [
      SELECT Id, Twilio_ID__c, Chat_or_Call_SID__c, TwilioDetailsID__c
      FROM Interaction
      WHERE Id = :interactionRecord.Id
    ];
    Twilio_Details__c insertedTwilioDetailRecord = [
      SELECT
        Id,
        Twilio_ID__c,
        Chat_or_Call_SID__c,
        Call_Recording_Id__c,
        ANZ_Queue__c
      FROM Twilio_Details__c
      WHERE Id = :updatedRecord.TwilioDetailsID__c
    ];

    System.assertEquals(
      'TWILIO_ID',
      updatedRecord.Twilio_ID__c,
      'Updated Record Twilio Id does not match'
    );
    System.assertEquals(
      'CHAT_OR_CALL_ID',
      updatedRecord.Chat_or_Call_SID__c,
      'Updated Record Chat or Call SID does not match'
    );
    // System.assertEquals(
    //   'CHAT_OR_CALL_STATUS',
    //   insertedTwilioDetailRecord.Status__c,
    //   'Inserted Twilio Record Status does not match'
    // );
    System.assertEquals(
      'CALL_RECORDING_ID',
      insertedTwilioDetailRecord.Call_Recording_Id__c,
      'Inserted Twilio Record Call Recording Id does not match'
    );
    System.assertEquals(
      'QUEUE_NAME',
      insertedTwilioDetailRecord.ANZ_Queue__c,
      'Inserted Twilio ANZ Queue does not match'
    );
  }
}
