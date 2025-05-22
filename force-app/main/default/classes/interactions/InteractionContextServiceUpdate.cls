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
      contextRequest.agentUserId = enrichContextRequestWithAgentUserId(contextRequest)?.Id;
      //Twilio Detail Record inserted by Twilio
      TwilioContextResponse twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequest
      );
      
      //Interaction attendee addition logic for conference scenario
      InteractionAttendee conferenceAttendee = InteractionAttendeeActions.insertTwilioConferenceAttendee(
        contextRequest
      );
     
      if (conferenceAttendee != null)
      {
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
        'Interaction Update from Twilio with chatorCalSid ' +contextRequest.interactionId+ ' failed with error message: ',
        objectException
      ).save();
      throw objectException;
    }
  }

  /**
   * @description Append agentUserRecord Id based on the agenEmail from Twilio
   * @param contextRequest twilio context request
   * @return User record based on the agentEmail
   */
  private static User enrichContextRequestWithAgentUserId(UpdateInteractionByTwilioPayload contextRequest){
    if (contextRequest.agentEmail == null)
    {
      return null;
    }
    return INTERACTION_REPOSITORY.fetchAgentUserId(
      contextRequest.agentEmail
    );
  }
}