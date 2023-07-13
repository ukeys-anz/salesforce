/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Util Class to handle incoming requests from Twilio for Twilio Details Upsert and Interaction Update.
 */
public with sharing class TwilioServiceUtil {
  /**
   * @description method passing incoming twilio context in to Salesforce.
   * @param twilioContextRequest Twilio Context Request
   * @return InteractionContextServiceUpdate.TwilioContextResponse to send the response back to Twilio
   */
  public static List<InteractionContextServiceUpdate.TwilioContextResponse> upsertTwilioDetailsRecord(
    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> twilioContextRequest
  ) {
    List<Twilio_Details__c> twilioDetailRecordToInsertOrUpdate = new List<Twilio_Details__c>();
    List<Interaction> interactionToBeUpdated = new List<Interaction>();
    Set<String> agentEmailList = new Set<String>();
    Map<String, Id> agentOwnerIdMap = new Map<String, Id>();
    List<InteractionContextServiceUpdate.TwilioContextResponse> responseList = new List<InteractionContextServiceUpdate.TwilioContextResponse>();
    for (
      Integer intCount = 0; intCount < twilioContextRequest.size(); intCount++
    ) {
      InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload res = twilioContextRequest.get(
        intCount
      );
      Twilio_Details__c twilioDetailRecord = new Twilio_Details__c();
      twilioDetailRecord.Twilio_ID__c = res.twilioId;
      twilioDetailRecord.Chat_or_Call_SID__c = res.chatOrCallId;
      twilioDetailRecord.Status__c = res.chatOrCallStatus;
      twilioDetailRecord.Call_Recording_Id__c = res.callRecordingId;
      twilioDetailRecord.ANZ_Queue__c = res.queueName;
      if (res.agentEmail != null) {
        agentEmailList.add(res.agentEmail);
      }
      twilioDetailRecordToInsertOrUpdate.add(twilioDetailRecord);
    }

    //Creating map of agent email and owner id
    for (User agent : [
      SELECT Id, Email
      FROM User
      WHERE email IN :agentEmailList
    ]) {
      agentOwnerIdMap.put(agent.Email, agent.Id);
    }

    //Upsert Twilio Details
    List<Database.UpsertResult> lstUpsertResult = Database.upsert(
      twilioDetailRecordToInsertOrUpdate,
      Twilio_Details__c.Chat_or_Call_SID__c,
      false
    );

    for (
      Integer intUpsertCount = 0;
      intUpsertCount < lstUpsertResult.size();
      intUpsertCount++
    ) {
      Database.UpsertResult twilioRecordUpserted = lstUpsertResult.get(
        intUpsertCount
      );
      InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload payLoad = twilioContextRequest.get(
        intUpsertCount
      );

      if (twilioRecordUpserted.isSuccess()) {
        responseList.add(generateResponse());
        String ownerId = '';
        if (!String.isBlank(payLoad.agentEmail)) {
          ownerId = agentOwnerIdMap.get(payLoad.agentEmail);
          interactionToBeUpdated.add(
            new Interaction(
              Id = payLoad.interactionId,
              OwnerId = ownerId,
              TwilioDetailsID__c = twilioRecordUpserted.getId()
            )
          );
        } else {
          interactionToBeUpdated.add(
            new Interaction(
              Id = payLoad.interactionId,
              TwilioDetailsID__c = twilioRecordUpserted.getId()
            )
          );
        }
      } else {
        List<Database.Error> err = twilioRecordUpserted.getErrors();
        String errorvalues = String.join(err, '/n');
        responseList.add(generateErrorResponse(errorvalues));
      }
    }

    Database.update(interactionToBeUpdated, false);
    return responseList;
  }

  /**
   * @description Method to generate a response instance
   * @return `InteractionContextServiceUpdate.TwilioContextResponse`
   */
  private static InteractionContextServiceUpdate.TwilioContextResponse generateResponse() {
    InteractionContextServiceUpdate.TwilioContextResponse response = new InteractionContextServiceUpdate.TwilioContextResponse();
    response.success = true;
    response.statusCode = 200;
    return response;
  }

  /**
   * @description Method to generate a response instance
   * @param errMsg error message for twilio response
   * @return `InteractionContextServiceUpdate.TwilioContextResponse`
   */
  private static InteractionContextServiceUpdate.TwilioContextResponse generateErrorResponse(
    String errMsg
  ) {
    InteractionContextServiceUpdate.TwilioContextResponse response = new InteractionContextServiceUpdate.TwilioContextResponse();
    response.errorMessage = errMsg;
    response.success = false;
    response.statusCode = 400;
    return response;
  }
}
