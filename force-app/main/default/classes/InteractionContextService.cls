/**
 * @author Rebecca Jan
 * @since  April 2022
 * @description APEX REST API class to handle incoming requests from Twilio.
 * Added Chat Interaction and Twilio Details Creation Logic and updated Call Interaction Creation Logic as part of ANZX-103285 by Shivam , July 2023
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity,PMD.ExcessivePublicCount')
@RestResource(urlMapping='/InteractionContextRequests/*')
global with sharing class InteractionContextService {
  global static final String CALL_INTERACTION_TYPE = 'voice';
  global static final String CHAT_INTERACTION_TYPE = 'chat';
  global static final String INBOUND_DIRECTION = 'Inbound';
  global static final String OUTBOUND_DIRECTION = 'Outbound';
  public static Map<String, String> supportTopicMap = new Map<String, String>();
  public static Map<String, String> interactionTwilioStatusMap = new Map<String, String>();

  static {
    //Fetch Status Mapping for Twilio and Interaction
    List<InteractionStatusMappingForTwilio__mdt> statusMap = [
      SELECT Type__c, Interaction_Status__c, Twilio_Status__c
      FROM InteractionStatusMappingForTwilio__mdt
      WHERE Type__c = 'Chat'
    ];
    for (InteractionStatusMappingForTwilio__mdt status : statusMap) {
      interactionTwilioStatusMap.put(
        status.Twilio_Status__c,
        status.Interaction_Status__c
      );
    }
  }

  /**
   * @description HTTP POST method passing incoming interaction context in to Salesforce.
   * Salesforce would then return a interaction id created
   * @param contextRequest interact context request
   */
  @SuppressWarnings('PMD.CyclomaticComplexity, PMD.NcssMethodCount')
  @HttpPost
  global static void doPost(List<InteractionContextRequest> contextRequest) {
    Integer finalStatusCode = 400;

    Map<String, Id> accountsByOCVId = new Map<String, Id>();
    Map<String, InteractionContextRequest> requestByOCVId = new Map<String, InteractionContextRequest>();
    Map<String, InteractionContextRequest> requestByPhoneNumber = new Map<String, InteractionContextRequest>();
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    Set<String> callOrChatSidList = new Set<String>();
    List<Account> accountsToUpdate = new List<Account>();
    List<Interaction> interactionToBeCreated = new List<Interaction>();
    List<InteractionContextResponse> responseList = new List<InteractionContextResponse>();
    List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload> twilioDetailsByInteractionList = new List<InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload>();

    //Validating the response recived from Twilio
    if (!contextRequest.isEmpty()) {
      for (Integer intCount = 0; intCount < contextRequest.size(); intCount++) {
        InteractionContextRequest req = contextRequest.get(intCount);
        if (
          isValidRequest(req).isEmpty() &&
          req.type.toLowerCase() == CHAT_INTERACTION_TYPE
        ) {
          requestByOCVId.put(req.ocvId, req);
          callOrChatSidList.add(req.chatOrCallId);
        } else if (
          isValidRequest(req).isEmpty() &&
          req.type.toLowerCase() == CALL_INTERACTION_TYPE
        ) {
          requestByPhoneNumber.put(req.phoneNumber, req);
          callOrChatSidList.add(req.chatOrCallId);
        } else {
          responseList.addAll(isValidRequest(req));
        }
      }
    }

    //Fetching valid support topic values and creating the map.
    Schema.DescribeFieldResult fieldSupportTopicPicklistValues = Interaction.Support_Topics__c.getDescribe();
    for (
      Schema.PicklistEntry supTop : fieldSupportTopicPicklistValues.getPicklistValues()
    ) {
      supportTopicMap.put(supTop.getValue().toLowerCase(), supTop.getValue());
    }

    //Finding available accounts based on OCV Id received for Chat
    if (!requestByOCVId.isEmpty()) {
      for (Account acc : [
        SELECT Id, External_Id__c, OCV_ID__c, PPID__c
        FROM Account
        WHERE OCV_ID__c IN :requestByOCVId.keySet() AND ANZx_Customer__c = TRUE
      ]) {
        accountsByOCVId.put(acc.OCV_ID__c, acc.Id);
        // Only update PPID once or if its changed
        if (
          String.isNotBlank(requestByOCVId.get(acc.OCV_ID__c).PPID) &&
          (String.isBlank(acc.PPID__C) ||
          acc.PPID__C != requestByOCVId.get(acc.OCV_ID__c).PPID)
        ) {
          acc.PPID__C = requestByOCVId.get(acc.OCV_ID__c).PPID;
          accountsToUpdate.add(acc);
        }
      }
    }

    //For Creating List of Existing Interactions with ChatOrCallId
    if (!callOrChatSidList.isEmpty()) {
      for (Interaction interact : [
        SELECT
          Id,
          Interaction_External_Id__c,
          Account.OCV_ID__c,
          Chat_or_Call_SID__c
        FROM Interaction
        WHERE Chat_or_Call_SID__c IN :callOrChatSidList
      ]) {
        existingInteractionsBySID.put(interact.Chat_or_Call_SID__c, interact);
      }
    }

    //Creation of New Interaction Record To Be Created and Checking Existing Interations to avoid creation of new interaction
    if (!contextRequest.isEmpty()) {
      for (Integer intCount = 0; intCount < contextRequest.size(); intCount++) {
        InteractionContextRequest interactContext = contextRequest.get(
          intCount
        );
        if (
          !existingInteractionsBySID.isEmpty() &&
          existingInteractionsBySID.containsKey(interactContext.chatOrCallId)
        ) {
          responseList.add(
            generateResponse(
              existingInteractionsBySID.get(interactContext.chatOrCallId).Id,
              existingInteractionsBySID.get(interactContext.chatOrCallId)
                .Interaction_External_Id__c,
              interactContext.ocvId,
              interactContext.issueSubtype
            )
          );
        } else {
          if (
            requestByOCVId.containsKey(interactContext.ocvId) &&
            (!accountsByOCVId.isEmpty() &&
            String.isNotBlank(accountsByOCVId.get(interactContext.ocvId)))
          ) {
            interactionToBeCreated.addAll(
              createInteraction(interactContext, accountsByOCVId)
            );
          } else if (
            requestByPhoneNumber.containsKey(interactContext.phoneNumber)
          ) {
            interactionToBeCreated.addAll(
              createInteraction(interactContext, accountsByOCVId)
            );
          }
        }
      }
    }

    //Creation of Twilio Details and response to be send to Twilio
    if (!interactionToBeCreated.isEmpty()) {
      List<Database.SaveResult> results = Database.insert(
        interactionToBeCreated,
        false
      );
      Map<Id, Interaction> newInteractionMap = new Map<Id, Interaction>(
        [
          SELECT
            Id,
            Interaction_External_Id__c,
            Account.OCV_ID__c,
            Account.PersonMobilePhone,
            Support_Topics__c,
            InteractionType
          FROM Interaction
          WHERE Id IN :interactionToBeCreated
        ]
      );
      for (Integer i = 0; i < interactionToBeCreated.size(); i++) {
        Database.SaveResult sr = results[i];
        if (sr.isSuccess()) {
          InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload twilioContext = new InteractionContextServiceUpdate.UpdateInteractionByTwilioPayload();

          twilioContext.interactionId = interactionToBeCreated[i].Id;
          twilioContext.callRecordingId = contextRequest[i].callRecordingId;
          twilioContext.chatOrCallId = contextRequest[i].chatOrCallId;
          twilioContext.chatOrCallStatus = contextRequest[i].chatOrCallStatus;
          twilioContext.twilioId = contextRequest[i].twilioId;
          twilioDetailsByInteractionList.add(twilioContext);

          responseList.add(
            generateResponse(
              interactionToBeCreated[i].Id,
              newInteractionMap.get(interactionToBeCreated[i].Id)
                .Interaction_External_Id__c,
              contextRequest[i].ocvId,
              contextRequest[i].issueSubtype
            )
          );
        } else {
          List<Database.Error> err = sr.getErrors();
          String errorvalues = String.join(err, '/n');
          responseList.add(
            generateErrorResponse(
              contextRequest[i].ocvId,
              errorvalues,
              contextRequest[i].issueSubtype
            )
          );
        }
      }
    }

    if (!twilioDetailsByInteractionList.isEmpty()) {
      TwilioServiceUtil.upsertTwilioDetailsRecord(
        twilioDetailsByInteractionList
      );
    }

    //Update PPID on Account
    if (
      !accountsToUpdate.isEmpty() &&
      Account.sObjectType.getDescribe().isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.Update(
        accountsToUpdate,
        false
      );

      Logger.error('Error in Updating Account', results);
      Logger.saveLog();
    }

    // Handling responses against requests with invalid OCV Ids
    for (String ocvId : requestByOCVId.keySet()) {
      if (!accountsByOCVId.keySet().contains(ocvId)) {
        String errorMessage =
          'Could not find a matching ANZx customer record based on OCV ID: ' +
          ocvId;

        responseList.add(generateErrorResponse(ocvId, errorMessage, ''));
      }
    }

    // At least one request was successful
    for (InteractionContextResponse res : responseList) {
      if (res.statusCode == 200) {
        finalStatusCode = 200;
        break;
      }
    }

    //Creating the json response to be send to Twilio
    String jsonRes = JSON.serialize(responseList);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatusCode;
  }

  /**
   * @description Method to generate a response instance
   * @param recordId interaction ID of the newly generated interaction.
   * @param externalId external id of the newly generated interaction.
   * @param ocvId ocvId for inbound chat
   * @param chatLabel chatLabel for inbound chat
   * @return `InteractionContextResponse`
   */
  private static InteractionContextResponse generateResponse(
    String recordId,
    String externalId,
    String ocvId,
    String chatLabel
  ) {
    InteractionContextResponse response = new InteractionContextResponse();
    response.recordId = recordId;
    response.externalId = externalId;
    response.success = true;
    response.statusCode = 200;
    response.ocvId = ocvId;
    response.chatLabel = chatLabel;
    return response;
  }

  /**
   * @description Method to generate a response instance
   * @param ocvId ocvId for inbound chat
   * @param errMsg error message for interaction response
   * @param chatLabel chatLabel for inbound chat
   * @return `InteractionContextResponse`
   */
  private static InteractionContextResponse generateErrorResponse(
    String ocvId,
    String errMsg,
    String chatLabel
  ) {
    InteractionContextResponse response = new InteractionContextResponse();
    response.errorMessage = errMsg;
    response.success = false;
    response.statusCode = 400;
    response.ocvId = ocvId;
    response.chatLabel = chatLabel;
    return response;
  }

  /**
   * @description Method to check if the request record is valid or not.
   * @param validateContextRequest Chat Context instance
   * @return `list<InteractionContextResponse>` which contains error messages if any
   */
  private static List<InteractionContextResponse> isValidRequest(
    InteractionContextRequest validateContextRequest
  ) {
    List<InteractionContextResponse> responseValidation = new List<InteractionContextResponse>();
    if (!String.isBlank(validateContextRequest.Type)) {
      if (
        validateContextRequest.direction == INBOUND_DIRECTION ||
        validateContextRequest.direction == OUTBOUND_DIRECTION
      ) {
        //Check to make sure OCV ID
        if (
          String.isBlank(validateContextRequest.ocvId) &&
          String.isBlank(validateContextRequest.phoneNumber)
        ) {
          responseValidation.add(
            generateErrorResponse(
              validateContextRequest.ocvId,
              'OCVid and Phonenumber cannot be null',
              validateContextRequest.issueSubtype
            )
          );
        }
      } else {
        responseValidation.add(
          generateErrorResponse(
            validateContextRequest.ocvId,
            'Direction should be inbound or outbound',
            validateContextRequest.issueSubtype
          )
        );
      }
    } else {
      responseValidation.add(
        generateErrorResponse(
          validateContextRequest.ocvId,
          'Type value is blank',
          validateContextRequest.issueSubtype
        )
      );
    }

    return responseValidation;
  }

  /**
   * @description Wrapper class to store Interaction Context Request parameters
   */
  global class InteractionContextRequest {
    /**
     * @description chatOrCallId to identify the Twilio details
     */
    public String chatOrCallId { get; set; }
    /**
     * @description Issue Subtype as a String based on Chat context passed from App in to Twilio
     */
    public String issueSubtype { get; set; }
    /**
     * @description Direction from Twillio
     */
    public String direction { get; set; }
    /**
     * @description Customer OCV ID
     */
    public String ocvId { get; set; }
    /**
     * @description phone number from Twilio
     */
    public String phoneNumber { get; set; }
    /**
     * @description PPID from Twilio
     */
    public String ppid { get; set; }
    /**
     * @description PPID from Twilio
     */
    public String type { get; set; }
    /**
     * @description Twilio Id from Twilio
     */
    public String twilioId { get; set; }
    /**
     * @description Call Recording Id from Twilio for inbound calls
     */
    public String callRecordingId { get; set; }
    /**
     * @description chatOrCallStatus from Twilio
     */
    public String chatOrCallStatus { get; set; }
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
    public String externalId { get; set; }
    /**
     * @description Error Message for failure response
     */
    public String errorMessage { get; set; }
    /**
     * @description Customer OCV ID
     */
    public String ocvId { get; set; }
    /**
     * @description Label for chat to display
     */
    public String chatLabel { get; set; }
  }

  /**
   * @description Method to check if the request record is valid or not.
   * @param interactContextRequest Chat Context instance
   * @param accountsMap accountsByOCVId
   * @return InteractionContextRequest which contains error messages if any
   */
  private static List<Interaction> createInteraction(
    InteractionContextRequest interactContextRequest,
    Map<String, Id> accountsMap
  ) {
    List<Interaction> listOfInteractionsToCreate = new List<Interaction>();
    if (interactContextRequest.type.toLowerCase() == CHAT_INTERACTION_TYPE) {
      Interaction intToInsert = new Interaction();
      intToInsert.Direction__c = interactContextRequest.direction;
      intToInsert.InteractionType = 'Chat';
      intToInsert.Contact_Mobile__c = interactContextRequest.phoneNumber;
      intToInsert.Chat_or_Call_SID__c = interactContextRequest.chatOrCallId;
      intToInsert.Status__c = (!interactionTwilioStatusMap.isEmpty() &&
        interactionTwilioStatusMap.containsKey(
          interactContextRequest.chatOrCallStatus.toLowerCase()
        ))
        ? interactionTwilioStatusMap.get(
            interactContextRequest.chatOrCallStatus.toLowerCase()
          )
        : interactContextRequest.chatOrCallStatus;
      intToInsert.StartTime = System.now();
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID;
      intToInsert.Support_Topics__c = validateSupportTopic(
        interactContextRequest.issueSubtype
      );
      intToInsert.AccountId = accountsMap.get(interactContextRequest.ocvId);
      listOfInteractionsToCreate.add(intToInsert);
    } else if (
      interactContextRequest.type.toLowerCase() == CALL_INTERACTION_TYPE
    ) {
      Interaction intToInsert = new Interaction();
      intToInsert.Direction__c = interactContextRequest.direction;
      intToInsert.InteractionType = 'Call';
      intToInsert.Contact_Mobile__c = interactContextRequest.phoneNumber;
      intToInsert.Chat_or_Call_SID__c = interactContextRequest.chatOrCallId;
      intToInsert.StartTime = System.now();
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
      listOfInteractionsToCreate.add(intToInsert);
    }
    return listOfInteractionsToCreate;
  }

  /**
   * @description validatedSupportTopic validates supportTopics in requests regardless of case sensitvity
   * @param issueSubType the Subtype received in request to validate
   * @return subtype the validated Subtype taking into account case sensitivity
   */
  private static String validateSupportTopic(String issueSubType) {
    if (String.isNotBlank(supportTopicMap.get(issueSubType.toLowerCase()))) {
      return supportTopicMap.get(issueSubType.toLowerCase());
    } else {
      return 'Support Enquiry';
    }
  }
}
