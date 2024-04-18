/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Util Class to handle incoming requests from Twilio for Twilio Details Upsert and Interaction Update.
 */
public with sharing class TwilioServiceUtil {
  public static Map<String, Id> agentOwnerIdMap = new Map<String, Id>();
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
   * @description method passing incoming twilio context in to Salesforce.
   * @param twilioContextRequest Twilio Context Request
   * @return TwilioContextResponse to send the response back to Twilio
   */
  public static List<TwilioContextResponse> upsertTwilioDetailsRecord(
    List<UpdateInteractionByTwilioPayload> twilioContextRequest
  ) {
    List<Interaction> interactionToBeUpdated = new List<Interaction>();
    List<TwilioContextResponse> responseList = new List<TwilioContextResponse>();
    List<Twilio_Details__c> twilioDetailRecordToInsertOrUpdate = new List<Twilio_Details__c>();
    List<Database.UpsertResult> lstUpsertResult = new List<Database.UpsertResult>();
    Set<String> agentEmailList = new Set<String>();

    for (
      Integer intCount = 0; intCount < twilioContextRequest.size(); intCount++
    ) {
      UpdateInteractionByTwilioPayload res = twilioContextRequest.get(intCount);
      Twilio_Details__c twilioDetailRecord = new Twilio_Details__c();
      //Checking whether the transaction made for Update or Insert.
      if (String.isNotBlank(res.twilioDetailRecordId)) {
        twilioDetailRecord.Id = res.twilioDetailRecordId;
      } else if (!String.isNotBlank(res.twilioDetailRecordId)) {
        twilioDetailRecord.Id = [
          SELECT TwilioDetailsID__c
          FROM Interaction
          WHERE Id = :res.interactionId
          WITH SECURITY_ENFORCED
        ]
        .TwilioDetailsID__c;
      }

      if (String.isNotBlank(res.twilioId)) {
        twilioDetailRecord.Twilio_ID__c = res.twilioId;
      }
      if (String.isNotBlank(res.chatOrCallId)) {
        twilioDetailRecord.Chat_or_Call_SID__c = res.chatOrCallId;
      }
      if (String.isNotBlank(res.callRecordingId)) {
        twilioDetailRecord.Call_Recording_Id__c = res.callRecordingId;
      }
      if (String.isNotBlank(res.queueName)) {
        twilioDetailRecord.ANZ_Queue__c = res.queueName;
      }
      if (String.isNotBlank(res.agentEmail)) {
        agentEmailList.add(res.agentEmail);
      }
      twilioDetailRecordToInsertOrUpdate.add(twilioDetailRecord);
    }

    //Creating map of agent email and owner id
    for (User agent : [
      SELECT Id, FederationIdentifier, Email
      FROM User
      WHERE
        (Email IN :agentEmailList
        OR FederationIdentifier IN :agentEmailList)
        AND IsActive = TRUE
    ]) {
      agentOwnerIdMap.put(agent.FederationIdentifier.toLowerCase(), agent.Id);
    }

    //create Twilio Details upsert list based on from which context it is called
    lstUpsertResult = Database.upsert(
      twilioDetailRecordToInsertOrUpdate,
      Twilio_Details__c.Id,
      false
    );

    for (
      Integer intUpsertCount = 0;
      intUpsertCount < lstUpsertResult.size();
      intUpsertCount++
    ) {
      Database.UpsertResult twilioRecordUpserted = lstUpsertResult.get(
        intUpsertCount
      );
      UpdateInteractionByTwilioPayload payLoad = twilioContextRequest.get(
        intUpsertCount
      );

      if (twilioRecordUpserted.isSuccess()) {
        interactionToBeUpdated.add(
          createInteractionDetailInstance(payLoad, twilioRecordUpserted)
        );
      } else {
        List<Database.Error> err = twilioRecordUpserted.getErrors();
        String errorvalues = String.join(err, '/n');
        responseList.add(generateErrorResponse(errorvalues));
      }
    }
    if (!interactionToBeUpdated.isEmpty()) {
      responseList.addAll(updateInteraction(interactionToBeUpdated));
    }
    return responseList;
  }

  /**
   * @description Method to generate a response instance
   * @return `TwilioContextResponse`
   */
  private static TwilioContextResponse generateResponse() {
    TwilioContextResponse response = new TwilioContextResponse();
    response.success = true;
    response.statusCode = 200;
    return response;
  }

  /**
   * @description Method to generate a response instance
   * @param errMsg error message for twilio response
   * @return `TwilioContextResponse`
   */
  private static TwilioContextResponse generateErrorResponse(String errMsg) {
    TwilioContextResponse response = new TwilioContextResponse();
    response.errorMessage = errMsg;
    response.success = false;
    response.statusCode = 400;
    return response;
  }

  /**
   * @description Method to generate a response instance
   * @param statusFromTwilio error message for twilio response
   * @return It will return the string of status
   */
  public static String getStatus(String statusFromTwilio) {
    return (String.isNotEmpty(statusFromTwilio) &&
      !interactionTwilioStatusMap.isEmpty() &&
      interactionTwilioStatusMap.containsKey(statusFromTwilio.toLowerCase()))
      ? interactionTwilioStatusMap.get(statusFromTwilio.toLowerCase())
      : statusFromTwilio;
  }

  /**
   * @description Method to generate a response instance for interaction update.
   * @param interactionToBeUpdatedList list of interaction
   * @return It will return the response list.
   */
  public static List<TwilioContextResponse> updateInteraction(
    List<Interaction> interactionToBeUpdatedList
  ) {
    List<TwilioContextResponse> responseList = new List<TwilioContextResponse>();
    List<Database.SaveResult> results = DMLUtil.updateRecords(
      interactionToBeUpdatedList,
      false,
      true
    );
    Logger.error('Error in Updating Interaction', results);
    Logger.saveLog();

    for (Integer i = 0; i < interactionToBeUpdatedList.size(); i++) {
      Database.SaveResult sr = results[i];
      if (sr.isSuccess()) {
        responseList.add(generateResponse());
      } else {
        List<Database.Error> err = sr.getErrors();
        String errorvalues = String.join(err, '/n');
        responseList.add(generateErrorResponse(errorvalues));
      }
    }
    return responseList;
  }

  /**
   * @description Method to insert Twilio Details record on insertion of Interaction for Chat and Call Recordtype
   * and if the insertion failed then creation of Twilio Details get rolled back
   * @param interactionsList list of interaction created newly from trigger
   */
  public static void insertTwilioDetailsOnInteractionCreation(
    List<Interaction> interactionsList
  ) {
    List<Twilio_Details__c> twilioDetailsToBeInserted = new List<Twilio_Details__c>();
    List<Interaction> interactionListForTwilioDetailsCreation = new List<Interaction>();
    //Set of Interaction RecordTypeIds for Call and Chat
    Set<Id> callMessageRecTypeIdsSet = new Set<Id>{
      GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      GetHelpConstants.INTERACTION_MESSAGE_RT_ID
    };

    for (Interaction newInteraction : interactionsList) {
      if (callMessageRecTypeIdsSet.contains(newInteraction.RecordTypeId)) {
        interactionListForTwilioDetailsCreation.add(newInteraction);
        Twilio_Details__c twilioDetailRecord = new Twilio_Details__c();
        twilioDetailsToBeInserted.add(twilioDetailRecord);
      }
    }
    //Insert Twilio Details
    List<Database.SaveResult> twilioInsertResult = DMLUtil.insertRecords(
      twilioDetailsToBeInserted,
      false,
      false
    );

    Logger.error(
      'Error in Creating Twilio Details On Trigger Event',
      twilioInsertResult
    );
    Logger.saveLog();

    //Coaches needs each Call/Chat Interaction should have Twilio details precreated so that they should only fill in few fields from related details section
    for (
      Integer intInsertCount = 0;
      intInsertCount < twilioInsertResult.size();
      intInsertCount++
    ) {
      Database.SaveResult twilioRecordInserted = twilioInsertResult.get(
        intInsertCount
      );
      if (twilioRecordInserted.isSuccess()) {
        interactionListForTwilioDetailsCreation[intInsertCount]
          .TwilioDetailsID__c = twilioRecordInserted.getId();
      }
    }
  }

  /**
   * @description Method to check whether it is a normal call or conference call
   * @param twilioContextRequest TwilioContextRequest from Twilio
   * @return return true if it's a conference call
   */
  public static Boolean checkIsConference(
    UpdateInteractionByTwilioPayload twilioContextRequest
  ) {
    return twilioContextRequest.isConference != null &&
      twilioContextRequest.isConference;
  }
  /**
   * @description Method to check whether it is a normal chat or transfer chat
   * @param twilioContextRequest TwilioContextRequest from Twilio
   * @return return true if it's a Transfer chat
   */
  private static Boolean checkIsTransfer(
    UpdateInteractionByTwilioPayload twilioContextRequest
  ) {
    return twilioContextRequest.transfer != null &&
      String.isNotBlank(twilioContextRequest.transfer);
  }
  /**
   * @description Method to create Interaction instance for owner update if needed
   * @param payLoad TwilioContextRequest from Twilio
   * @param twilioRecordUpserted twilioRecord upserted result
   * @return return Interaction instance to be updated
   */
  private static Interaction createInteractionDetailInstance(
    UpdateInteractionByTwilioPayload payLoad,
    Database.UpsertResult twilioRecordUpserted
  ) {
    Interaction interactionToUpsert = new Interaction();
    interactionToUpsert.Id = payLoad.interactionId;
    interactionToUpsert.TwilioDetailsID__c = twilioRecordUpserted.getId();
    interactionToUpsert.Status__c = getStatus(payLoad.chatOrCallStatus);
    if (String.isNotBlank(payLoad.agentEmail) && !checkIsConference(payLoad)) {
      interactionToUpsert.OwnerId = agentOwnerIdMap.get(
        payLoad.agentEmail.toLowerCase()
      );
    }
    if (checkIsTransfer(payLoad)) {
      interactionToUpsert.Chat_Queue__c = payLoad.queueName;
      interactionToUpsert.Transfer__c = payLoad.transfer;
    }

    return interactionToUpsert;
  }
}
