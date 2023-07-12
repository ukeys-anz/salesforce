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
      //Twilio Detail Record inserted by Twilio
      Twilio_Details__c twilioDetailRecord = upsertTwilioDetailsRecord(params);
      Interaction interactionRecord = new Interaction();
      interactionRecord.Id = params.interactionId;
      if (params.twilioId != null) {
        interactionRecord.Twilio_ID__c = params.twilioId;
      }
      if (params.chatOrCallId != null) {
        interactionRecord.Chat_or_Call_SID__c = params.chatOrCallId;
      }
      if (twilioDetailRecord.Id != null) {
        interactionRecord.TwilioDetailsID__c = twilioDetailRecord.id;
      }
      interactionRecord.OwnerId = UserInfo.getUserId();
      update interactionRecord;
    } catch (Exception e) {
      Logger.error('Error updating interaction using open CTI', e);
      Logger.saveLog();
      throw e;
    }
  }

  private static Twilio_Details__c upsertTwilioDetailsRecord(
    UpdateInteractionPayload params
  ) {
    Twilio_Details__c twilioDetailRecordToInsertOrUpdate = new Twilio_Details__c();
    twilioDetailRecordToInsertOrUpdate.Twilio_ID__c = params.twilioId;
    twilioDetailRecordToInsertOrUpdate.Chat_or_Call_SID__c = params.chatOrCallId;
    //twilioDetailRecordToInsertOrUpdate.Status__c = params.chatOrCallStatus;
    twilioDetailRecordToInsertOrUpdate.Call_Recording_Id__c = params.callRecordingId;
    twilioDetailRecordToInsertOrUpdate.ANZ_Queue__c = params.queueName;
    Database.upsert(
      twilioDetailRecordToInsertOrUpdate,
      Twilio_Details__c.Call_Recording_Id__c
    );
    return twilioDetailRecordToInsertOrUpdate;
  }

  @TestVisible
  private class UpdateInteractionPayload {
    @TestVisible
    Id interactionId;
    @TestVisible
    String twilioId;
    @TestVisible
    String chatOrCallId;
    @TestVisible
    String chatOrCallStatus;
    @TestVisible
    String callRecordingId;
    @TestVisible
    String queueName;
  }
}
