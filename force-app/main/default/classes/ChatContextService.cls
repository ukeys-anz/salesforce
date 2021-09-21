/**
 * @author Shermal Warnakula
 * @since  11/2020
 * @description APEX REST API class to handle incoming requests from Twilio.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
@RestResource(urlMapping='/ChatContextRequests/*')
global with sharing class ChatContextService {
  // General Inquiry Record Type Id
  global static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();
  global static final String QUEUE_TYPE = 'Queue';
  global static final String GENERAL_CASE_QUEUE_DEVELOPER_NAME = 'General_Case_Queue';
  global static final String CASE_CHANNEL_CHAT = 'Chat';

  global static Group generalInquiryQueue = [
    SELECT Id
    FROM Group
    WHERE
      Type = :QUEUE_TYPE
      AND DeveloperName = :GENERAL_CASE_QUEUE_DEVELOPER_NAME
    LIMIT 1
  ];

  global static Map<Id, Account> accountsById = new Map<Id, Account>();

  /**
   * @description HTTP POST method passing incoming Chat context in to Salesforce.
   * Salesforce would then return a unique customer identifier, or a related Case Number to include on Twilio tasks as "sfdcSearchString".
   * @param contextRequests List of Chat Context Requests
   */
  @SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount'
  )
  @HttpPost
  global static void doPost(List<ChatContextRequest> contextRequests) {
    List<ChatContextResponse> responseList = new List<ChatContextResponse>();
    Map<String, ChatContextRequest> requestByOCVId = new Map<String, ChatContextRequest>();
    Integer finalStatusCode = 400;

    if (!contextRequests.isEmpty()) {
      for (ChatContextRequest req : contextRequests) {
        if (isValidRequest(req)) {
          requestByOCVId.put(req.ocvId, req);
        } else {
          responseList.add(
            generateErrorResponse(
              req.ocvId,
              '',
              'Invalid or insufficient request parameters. ' + req
            )
          );
        }
      }
    }

    // Query for customer's unique External ID on Account object, as well as any related Case records based on passed in OCV ID
    Map<String, Account> accountByOCVId = new Map<String, Account>();
    Map<String, Boolean> responseStatusByOCVId = new Map<String, Boolean>();
    List<Case> newCases = new List<Case>();
    List<Account> accountsToUpdate = new List<Account>();

    for (Account acc : [
      SELECT
        Id,
        External_Id__c,
        OCV_ID__c,
        PPID__c,
        (SELECT Id, Twilio_Channel_SID__c, CaseNumber FROM Cases)
      FROM Account
      WHERE OCV_ID__c IN :requestByOCVId.keySet() AND ANZx_Customer__c = TRUE
    ]) {
      accountByOCVId.put(acc.OCV_ID__c, acc);
      accountsById.put(acc.Id, acc);

      //Only update PPID once or if its changed
      if (
        String.isNotBlank(requestByOCVId.get(acc.OCV_ID__c).PPID) &&
        (String.isBlank(acc.PPID__C) ||
        acc.PPID__C != requestByOCVId.get(acc.OCV_ID__c).PPID)
      ) {
        acc.PPID__C = requestByOCVId.get(acc.OCV_ID__c).PPID;
        accountsToUpdate.add(acc);
      }

      Boolean caseExists = false;
      // Check if the customer already has a Case created against the Channel SID being passed
      for (Case existingCase : acc.Cases) {
        if (
          (String) existingCase.Twilio_Channel_SID__c ==
          requestByOCVId.get(acc.OCV_ID__c).channelSID
        ) {
          // Customer already have a Case against the same Chat Channel
          responseList.add(
            generateResponse(acc.OCV_ID__c, existingCase.CaseNumber, '')
          );
          caseExists = true;
          break;
        }
      }

      // record response status against each OCV ID
      responseStatusByOCVId.put(acc.OCV_ID__c, caseExists);

      // Create a new Case linked to the customer with Channel SID, if no related Case exists
      if (
        !caseExists &&
        String.isNotBlank(requestByOCVId.get(acc.OCV_ID__c).caseType)
      ) {
        Case newCase = new Case();
        newCase.AccountId = acc.Id;
        newCase.Origin = CASE_CHANNEL_CHAT;
        newCase.Twilio_Channel_SID__c = requestByOCVId.get(acc.OCV_ID__c)
          .channelSID;
        newCase.Type = requestByOCVId.get(acc.OCV_ID__c).caseType;
        newCase.RecordTypeId = GENERAL_INQUIRY_RT_ID;
        if (generalInquiryQueue != null) {
          newCase.OwnerId = generalInquiryQueue.Id;
        }
        newCases.add(newCase);
      }
    }

    if (
      !accountsToUpdate.isEmpty() &&
      Account.sObjectType.getDescribe().isUpdateable()
    ) {
      List<Database.SaveResult> results = Database.Update(
        accountsToUpdate,
        false
      );

      lib_systemLog log = new lib_systemLog('ChatContextService', 'doPost');
      Boolean hasError = log.addDatabaseSaveResult(
        'Account',
        results,
        accountsToUpdate
      );
      if (hasError) {
        //log errors to application log
        log.insertLog();
      }
    }

    // Insert new Case records to represent the Chat Topic, if there weren't any related Cases
    createNewCases(newCases, responseStatusByOCVId, responseList);

    // Return Account 'External_Id__c' as the 'sfdcSearchString' if no Case was found or created
    // 'External_Id__c' is assumed to be present at all times on the Account record.
    for (String ocvId : accountByOCVId.keySet()) {
      if (!responseStatusByOCVId.get(ocvId)) {
        responseList.add(
          generateResponse(ocvId, accountByOCVId.get(ocvId).External_Id__c, '')
        );
      }
    }

    // Handling responses against requests with invalid OCV Ids
    for (String ocvId : requestByOCVId.keySet()) {
      if (!accountByOCVId.keySet().contains(ocvId)) {
        String errorMessage =
          'Could not find a matching ANZx customer record based on OCV ID: ' +
          ocvId;

        responseList.add(generateErrorResponse(ocvId, '', errorMessage));
      }
    }

    // At least one request was successful
    for (ChatContextResponse res : responseList) {
      if (res.statusCode == 200) {
        finalStatusCode = 200;
        break;
      }
    }

    //Generate Response based on the results
    String jsonRes = JSON.serialize(responseList);
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(jsonRes);
    RestContext.response.statusCode = finalStatusCode;
  }

  /**
   * @description Method to find or create related Case records against the Customer and Chat Topic / Channel
   * @param newCases new Case records to be created
   * @param responseStatusByOCVId response status by OCVId
   * @param responseList list of responses to be returned
   * @return `Map<String, Boolean>` response status by OCVId
   */
  private static Map<String, Boolean> createNewCases(
    List<Case> newCases,
    Map<String, Boolean> responseStatusByOCVId,
    List<ChatContextResponse> responseList
  ) {
    // Insert new Case records to represent the Chat Topic
    if (!newCases.isEmpty()) {
      if (
        Case.sObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Case.fields.AccountId.isCreateable() &&
        Schema.sObjectType.Case.fields.Origin.isCreateable() &&
        Schema.sObjectType.Case.fields.OwnerId.isCreateable() &&
        Schema.sObjectType.Case.fields.RecordTypeId.isCreateable() &&
        Schema.sObjectType.Case.fields.Type.isCreateable() &&
        Schema.sObjectType.Case.fields.Twilio_Channel_SID__c.isCreateable()
      ) {
        List<Database.SaveResult> results = Database.insert(newCases, false);

        // Query newly inserted Cases to retrive Case Number
        Map<ID, Case> newCaseMap = new Map<ID, Case>(
          [
            SELECT Id, CaseNumber, Account.OCV_ID__c, Account.External_Id__c
            FROM Case
            WHERE Id IN :newCases
          ]
        );

        for (Integer i = 0; i < newCases.size(); i++) {
          Database.SaveResult sr = results[i];

          if (sr.isSuccess()) {
            responseList.add(
              generateResponse(
                newCaseMap.get(newCases[i].Id).Account.OCV_ID__c,
                newCaseMap.get(newCases[i].Id).CaseNumber,
                ''
              )
            );

            responseStatusByOCVId.put(
              newCaseMap.get(newCases[i].Id).Account.OCV_ID__c,
              true
            );
          } else {
            // Returning a success response with an error message, since Twilio could still create Tasks with Customer Identifier
            String errorMessage =
              'Faled to auto create a new Case against the customer customer. OCV ID: ' +
              accountsById.get(newCases[i].AccountId).OCV_ID__c +
              '. Error: ';
            for (Database.Error err : sr.getErrors()) {
              errorMessage += err;
            }

            responseList.add(
              generateResponse(
                accountsById.get(newCases[i].AccountId).OCV_ID__c,
                accountsById.get(newCases[i].AccountId).External_Id__c,
                errorMessage
              )
            );

            responseStatusByOCVId.put(
              accountsById.get(newCases[i].AccountId).OCV_ID__c,
              true
            );
          }
        }
      } else {
        CommonUtil.logAndThrowIAE(
          'ChatContextService',
          'createNewCases',
          'Not enough permissions to create Case.'
        );
      }
    }

    return responseStatusByOCVId;
  }

  /**
   * @description Method to check if the request record is valid or not.
   * @param chatContext Chat Context instance
   * @return `Boolean` true if the record is valid. Otherwise return false.
   */
  private static Boolean isValidRequest(ChatContextRequest chatContext) {
    //Check if PPID is present but don't cancel flow if not present
    if (String.isBlank(chatContext.PPID)) {
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        'ChatContextService',
        'isValidRequest'
      );
      log.error('Missing PPID from request');
      log.insertLog();
    }
    //Check to make sure OCV ID and Channel ID are present
    return String.isNotBlank(chatContext.ocvId) &&
      String.isNotBlank(chatContext.channelSID);
  }

  /**
   * @description Method to generate a response instance
   * @param ocvId OCV ID related to the original request
   * @param sfdcSearchString Search String to be used on related Twilio Task
   * @param errMsg error message
   * @return `ChatContextResponse`
   */
  private static ChatContextResponse generateResponse(
    String ocvId,
    String sfdcSearchString,
    String errMsg
  ) {
    ChatContextResponse response = new ChatContextResponse();
    response.ocvId = ocvId;
    response.success = true;
    response.statusCode = 200;
    response.sfdcSearchString = sfdcSearchString;
    // There is one instance where we pass a message (with error details) back to Twilio as a success response.
    // This is when Case auto-creation fails due to some reason, but still Salesforce should return the unique customer identifier instead of a new Case Number.
    response.errorMessage = errMsg;
    return response;
  }

  /**
   * @description Method to generate an error response instance
   * @param ocvId OCV ID related to the original request
   * @param sfdcSearchString Search String to be used on related Twilio Task
   * @param errMsg error message
   * @return `ChatContextResponse`
   */
  private static ChatContextResponse generateErrorResponse(
    String ocvId,
    String sfdcSearchString,
    String errMsg
  ) {
    ChatContextResponse response = new ChatContextResponse();
    response.ocvId = ocvId;
    response.success = false;
    response.statusCode = 400;
    response.sfdcSearchString = sfdcSearchString;
    response.errorMessage = errMsg;
    return response;
  }

  /**
   * @description Wrapper class to store Chat Context Request parameters
   */
  global class ChatContextRequest {
    /**
     * @description Customer OCV ID
     */
    public String ocvId { get; set; }
    /**
     * @description Channel SID from Twilio related to the Chat Topic
     */
    public String channelSID { get; set; }
    /**
     * @description Case Type as a String based on Chat contexed passed from App in to Twilio
     */
    public String caseType { get; set; }
    /**
     * @description PPID from Twilio
     */
    public String ppid { get; set; }
  }

  /**
   * @description Wrapper class to store tChat Context Response parameters
   */
  global class ChatContextResponse {
    /**
     * @description Customer OCV ID
     */
    public String ocvId { get; set; }
    /**
     * @description Response result (true or false)
     */
    public Boolean success { get; set; }
    /**
     * @description Response code. 200 for success. 400 for failure.
     */
    public Integer statusCode { get; set; }
    /**
     * @description Salesforce ID
     */
    public String sfdcSearchString { get; set; }
    /**
     * @description Error Message for failure response
     */
    public String errorMessage { get; set; }
  }
}
