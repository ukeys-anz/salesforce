/**
 * @author
 * @since  August 2022
 * @description SOAP API class that will update Interaction with Twilio ID.
 */
global with sharing class InteractionTwilioService {
  /**
   * @description method passing incoming interaction context in to Salesforce.
   * Salesforce would then update the interaction using the interaction Id
   * @param jsonString contains the payload
   */
  webService static void updateInteraction(String jsonString) {
    try {
      UpdateInteractionPayload params = (UpdateInteractionPayload) JSON.deserialize(
        jsonString,
        UpdateInteractionPayload.class
      );

      Interaction interactionRecord = new Interaction();
      interactionRecord.Id = params.interactionId;
      if (params.twilioId != null) {
        interactionRecord.Twilio_ID__c = params.twilioId;
      }
      if (params.chatOrCallId != null) {
        interactionRecord.Chat_or_Call_SID__c = params.chatOrCallId;
      }

      update interactionRecord;
    } catch (Exception e) {
      Logger.error('Error updating interaction using open CTI', e);
      Logger.saveLog();
      throw e;
    }
  }

  @TestVisible
  private class UpdateInteractionPayload {
    @TestVisible
    Id interactionId;
    @TestVisible
    String twilioId;
    @TestVisible
    String chatOrCallId;
  }
}
