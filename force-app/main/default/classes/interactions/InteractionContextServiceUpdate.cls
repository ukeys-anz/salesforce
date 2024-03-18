/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description APEX REST API class to handle incoming requests from Twilio.
 */
@RestResource(urlMapping='/InteractionContextRequestUpdates/*')
global with sharing class InteractionContextServiceUpdate {
  /**
   * @description HTTP POST method passing incoming Twilio context in to Salesforce.
   * @param contextRequest twilio context request
   */
  @HttpPost
  global static void doPost(UpdateInteractionByTwilioPayload contextRequest) {
    List<UpdateInteractionByTwilioPayload> contextRequests = new List<UpdateInteractionByTwilioPayload>{
      contextRequest
    };
    Integer finalStatus = 200;
    List<TwilioContextResponse> twilioResponse = new List<TwilioContextResponse>();
    try {
      //Twilio Detail Record inserted by Twilio
      twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequests
      );
      //Interaction attendee addition logic for conference scenario
      List<InteractionAttendee> conferenceAttendeeList = InteractionAttendeeActions.insertTwilioConferenceAttendee(
        contextRequests[0],
        TwilioServiceUtil.agentOwnerIdMap
      );

      DMLUtil.insertRecords(conferenceAttendeeList, false, false);
    } catch (Exception e) {
      Logger.error('Error upserting Twilio Details and Interaction', e);
      Logger.saveLog();
      throw e;
    }
    String jsonRes = JSON.serialize(twilioResponse.get(0));
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatus;
  }
}
