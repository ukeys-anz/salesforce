/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Util Class to handle incoming requests from Twilio for Twilio Details Upsert and Interaction Update.
 */
public with sharing class TwilioServiceUtil {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final InteractionRepository INTERACTION_REPOSITORY = (InteractionRepository) Lib_InstanceProvider.forType(
    InteractionRepository.class
  );
  private static final Set<String> CALL_MESSAGE_RT_ID_SET = new Set<String>{
    RTInteraction.call,
    RTInteraction.message
  };

  /**
   * @description method passing incoming twilio context in to Salesforce.
   * @param twilioContextRequest Twilio Context Request
   * @return TwilioContextResponse to send the response back to Twilio
   */
  public static TwilioContextResponse upsertTwilioDetailsRecord(
    UpdateInteractionByTwilioPayload twilioContextRequest
  ) {
    Twilio_Details__c twilioDetailRecord = buildTwilioDetails(
      twilioContextRequest
    );
    
    //create Twilio Details upsert list based on from which context it is called
    try {
      DML_REPOSITORY.doUpsert(
        twilioDetailRecord
      );
      Interaction interactionToBeUpdated = createInteractionDetailInstance(
        twilioContextRequest,
        twilioDetailRecord
      );
      DML_REPOSITORY.doUpdate(interactionToBeUpdated);
      return generateResponse();
    } catch (Exception objException) {
      return generateErrorResponse(objException.getMessage());
    }
  }

  private static Twilio_Details__c buildTwilioDetails(
    UpdateInteractionByTwilioPayload twilioContextRequestForUpdate
  ) {
    Twilio_Details__c twilioDetailRecord = new Twilio_Details__c();
    Interaction interactionWithTwilioId = INTERACTION_REPOSITORY.fetchTwilioDetailIdFromInteraction(
      twilioContextRequestForUpdate.interactionId
    ); 
    twilioDetailRecord.Id = interactionWithTwilioId?.TwilioDetailsID__c;

    if (String.isNotBlank(twilioContextRequestForUpdate.twilioId)) {
      twilioDetailRecord.Twilio_ID__c = twilioContextRequestForUpdate.twilioId;
    }
    if (String.isNotBlank(twilioContextRequestForUpdate.chatOrCallId)) {
      twilioDetailRecord.Chat_or_Call_SID__c = twilioContextRequestForUpdate.chatOrCallId;
    }
    if (String.isNotBlank(twilioContextRequestForUpdate.callRecordingId)) {
      twilioDetailRecord.Call_Recording_Id__c = twilioContextRequestForUpdate.callRecordingId;
    }
    if (String.isNotBlank(twilioContextRequestForUpdate.queueName)) {
      twilioDetailRecord.ANZ_Queue__c = twilioContextRequestForUpdate.queueName;
    }
    if (String.isNotBlank(twilioContextRequestForUpdate.nlpTopic)) {
      twilioDetailRecord.NLP_Topic__c = twilioContextRequestForUpdate.nlpTopic;
    }

    return twilioDetailRecord;
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
   * @description Method to get status value of the twilio
   * @param statusFromTwilio status value from Twilio on update
   * @return It will return the salesforce valid status value based on mapping
   */
  public static String getStatus(String statusFromTwilio) {
    if (String.isBlank(statusFromTwilio)) {
      return statusFromTwilio;
    }
    String statusKey = statusFromTwilio.toLowerCase();
    if (!QueryTwilioStatusMapping.mapByStatus.containsKey(statusKey)) {
        return statusFromTwilio;
    }
    return QueryTwilioStatusMapping.getByStatus(statusKey).Interaction_Status__c;
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
    List<Interaction> interactionListForTwilioDetailsCreation = ListUtil.filter(
      interactionsList
    )
    .equals(Interaction.RecordTypeId, CALL_MESSAGE_RT_ID_SET)
    .toList();

    for (Interaction newInteraction : interactionListForTwilioDetailsCreation) {
      {
        Twilio_Details__c twilioDetailRecord = new Twilio_Details__c();
        twilioDetailsToBeInserted.add(twilioDetailRecord);
      }
    }

    //Insert Twilio Details
    List<Database.SaveResult> twilioInsertResult = DML_REPOSITORY.doInsert(
      twilioDetailsToBeInserted,
     new DMLConfig().systemMode().allowPartial()
    );

    //Coaches needs each Call/Chat Interaction should have Twilio details precreated so that they should only fill in few fields from related details section
    Integer intInsertCount = 0;
    for(Database.SaveResult twilioRecordInserted : twilioInsertResult)
    {
      if(!twilioRecordInserted.isSuccess())
      {
        continue;
      }
      interactionListForTwilioDetailsCreation[intInsertCount]
        .TwilioDetailsID__c = twilioRecordInserted.getId();
      intInsertCount++;
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
    Twilio_Details__c twilioRecordUpserted
  ) {
    Interaction interactionToUpsert = new Interaction();
    interactionToUpsert.Id = payLoad.interactionId;
    interactionToUpsert.TwilioDetailsID__c = twilioRecordUpserted.Id;
    interactionToUpsert.Status__c = getStatus(payLoad.chatOrCallStatus);
    if (String.isNotBlank(payLoad.queueName)) {
      interactionToUpsert.Chat_Queue__c = payLoad.queueName;
    }
    if (payLoad.agentUserId != null && !checkIsConference(payLoad)) {
      interactionToUpsert.OwnerId = payLoad.agentUserId;
    }
    if (checkIsTransfer(payLoad)) {
      interactionToUpsert.Transfer__c = payLoad.transfer;
    }

    return interactionToUpsert;
  }
}