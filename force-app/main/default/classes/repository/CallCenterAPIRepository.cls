/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Call Center API repository for all chat, voice calling, sms callouts
 * @group Repository
 */
public with sharing class CallCenterAPIRepository extends RepositoryBase {
  public static final String CHANNELS_ENDPOINT_SUFFIX = '/channels';
  public static final Integer OFFSET_LIMIT = 20;

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
    ChatChannelModel result;
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
    ChatChannelModel.Channel result;

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
    ChatChannelModel result;
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.fetchChatTopics(ocvId, endPoint);
    if (response.successful) {
      try {
        result = ChatChannelModel.parseChannels(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CallCenterAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CallCenterAPIRepository.class);
    }
    return result;
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
    ChatChannelModel.Channel result;
    Service s = ServiceProvider.getService(TwilioService.class);
    HttpCalloutResponse response = s.fetchChatTopics(ocvId, endPoint);
    if (response.successful) {
      try {
        result = ChatChannelModel.parseSingleChannel(response.body);
      } catch (Exception e) {
        handleErrors(null, e, CallCenterAPIRepository.class);
      }
    } else {
      handleErrors(response, null, CallCenterAPIRepository.class);
    }
    return result;
  }
}
