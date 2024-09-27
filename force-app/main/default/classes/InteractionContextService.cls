/**
 * @author Rebecca Jan
 * @since  April 2022
 * @description APEX REST API class to handle incoming requests from Twilio.
 * Added Chat Interaction and Twilio Details Creation Logic and updated Call Interaction Creation Logic as part of ANZX-103285 by Shivam , July 2023
 */

@RestResource(urlMapping='/InteractionContextRequests/*')
global with sharing class InteractionContextService {
  public static final String CALL_INTERACTION_TYPE = 'voice';
  public static final String CHAT_INTERACTION_TYPE = 'chat';
  public static final String INBOUND_DIRECTION = 'Inbound';
  public static final String OUTBOUND_DIRECTION = 'Outbound';
  public static final String DEFAULT_CHAT_FOR = 'Customer';
  public static final String DEFAULT_CHAT_AUTHENTICATED_METHOD = 'Authenticated';
  private static Map<String, String> supportTopicMap = new Map<String, String>();
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );

  /**
   * @description HTTP POST method passing incoming interaction context in to Salesforce.
   * Salesforce would then return a interaction id created
   * @param contextRequest InteractionContextRequest from Twilio
   */
  @HttpPost
  global static void doPost(InteractionContextRequest contextRequest) {
    List<InteractionContextRequest> contextRequests = new List<InteractionContextRequest>{
      contextRequest
    };
    Integer finalStatusCode = 400;
    Map<String, Id> accountsByOCVId = new Map<String, Id>();
    Map<String, InteractionContextRequest> requestByOCVId = new Map<String, InteractionContextRequest>();
    Map<String, InteractionContextRequest> requestByPhoneNumber = new Map<String, InteractionContextRequest>();
    Map<String, Interaction> existingInteractionsBySID = new Map<String, Interaction>();
    Set<String> callOrChatSidList = new Set<String>();
    List<Account> accountsToUpdate = new List<Account>();
    List<Interaction> interactionToBeCreated = new List<Interaction>();
    List<InteractionContextResponse> responseList = new List<InteractionContextResponse>();
    List<UpdateInteractionByTwilioPayload> twilioDetailsByInteractionList = new List<UpdateInteractionByTwilioPayload>();

    //Validating the response received from Twilio in order to proceed
    validateIncomingRequestFromTwilio(
      contextRequests,
      requestByOCVId,
      callOrChatSidList,
      requestByPhoneNumber,
      responseList
    );

    //Fetching Valid Support Topic Values and Create the map to verify the callOrChatStatus received from Twilio
    populateSupportTopicMap();

    //For Creating Map of Existing Interactions By callOrChatSID for checking Duplication of the Interaction Context.
    existingInteractionsBySID = INTERACTION_REPOSITORY.queryExistingInteractionFromCallOrChatSID(
      callOrChatSidList
    );

    //Finding available accounts based on OCV Id received from Twilio to populate in Interaction
    if (!requestByOCVId.isEmpty()) {
      fetchAvailableAccountsByOCVId(
        requestByOCVId,
        accountsByOCVId,
        accountsToUpdate,
        responseList
      );
    }

    //Creation of New Interaction Record To Be Created and Checking Existing Interations to avoid creation of new interaction
    if (!contextRequests.isEmpty()) {
      for (
        Integer intCount = 0; intCount < contextRequests.size(); intCount++
      ) {
        InteractionContextRequest interactContext = contextRequests.get(
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
      List<Database.SaveResult> results = DMLUtil.insertRecords(
        interactionToBeCreated,
        false,
        true
      );
      Logger.error('Error in Creating Interaction', results);
      Logger.saveLog();

      // Twilio Record Creation
      createTwilioRecordAfterInteractionCreation(
        interactionToBeCreated,
        results,
        contextRequests,
        twilioDetailsByInteractionList,
        responseList
      );
    }

    //Update PPID on Account if missed
    if (!accountsToUpdate.isEmpty()) {
      updatePPIDOnAccount(accountsToUpdate);
    }

    // At least one request was successful
    for (InteractionContextResponse res : responseList) {
      if (res.statusCode == 200) {
        finalStatusCode = 200;
        break;
      }
    }

    //Creating the json response to be send to Twilio
    String jsonRes = JSON.serialize(responseList.get(0));
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatusCode;
  }

  /**
   * @description This method will validate the response received from Twilio and create the list required for further process.
   * @param contextRequests List<InteractionContextRequest>
   * @param requestByOCVId  Map<String, InteractionContextRequest>
   * @param callOrChatSidList   Set<String>
   * @param requestByPhoneNumber Map<String, InteractionContextRequest>
   * @param responseList List<InteractionContextResponse>
   */
  private static void validateIncomingRequestFromTwilio(
    List<InteractionContextRequest> contextRequests,
    Map<String, InteractionContextRequest> requestByOCVId,
    Set<String> callOrChatSidList,
    Map<String, InteractionContextRequest> requestByPhoneNumber,
    List<InteractionContextResponse> responseList
  ) {
    if (!contextRequests.isEmpty()) {
      for (
        Integer intCount = 0; intCount < contextRequests.size(); intCount++
      ) {
        InteractionContextRequest req = contextRequests.get(intCount);
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
          if (req.isAuthenticated) {
            requestByOCVId.put(req.ocvId, req);
          } else {
            requestByPhoneNumber.put(req.phoneNumber, req);
          }
          callOrChatSidList.add(req.chatOrCallId);
        } else {
          responseList.addAll(isValidRequest(req));
        }
      }
    }
  }

  /**
   * @description This method will fetch the available accounts based on the ocv id received to set in the Interaction to be created.
   * @param requestByOCVId Map<String, InteractionContextRequest>
   * @param accountsByOCVId Map<String, Id> It will contains string and id of an account.
   * @param accountsToUpdate List<Account> contains list of account to update the ppid.
   * @param responseList List<InteractionContextResponse>
   */
  private static void fetchAvailableAccountsByOCVId(
    Map<String, InteractionContextRequest> requestByOCVId,
    Map<String, Id> accountsByOCVId,
    List<Account> accountsToUpdate,
    List<InteractionContextResponse> responseList
  ) {
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

    // Handling responses against requests with invalid OCV Ids
    for (String ocvId : requestByOCVId.keySet()) {
      if (!accountsByOCVId.keySet().contains(ocvId)) {
        String errorMessage =
          'Could not find a matching ANZx customer record based on OCV ID: ' +
          ocvId;

        responseList.add(generateErrorResponse(ocvId, errorMessage, ''));
      }
    }
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
   * @description Method to create Interaction List to be created.
   * @param interactContextRequest Interaction Context Request from Twilio
   * @param accountsMap accountsByOCVId
   * @return InteractionContextRequest which contains error messages if any
   */
  private static List<Interaction> createInteraction(
    InteractionContextRequest interactContextRequest,
    Map<String, Id> accountsMap
  ) {
    List<Interaction> listOfInteractionsToCreate = new List<Interaction>();
    Interaction intToInsert = new Interaction();
    intToInsert.Direction__c = interactContextRequest.direction;
    intToInsert.Chat_or_Call_SID__c = interactContextRequest.chatOrCallId;
    intToInsert.StartTime = System.now();
    intToInsert.Contact_Mobile__c = interactContextRequest.phoneNumber;
    if (interactContextRequest.type.toLowerCase() == CHAT_INTERACTION_TYPE) {
      intToInsert.InteractionType = 'Chat';
      intToInsert.Status__c = TwilioServiceUtil.getStatus(
        interactContextRequest.chatOrCallStatus
      );
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_MESSAGE_RT_ID;
      intToInsert.Support_Topics__c = validateSupportTopic(
        interactContextRequest.issueSubtype
      );
      intToInsert.AccountId = accountsMap.get(interactContextRequest.ocvId);
      intToInsert.Authentication_Method__c = DEFAULT_CHAT_AUTHENTICATED_METHOD;
      intToInsert.Interaction_Purpose__c = DEFAULT_CHAT_FOR;
      listOfInteractionsToCreate.add(intToInsert);
    } else {
      intToInsert.InteractionType = 'Call';
      intToInsert.RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID;
      intToInsert = setInteractionForAuthenticated(
        intToInsert,
        interactContextRequest,
        accountsMap
      );
      listOfInteractionsToCreate.add(intToInsert);
    }
    return listOfInteractionsToCreate;
  }

  /**
   * @description Method to create the Twilio Details record for the Interaction To be Created.
   * @param interactionListCreatedDB List<Interaction> To Be Created
   * @param results List<Database.SaveResult> for Interaction Created
   * @param contextRequests Interaction Context Request From Twilio
   * @param twilioDetailsByInteractionList List<UpdateInteractionByTwilioPayload>
   * @param responseList  List<InteractionContextResponse>
   */
  private static void createTwilioRecordAfterInteractionCreation(
    List<Interaction> interactionListCreatedDB,
    List<Database.SaveResult> results,
    List<InteractionContextRequest> contextRequests,
    List<UpdateInteractionByTwilioPayload> twilioDetailsByInteractionList,
    List<InteractionContextResponse> responseList
  ) {
    Map<Id, Interaction> newInteractionMap = new Map<Id, Interaction>(
      [
        SELECT
          Id,
          Interaction_External_Id__c,
          Account.OCV_ID__c,
          Account.PersonMobilePhone,
          Support_Topics__c,
          InteractionType,
          TwilioDetailsID__c
        FROM Interaction
        WHERE Id IN :interactionListCreatedDB
        WITH SECURITY_ENFORCED
      ]
    );
    for (Integer i = 0; i < interactionListCreatedDB.size(); i++) {
      Database.SaveResult sr = results[i];
      if (sr.isSuccess()) {
        UpdateInteractionByTwilioPayload twilioContext = new UpdateInteractionByTwilioPayload();

        twilioContext.interactionId = interactionListCreatedDB[i].Id;
        twilioContext.callRecordingId = contextRequests[i].callRecordingId;
        twilioContext.chatOrCallId = contextRequests[i].chatOrCallId;
        twilioContext.chatOrCallStatus = contextRequests[i].chatOrCallStatus;
        twilioContext.twilioId = contextRequests[i].twilioId;
        twilioContext.twilioDetailRecordId = interactionListCreatedDB[i]
          .TwilioDetailsID__c;
        twilioDetailsByInteractionList.add(twilioContext);

        responseList.add(
          generateResponse(
            interactionListCreatedDB[i].Id,
            newInteractionMap.get(interactionListCreatedDB[i].Id)
              .Interaction_External_Id__c,
            contextRequests[i].ocvId,
            contextRequests[i].issueSubtype
          )
        );
      } else {
        List<Database.Error> err = sr.getErrors();
        String errorvalues = String.join(err, '/n');
        responseList.add(
          generateErrorResponse(
            contextRequests[i].ocvId,
            errorvalues,
            contextRequests[i].issueSubtype
          )
        );
      }
    }

    if (!twilioDetailsByInteractionList.isEmpty()) {
      TwilioServiceUtil.upsertTwilioDetailsRecord(
        twilioDetailsByInteractionList
      );
    }
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
   * @description this method will update the ppid of the accounts
   * @param accountsToUpdate List<Account> containing account which needs to be updated for PPID.
   */
  private static void updatePPIDOnAccount(List<Account> accountsToUpdate) {
    if (Account.sObjectType.getDescribe().isUpdateable()) {
      List<Database.SaveResult> results = Database.Update(
        accountsToUpdate,
        false
      );

      Logger.error('Error in Updating Account', results);
      Logger.saveLog();
    }
  }

  /**
   * @description to set the attributes of interaction if the call is authenticated
   * @param interaction Interaction object in which details needs to be added
   * @param interactContextRequest Request from Twilio
   * @param accountsMap accountsByOCVId
   * @return Interaction object with details
   */
  private static Interaction setInteractionForAuthenticated(
    Interaction interaction,
    InteractionContextRequest interactContextRequest,
    Map<String, Id> accountsMap
  ) {
    if (!interactContextRequest.isAuthenticated) {
      return interaction;
    }
    interaction.AccountId = accountsMap.get(interactContextRequest.ocvId);
    interaction.Interaction_Purpose__c = DEFAULT_CHAT_FOR;
    interaction.Authentication_Method__c = DEFAULT_CHAT_AUTHENTICATED_METHOD;
    interaction.Support_Topics__c = validateSupportTopic(
      interactContextRequest.issueSubtype
    );
    return interaction;
  }
}
