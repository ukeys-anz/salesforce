/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description APEX REST API class to handle incoming requests from Twilio.
 */
@RestResource(urlMapping='/InteractionContextRequestUpdates/*')
global with sharing class InteractionContextServiceUpdate {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  /**
   * @description HTTP POST method passing incoming Twilio context in to Salesforce.
   * @param contextRequest twilio context request
   */
  @HttpPost
  global static void doPost(UpdateInteractionByTwilioPayload contextRequest) {
    try {

      if(contextRequest.agentEmail!=null)
      {
        enrichContextRequestWithAgentUserId(contextRequest);
      }

      //Twilio Detail Record inserted by Twilio
      TwilioContextResponse twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequest
      );
      
      if(TwilioServiceUtil.checkIsConference(twilioContextRequest))
      {
        //Interaction attendee addition logic for conference scenario
        InteractionAttendee conferenceAttendee = InteractionAttendeeActions.insertTwilioConferenceAttendee(
          contextRequest
        );
      
        DML_REPOSITORY.doInsert(
          conferenceAttendee,
          new DMLConfig().systemMode()
        );
      }
    

      String jsonRes = JSON.serialize(twilioResponse);
      RestContext.response.addHeader('Content-Type', 'application/json');
      RestContext.response.responseBody = Blob.valueOf(jsonRes);
      RestContext.response.statusCode = twilioResponse.statusCode;
    } catch (Exception objectException) {
      Logger.error(
        'Interaction Update from Twilio with chatorCalSid' +contextRequest.chatOrCallId+ ' failed with error message: ',
        objectException
      ).save();
      throw objectException;
    }
  }

  /**
   * @description Append agentUserRecord Id based on the agenEmail from Twilio
   * @param contextRequest twilio context request
   */
  private static void enrichContextRequestWithAgentUserId(UpdateInteractionByTwilioPayload contextRequest){
    User agentUserRecord = INTERACTION_REPOSITORY.fetchAgentUserId(
      contextRequest.agentEmail
    );
    if(agentUserRecord!=null)
    {
      contextRequest.agentUserId = agentUserRecord.Id;
    }
  }
}