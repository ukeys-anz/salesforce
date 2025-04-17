/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description APEX REST API class to handle incoming requests from Twilio.
 * Added Chat Interaction and Twilio Details Creation Logic and updated Call Interaction Creation Logic as part of ANZX-103285
 */

@RestResource(urlMapping='/InteractionContextRequests/*')
global with sharing class InteractionContextService {
  private static final String CALL_INTERACTION_TYPE = 'voice';
  private static final String CHAT_INTERACTION_TYPE = 'chat';
  private static final String INBOUND_DIRECTION = 'Inbound';
  private static final String OUTBOUND_DIRECTION = 'Outbound';
  private static final String DEFAULT_CHAT_FOR = 'Customer';
  private static final String DEFAULT_CHAT_AUTHENTICATED_METHOD = 'Authenticated';
  private static Map<String, String> supportTopicMap = new Map<String, String>();
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description HTTP POST method passing incoming interaction context in to Salesforce.
   * Salesforce would then return a interaction id created
   * @param contextRequest InteractionContextRequest from Twilio
   */
  @HttpPost
  global static void doPost(InteractionContextRequest contextRequest) {
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    Interaction interactionToBeCreated = new Interaction();
    InteractionContextResponse responseSentToTwilio = new InteractionContextResponse();

    //Validating the response received from Twilio in order to proceed
    responseSentToTwilio = validateIncomingRequestFromTwilio(contextRequest);
    if (responseSentToTwilio != null) {
      sendRestContextToTwilio(responseSentToTwilio);
      return;
    }

    //Fetching Valid Support Topic Values and Create the map to verify the callOrChatStatus received from Twilio
    populateSupportTopicMap();

    //Finding available accounts based on OCV Id and update if PPID is changed
    if (String.isNotBlank(contextRequest.ocvId)) {
      responseSentToTwilio = updatePPIDOnAccountIfExist(contextRequest);
      if (responseSentToTwilio != null) {
        sendRestContextToTwilio(responseSentToTwilio);
        return;
      }
    }

    //For Creating Map of Existing Interactions By callOrChatSID for checking Duplication of the Interaction Context.
    existingInteractionsBySID = INTERACTION_REPOSITORY.queryExistingInteractionFromCallOrChatSID(
      contextRequest.chatOrCallId
    );

    //Creation of New Interaction Record To Be Created and Checking Existing Interactions to avoid creation of new interaction
    if (
      !existingInteractionsBySID.isEmpty() &&
      existingInteractionsBySID.containsKey(contextRequest.chatOrCallId)
    ) {
      sendRestContextToTwilio(
        generateResponse(
          existingInteractionsBySID.get(contextRequest.chatOrCallId).Id,
          existingInteractionsBySID.get(contextRequest.chatOrCallId)
            .Interaction_External_Id__c,
          contextRequest.ocvId,
          contextRequest.issueSubtype,
          contextRequest.pushToAppTask
        )
      );
      return;
    }

    interactionToBeCreated = createInteractionInstance(contextRequest);

    try {
      Database.SaveResult interactionCreated = DML_REPOSITORY.doInsert(
        interactionToBeCreated
      );
      // Twilio Record Upsert With Context Detail
      upsertTwilioRecordAfterInteractionCreation(
        interactionCreated,
        contextRequest
      );
    } catch (Exception objException) {
      //Creating the json response to be send to Twilio
      sendRestContextToTwilio(
        generateErrorResponse(
          contextRequest.ocvId,
          objException.getMessage(),
          contextRequest.issueSubType
        )
      );
      return;
    }
  }

  /**
   * @description Method to check if the request record is valid or not.
   * @param validateContextRequest Chat Context instance
   * @return `InteractionContextResponse` which contains error messages if any
   */
  private static InteractionContextResponse validateIncomingRequestFromTwilio(
    InteractionContextRequest validateContextRequest
  ) {
    //check Type value is not blank
    if (String.isBlank(validateContextRequest.type)) {
      return generateErrorResponse(
        validateContextRequest.ocvId,
        'Type value is blank',
        validateContextRequest.issueSubtype
      );
    }

    //check direction values must be correct
    if (
      validateContextRequest.direction != INBOUND_DIRECTION &&
      validateContextRequest.direction != OUTBOUND_DIRECTION
    ) {
      return generateErrorResponse(
        validateContextRequest.ocvId,
        'Direction should be inbound or outbound',
        validateContextRequest.issueSubtype
      );
    }

    //Check to make sure OCV ID or PhoneNumber Exist
    if (
      String.isBlank(validateContextRequest.ocvId) &&
      String.isBlank(validateContextRequest.phoneNumber)
    ) {
      return generateErrorResponse(
        validateContextRequest.ocvId,
        'OCVid and Phonenumber cannot be null',
        validateContextRequest.issueSubtype
      );
    }

    return null;
  }

  /**
   * @description This method will update the existing account PPID if changed
   * based on the ocv id received from Twilio
   * @param contextRequest InteractionContextRequest from Twilio
   * @return InteractionContextResponse return error if any or null to be sent to twilio
   */
  private static InteractionContextResponse updatePPIDOnAccountIfExist(
    InteractionContextRequest contextRequest
  ) {
    try {
      Account existingAccount = contextRequest.existingAccount;
      if(existingAccount == null)
      {
        String errorMessage =
        'Could not find a matching ANZx customer record based on OCV ID: ' +
        contextRequest.ocvId;
        return generateErrorResponse(contextRequest.ocvId, errorMessage, '');
      }

      // Only update PPID once or if its changed
      if (
        String.isNotBlank(contextRequest.ppid) &&
        existingAccount.PPID__C != contextRequest.ppid
      ) {
        existingAccount.PPID__C = contextRequest.ppid;
        DML_REPOSITORY.doUpdate(existingAccount, new DmlConfig().systemMode());
      }
      return null;
    } catch (Exception objException) {
      return generateErrorResponse(
        contextRequest.ocvId,
        objException.getMessage(),
        ''
      );
    }
  }

  /**
   * @description Method to create Interaction List to be created.
   * @param interactContextRequest Interaction Context Request from Twilio
   * @return Interaction Interaction to be created
   */
  private static Interaction createInteractionInstance(
    InteractionContextRequest interactContextRequest
  ) {
    Interaction intToInsert = new Interaction();
    intToInsert.Direction__c = interactContextRequest.direction;
    intToInsert.Chat_or_Call_SID__c = interactContextRequest.chatOrCallId;
    intToInsert.StartTime = System.now();
    intToInsert.Contact_Mobile__c = interactContextRequest.phoneNumber;
    if (interactContextRequest?.pushToAppTask?.WhatId != null) {
      fetchWhatIdTypeToLinkInteraction(
        intToInsert,
        interactContextRequest.pushToAppTask?.WhatId
      );
    }
    if (interactContextRequest.type.toLowerCase() == CHAT_INTERACTION_TYPE) {
      intToInsert.InteractionType = InteractionConstants.CHAT;
      intToInsert.Status__c = TwilioServiceUtil.getStatus(
        interactContextRequest.chatOrCallStatus
      );
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID;
      intToInsert.Support_Topics__c = validateSupportTopic(
        interactContextRequest.issueSubtype
      );
      intToInsert.AccountId = interactContextRequest.existingAccount.Id;
      intToInsert.Authentication_Method__c = DEFAULT_CHAT_AUTHENTICATED_METHOD;
      intToInsert.Interaction_Purpose__c = DEFAULT_CHAT_FOR;
      return intToInsert;
    }
    intToInsert.InteractionType = InteractionConstants.CALL;
    intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
    intToInsert = setInteractionForAuthenticated(
      intToInsert,
      interactContextRequest
    );
    return intToInsert;
  }

  /**
   * @description Method to upsert the Twilio Details record for the Interaction Created
   * @param interactionCreated Database.SaveResult for Interaction Created
   * @param contextRequest Interaction Context Request From Twilio
   */
  private static void upsertTwilioRecordAfterInteractionCreation(
    Database.SaveResult interactionCreated,
    InteractionContextRequest contextRequest
  ) {
    Interaction newInteraction = INTERACTION_REPOSITORY.getInteractionDetails(
      interactionCreated.getId()
    );
    UpdateInteractionByTwilioPayload twilioContext = new UpdateInteractionByTwilioPayload();

    twilioContext.interactionId = newInteraction?.Id;
    twilioContext.callRecordingId = contextRequest.callRecordingId;
    twilioContext.chatOrCallId = contextRequest.chatOrCallId;
    twilioContext.chatOrCallStatus = contextRequest.chatOrCallStatus;
    twilioContext.twilioId = contextRequest.twilioId;
    twilioContext.twilioDetailRecordId = newInteraction?.TwilioDetailsID__c;
    //upsert twilio details
    TwilioServiceUtil.upsertTwilioDetailsRecord(twilioContext);
    sendRestContextToTwilio(
      generateResponse(
        newInteraction.Id,
        newInteraction.Interaction_External_Id__c,
        contextRequest.ocvId,
        contextRequest.issueSubtype,
        contextRequest.pushToAppTask
      )
    );
    return;
  }

  /**
   * @description this method will populate support topic map with Valid Values from Database.
   */
  private static void populateSupportTopicMap() {
    //Fetching valid support topic values and creating the map.
    Schema.DescribeFieldResult fieldSupportTopicPicklistValues = Interaction.Support_Topics__c.getDescribe();
    for (
      Schema.PicklistEntry supTop : fieldSupportTopicPicklistValues.getPicklistValues()
    ) {
      supportTopicMap.put(supTop.getValue().toLowerCase(), supTop.getValue());
    }
  }

  /**
   * @description to set the attributes of interaction if the call is authenticated
   * @param interaction Interaction object in which details needs to be added
   * @param interactContextRequest Request from Twilio
   * @return Interaction object with details
   */
  private static Interaction setInteractionForAuthenticated(
    Interaction interaction,
    InteractionContextRequest interactContextRequest
  ) {
    if (!interactContextRequest.isAuthenticated) {
      return interaction;
    }
    interaction.AccountId = interactContextRequest.existingAccount.Id;
    interaction.Interaction_Purpose__c = DEFAULT_CHAT_FOR;
    interaction.Authentication_Method__c = DEFAULT_CHAT_AUTHENTICATED_METHOD;
    interaction.Support_Topics__c = validateSupportTopic(
      interactContextRequest.issueSubtype
    );
    return interaction;
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

  /**
   * @description It will update the RestContext response based on the InteractionContextResponse value
   * @param responseToSend InteractionContextResponse format to send back to Twilio
   * @return RestResponse
   */
  private static RestResponse sendRestContextToTwilio(
    InteractionContextResponse responseToSend
  ) {
    //Creating the json response to be send to Twilio
    String jsonRes = JSON.serialize(responseToSend);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = responseToSend.statusCode;
    return RestContext.response;
  }

  /**
   * @description method will check what id type and based on that link with correct field in Interaction on insertion
   * @param interactionToInsert Interaction Pass By Reference to insert
   * @param whatId whatId fetched using the pubsubeventId received from Twilio
   */
  private static void fetchWhatIdTypeToLinkInteraction(
    Interaction interactionToInsert,
    Id whatId
  ) {
    String sobjectName = whatId.getSObjectType().toString();
    switch on sobjectName {
      when 'Case' {
        interactionToInsert.CaseId__c = whatId;
      }
      when 'Coaching_Summary__c' {
        interactionToInsert.Coaching_Summary__c = whatId;
      }
      when 'Loan_Application__c' {
        interactionToInsert.Loan_Application__c = whatId;
      }
    }
  }

  /**
   * @description Method to generate a response instance
   * @param recordId interaction ID of the newly generated interaction.
   * @param externalId external id of the newly generated interaction.
   * @param ocvId ocvId for inbound chat
   * @param chatLabel chatLabel for inbound chat
   * @param pushToAppTask PushToApp Task Record Detail
   * @return `InteractionContextResponse`
   */
  private static InteractionContextResponse generateResponse(
    String recordId,
    String externalId,
    String ocvId,
    String chatLabel,
    Task pushToAppTask
  ) {
    InteractionContextResponse response = new InteractionContextResponse();
    response.recordId = recordId;
    response.externalId = externalId;
    response.success = true;
    response.statusCode = 200;
    response.ocvId = ocvId;
    response.chatLabel = chatLabel;
    response.relatedRecordId = pushToAppTask?.WhatId;
    response.taskId = pushToAppTask?.Id;
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
}
