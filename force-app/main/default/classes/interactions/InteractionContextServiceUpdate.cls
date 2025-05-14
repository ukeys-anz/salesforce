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
  /**
   * @description HTTP POST method passing incoming Twilio context in to Salesforce.
   * @param contextRequest twilio context request
   */
  @HttpPost
  global static void doPost(UpdateInteractionByTwilioPayload contextRequest) {
    try {
      //Twilio Detail Record inserted by Twilio
      TwilioContextResponse twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequest
      );
      //Interaction attendee addition logic for conference scenario
      InteractionAttendee conferenceAttendee = InteractionAttendeeActions.insertTwilioConferenceAttendee(
        contextRequest
      );
      if (conferenceAttendee != null) {
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
      throw CommonUtil.logExceptionWithMessage(
        'Interaction Update from Twilio with chatorCalSid' +contextRequest.chatOrCallId+ ' failed with error message: ',
        objectException
      );
    }
  }
}