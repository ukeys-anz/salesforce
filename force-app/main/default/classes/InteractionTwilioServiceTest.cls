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
      System.assertEquals('Invalid id: 0123456789', e.getMessage());
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

    InteractionTwilioService.UpdateInteractionPayload payload1 = new InteractionTwilioService.UpdateInteractionPayload();
    payload1.interactionId = interactionRecord.Id;
    payload1.twilioId = 'TWILIO_ID';

    InteractionTwilioService.UpdateInteractionPayload payload2 = new InteractionTwilioService.UpdateInteractionPayload();
    payload2.interactionId = interactionRecord.Id;
    payload2.chatOrCallId = 'CHAT_OR_CALL_ID';

    Test.startTest();
    InteractionTwilioService.updateInteraction(JSON.serialize(payload1));
    InteractionTwilioService.updateInteraction(JSON.serialize(payload2));
    Test.stopTest();

    Interaction updatedRecord = [
      SELECT Id, Twilio_ID__c, Chat_or_Call_SID__c
      FROM Interaction
      WHERE Id = :interactionRecord.Id
    ];
    System.assertEquals('TWILIO_ID', updatedRecord.Twilio_ID__c);
    System.assertEquals('CHAT_OR_CALL_ID', updatedRecord.Chat_or_Call_SID__c);
  }
}
