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
  global static void doPost(
    List<UpdateInteractionByTwilioPayload> contextRequest
  ) {
    Integer finalStatus = 200;
    List<TwilioContextResponse> twilioResponse = new List<TwilioContextResponse>();
    try {
      //Twilio Detail Record inserted by Twilio
      twilioResponse = TwilioServiceUtil.upsertTwilioDetailsRecord(
        contextRequest
      );
    } catch (Exception e) {
      Logger.error('Error updating interaction using open CTI', e);
      Logger.saveLog();
      throw e;
    }
    String jsonRes = JSON.serialize(twilioResponse);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatus;
  }

  /**
   * @author Shivam Swaraj
   * @since  July 2023
   * @description Wrapper class to store Twilio Context Response parameters
   */
  global class UpdateInteractionByTwilioPayload {
    /**
     * @description Interaction ID
     */
    public Id interactionId { get; set; }
    /**
     * @description twilioId
     */
    public String twilioId { get; set; }
    /**
     * @description chatOrCallId
     */
    public String chatOrCallId { get; set; }
    /**
     * @description chatOrCallStatus
     */
    public String chatOrCallStatus { get; set; }
    /**
     * @description callRecordingId
     */
    public String callRecordingId { get; set; }
    /**
     * @description queueName
     */
    public String queueName { get; set; }
    /**
     * @description agentEmail
     */
    public String agentEmail { get; set; }
  }

  /**
   * @description Wrapper class to store Twilio Context Response parameters
   */
  global class TwilioContextResponse {
    /**
     * @description Response result (true or false)
     */
    public Boolean success { get; set; }
    /**
     * @description Response code. 200 for success. 400 for failure.
     */
    public Integer statusCode { get; set; }
    /**
     * @description Error Message for failure response
     */
    public String errorMessage { get; set; }
  }
}
