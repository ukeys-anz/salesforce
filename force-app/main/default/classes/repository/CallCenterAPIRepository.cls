/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Call Center API repository for all chat, voice calling, sms callouts
 * @group Repository
 */
public with sharing class CallCenterAPIRepository extends RepositoryBase {
  public static final String CHANNELS_ENDPOINT_SUFFIX = '/channels';
  public static final Integer OFFSET_LIMIT = 20;
  private static final String DEFAULT_ISSUE_TYPE = 'Follow Up';
  private static final String DEFAULT_ISSUE_SUB_TYPE = 'ANZ Plus Support';

  /**
   * @param ocvId customer id
   * @param ppid ppid from twilio
   * @param nextURL the url to fetch the next set of records
   * @return `ChatChannelModel` model class constructed from api response
   * @description fetches chat channels by customer from Twilio, deserialized to a model
   */
  public ChatChannelModel getChatTopicsByCustomer(
    String ocvId,
    String ppid,
    String nextURL
  ) {
    // Construct the endpoint
    String rowLimitParam = '?limit=' + OFFSET_LIMIT;
    String urlParams = String.isBlank(nextURL) ? rowLimitParam : nextURL;

    String endPoint =
      'callout:SF_MS_Twilio' +
      Label.MS_Get_CustomerChatChannels +
      ppid +
      CHANNELS_ENDPOINT_SUFFIX +
      urlParams;

    // Call the service
    return getChatTopics(ocvId, endPoint);
  }

  /**
   * @param ocvId customer id
   * @param channelSID channel SID
   * @return `ChatChannelModel` model class constructed from api response
   * @description fetches chat channels by channel SID from Twilio, deserialized to a model
   */
  public ChatChannelModel.Channel getChatTopicsByChannelSID(
    String ocvId,
    String channelSID
  ) {
    // Construct the endpoint
    String endPoint =
      'callout:SF_MS_Twilio' +
      Label.MS_Get_CaseChatChannel +
      channelSID;

    // Call the service
    return getSingleChatTopic(ocvId, endPoint);
  }

  /**
   * @param ocvId customer id
   * @param endPoint the end point of the API callout
   * @return `ChatChannelModel` model class constructed from api response
   * @description fetches chat channels from Twilio, deserialized to a model
   */
  private ChatChannelModel getChatTopics(String ocvId, String endPoint) {
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.fetchChatTopics(ocvId, endPoint);
    if (response.successful == false) {
      Logger.error('Failed to retrieve chat topics', response.error);
      Logger.saveLog();
      throw response.error;
    }
    return ChatChannelModel.parseChannels(response.body);
  }

  /**
   * @param ocvId customer id
   * @param endPoint the end point of the API callout
   * @return `ChatChannelModel.Channel` model class constructed from api response
   * @description fetches chat channels from Twilio, deserialized to a model
   */
  private ChatChannelModel.Channel getSingleChatTopic(
    String ocvId,
    String endPoint
  ) {
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.fetchChatTopics(ocvId, endPoint);
    if (response.successful == false) {
      Logger.error('Failed to retrieve single chat topic', response.error);
      Logger.saveLog();
      throw response.error;
    }
    return ChatChannelModel.parseSingleChannel(response.body);
  }

  /**
   * @param ocvId customer id
   * @param messageContent the message content to send
   * @param customerName the first name of the customer
   * @return `InitiateChatModel` model class constructed from api response
   * @description sends the initial chat message
   */
  public InitiateChatModel initiateChat(
    String ocvId,
    String messageContent,
    String customerName
  ) {
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.initiateChat(
      ocvId,
      messageContent,
      customerName,
      DEFAULT_ISSUE_TYPE,
      DEFAULT_ISSUE_SUB_TYPE
    );
    if (response.successful == false) {
      Logger.error('Failed to initiate chat', response.error);
      Logger.saveLog();
      throw response.error;
    }
    return InitiateChatModel.parse(response.body);
  }

  /**
   * @param ocvId customer id
   * @param conversationSid the id of the chat to reinitiate
   * @return `ReinitiateChatModel` model class constructed from api response
   * @description reinitiates the customer chat
   */
  public ReinitiateChatModel reinitiateChat(
    String ocvId,
    String conversationSid
  ) {
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.reinitiateChat(ocvId, conversationSid);
    if (response.successful == false && response.statusCode == 400) {
      throw new CustomException(response.error.getMessage());
    }
    if (response.successful == false) {
      Logger.error('Failed to reinitiate chat', response.error);
      Logger.saveLog();
      throw response.error;
    }
    return ReinitiateChatModel.parse(response.body);
  }

  /**
   * @description Custom Exception class that is used to differentiate custom and generic exceptions
   */
  public class CustomException extends Exception {
  }
}
