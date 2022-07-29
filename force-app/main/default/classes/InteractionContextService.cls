/**
 * @author Rebecca Jan
 * @since  April 2022
 * @description APEX REST API class to handle incoming requests from Twilio.
 */
@RestResource(urlMapping='/InteractionContextRequests/*')
global with sharing class InteractionContextService {
  global static final String INTERACTION_TYPE = 'Call';
  global static final String INBOUND_DIRECTION = 'Inbound';
  global static final String OUTBOUND_DIRECTION = 'Outbound';
  /**
   * @description HTTP POST method passing incoming interaction context in to Salesforce.
   * Salesforce would then return a interaction id created
   * @param contextRequest interact context request
   */
  @HttpPost
  global static void doPost(InteractionContextRequest contextRequest) {
    Integer finalStatus = 200;
    InteractionContextResponse resp;

    if (
      contextRequest.direction != INBOUND_DIRECTION &&
      contextRequest.direction != OUTBOUND_DIRECTION
    ) {
      resp = generateErrorResponse('Direction should be inbound or outbound');
      finalStatus = 400;
    } else {
      Interaction intToInsert = new Interaction();

      intToInsert.Direction__c = contextRequest.direction;
      intToInsert.InteractionType = INTERACTION_TYPE;
      intToInsert.Contact_Mobile__c = contextRequest.phoneNumber;
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;

      if (PermissionUtils.canCreate('Interaction')) {
        insert intToInsert;
      }
      Interaction newInt;
      if (PermissionUtils.canQuery('Interaction')) {
        newInt = [
          SELECT Id, Interaction_External_Id__c
          FROM Interaction
          WHERE Id = :intToInsert.Id
        ];
      }
      resp = generateResponse(
        intToInsert.Id,
        newInt.Interaction_External_Id__c
      );
    }

    String jsonRes = JSON.serialize(resp);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatus;
  }

  /**
   * @description Method to generate a response instance
   * @param recordId interaction ID of the newly generated interaction.
   * @param interactionId external id of the newly generated interaction.
   * @return `InteractionContextResponse`
   */
  private static InteractionContextResponse generateResponse(
    String recordId,
    String interactionId
  ) {
    InteractionContextResponse response = new InteractionContextResponse();
    response.recordId = recordId;
    response.interactionId = interactionId;
    response.success = true;
    response.statusCode = 200;
    return response;
  }

  /**
   * @description Method to generate a response instance
   * @param errMsg error message for interaction response
   * @return `InteractionContextResponse`
   */
  private static InteractionContextResponse generateErrorResponse(
    String errMsg
  ) {
    InteractionContextResponse response = new InteractionContextResponse();
    response.errorMessage = errMsg;
    response.success = false;
    response.statusCode = 400;
    return response;
  }

  /**
   * @description Wrapper class to store Interaction Context Request parameters
   */
  global class InteractionContextRequest {
    /**
     * @description phone number from Twilio
     */
    public String phoneNumber { get; set; }
    /**
     * @description Direction from Twillio
     */
    public String direction { get; set; }
  }

  /**
   * @description Wrapper class to store Interaction Context Response parameters
   */
  global class InteractionContextResponse {
    /**
     * @description Response result (true or false)
     */
    public Boolean success { get; set; }
    /**
     * @description Response code. 200 for success. 400 for failure.
     */
    public Integer statusCode { get; set; }
    /**
     * @description Record ID
     */
    public String recordId { get; set; }
    /**
     * @description Interaction ID
     */
    public String interactionId { get; set; }
    /**
     * @description Error Message for failure response
     */
    public String errorMessage { get; set; }
  }
}
