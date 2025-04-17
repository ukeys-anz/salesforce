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
    TwilioContextResponse twilioResponse = new TwilioContextResponse();
    try {
      //Twilio Detail Record inserted by Twilio
      twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequest
      );
      //Interaction attendee addition logic for conference scenario
      InteractionAttendee conferenceAttendee = InteractionAttendeeActions.insertTwilioConferenceAttendee(
        contextRequest
      );
      if(conferenceAttendee != null){
        DML_REPOSITORY.doInsert(conferenceAttendee, new DMLConfig().systemMode());
      }
    } catch (Exception objectException) {
      throw CommonUtil.logException(objectException);
    }
    String jsonRes = JSON.serialize(twilioResponse);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = twilioResponse.statusCode;
  }
}