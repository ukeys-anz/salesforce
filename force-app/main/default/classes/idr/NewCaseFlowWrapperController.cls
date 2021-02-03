/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
public with sharing class NewCaseFlowWrapperController {
  /**
   * @description Get the Developer Name of a Case record type based on its Id
   * @param id Record Type ID
   * @return The RT's Dev Name
   */
  @AuraEnabled
  public static String getCaseRecordTypeDevNameById(Id id) {
    return Schema.SObjectType.Case.getRecordTypeInfosById()
      .get(id)
      .getDeveloperName();
  }

  /**
   * @description Get the active Chat Topic ID (if any) by the Account ID (customer)
   * @param accountID Account ID related to the customer
   * @return String having the Active Chat Topic ID
   */
  @AuraEnabled
  public static string getActiveChatTopicIDsByCustomer(Id accountID) {
    // TODO: Only run below logic for Case record types which has a possibility of originating from a Chat.
    //       (Might have to pass in Record Type ID from Aura Controller to figure out the Record Type name)

    String activeChatTopicID = '';

    // Get OCV ID by passing in SF Account ID
    String ocvId = getOCVId(accountID);

    // Get Active Chat Topics from Twilio
    List<ChatChannelsResponseWrapper.Channels> activeChatTopics = getActiveChatChannelsFromTwilio(
      ocvId
    );

    // Extract Channel SIDs from Active Chat Topics
    activeChatTopicID = getChatChannelSIDs(activeChatTopics);

    // If more than one active Chat Topic found, log an Application Log entry including the '|' seperated string of all returned Chat Topic IDs
    if (activeChatTopics.size() > 1) {
      lib_systemLog.createSingleLog(
        NewCaseFlowWrapperController.class.getName(),
        'getActiveChatTopicIDsByCustomer',
        'MORE_THAN_ONE_ACTIVE_CHAT_TOPIC',
        'More than one "Acitve" Chat Topics found while trying to auto-link to a Case.' +
        ' - ' +
        'Channel SIDs :' +
        activeChatTopicID +
        ' - Account ID:' +
        accountID +
        ' - ' +
        'If user decides to save the Case (with or without a linked Chat Topic), the custom field "Auto_matched_Chat_Topic_IDs__c" on the particular Case record will me marked with auto-matched Chat Topic IDs to help troubleshooting.',
        lib_systemLog.Severity.WARNING
      );
    }

    return activeChatTopicID;
  }

  /**
   * @description Get Active Chat Channels (Topics) from Twilio.
   *    NOTE: Mule-Twilio API only returns filtered results within offset limit (MAX 20).
   *    Therefore, we have to keep on querying the API until there is no 'Next' attribute present in the response to identify all 'Active' chat topics
   * @param ocvId Customer OCV ID
   * @return List<ChatChannelsResponseWrapper.Channels>
   */
  private static List<ChatChannelsResponseWrapper.Channels> getActiveChatChannelsFromTwilio(
    String ocvId
  ) {
    // Loop through results to identify Active Chat Topics
    // NOTE: A singe iteration of below loop will return a maximum of 20 records (Maximum offset limit supported by the API is 20 records at once)
    //       If a particular customer have had 60 different Chat Topics throughout the lifetime with ANZx, the API will be called 3 times which is 60/20.
    List<ChatChannelsResponseWrapper.Channels> activeChatTopics = new List<ChatChannelsResponseWrapper.Channels>();
    String nextURL = '';
    do {
      // Make a callout to Mulesoft to fetch all Chat Topics related to the customer
      String responseBody = getActiveChatTopics(ocvId, nextURL);

      // Process and deserialize response body
      ChatChannelsResponseWrapper responseWrapper = deserializeResponse(
        responseBody
      );

      // Keep on adding to the list unil there is no Next set
      if (responseWrapper.hasChannels()) {
        activeChatTopics.addAll(responseWrapper.channels);
      }

      nextURL = responseWrapper.nextUrl();
    } while (nextURL != null);

    return activeChatTopics;
  }

  /**
   * @description Extracts Channel SIDs (Chat Topic IDs) from active Chat Topics. Returns a String containing Channel SIDs separated by '|'
   * @param activeChatTopics List of active Chat Topics from response wrapper
   * @return String
   */
  private static String getChatChannelSIDs(
    List<ChatChannelsResponseWrapper.Channels> activeChatTopics
  ) {
    String activeChatTopicID = '';
    if (!activeChatTopics.isEmpty()) {
      if (activeChatTopics.size() == 1) {
        activeChatTopicID = activeChatTopics[0].Id;
      } else {
        // Return '|' seperated string of all returned Chat Topic IDs, and save it on a custom field on Case object (not visible on Page Layout) ?
        for (ChatChannelsResponseWrapper.Channels topic : activeChatTopics) {
          activeChatTopicID += !String.isBlank(activeChatTopicID)
            ? '|' + topic.Id
            : topic.Id;
        }
      }
    }
    return activeChatTopicID;
  }

  /**
   * @description Query for Customer OCV ID by passing in the Account ID
   * @param accountID SF Account ID related to the Customer
   * @return String
   */
  private static String getOCVId(Id accountID) {
    if (Account.sObjectType.getDescribe().isQueryable()) {
      List<Account> accounts = [
        SELECT OCV_ID__c
        FROM Account
        WHERE Id = :accountID
      ];
      if (!accounts.isEmpty()) {
        return accounts[0].OCV_ID__c;
      }
    }
    return null;
  }

  /**
   * @description Deserialize JSON response
   * @param responseBody JSON response body
   * @return ChatChannelsResponseWrapper
   */
  private static ChatChannelsResponseWrapper deserializeResponse(
    String responseBody
  ) {
    // Replace '_links' with 'xlinks'
    if (String.isNotBlank(responseBody)) {
      responseBody = responseBody.replace('_links', 'xlinks');
    }

    ChatChannelsResponseWrapper responseWrapper = (ChatChannelsResponseWrapper) JSON.deserialize(
      responseBody,
      ChatChannelsResponseWrapper.class
    );
    return responseWrapper;
  }

  /**
   * @description Fetch Chat Topics via API by passing in customer OCV ID
   * @param ocvID Customer OCV ID
   * @param nextURL URL to get next result set if available
   * @return String
   */
  public static String getActiveChatTopics(String ocvID, String nextURL) {
    String urlParams =
      '?status=active&chatFlowStatus=ACCEPTED&limit=' +
      ChatTopicRelatedListController.OFFSET_LIMIT;

    String responseBody = null;
    if (String.isNotBlank(ocvID)) {
      HttpRequest request = new HttpRequest();
      String finalURL = String.isBlank(nextURL) ? urlParams : nextURL;
      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Get_CustomerChatChannels +
        ocvID +
        ChatTopicRelatedListController.CHANNELS_ENDPOINT_SUFFIX +
        finalURL
      );

      RequestUtils.setCommonRequestParams(request, 'GET');
      responseBody = RequestUtils.processRequest(
        request,
        NewCaseFlowWrapperController.class.getName(),
        'getActiveChatTopics',
        NewCaseFlowWrapperController.class.getName(),
        true
      );
    }

    return responseBody;
  }
}
