/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Mock implementation of Twilio api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TwilioServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public TwilioServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CHAT_CHANNELS_SUCCESS_RESPONSE = getStaticResource(
    'mock_chatChannels'
  );

  @TestVisible
  private static final String SINGLE_CHAT_CHANNEL_SUCCESS_RESPONSE = getStaticResource(
    'mock_chatChannelsSingle'
  );

  @TestVisible
  private static final String INITIATE_CHAT_RESPONSE = getStaticResource(
    'mock_initiateChat'
  );

  @TestVisible
  private static final String REINITIATE_CHAT_RESPONSE = getStaticResource(
    'mock_reinitiateChat'
  );

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param endPoint the end point of the API callout
   * @return `HttpCalloutResponse` the api response
   * @description fetches chat channels (chat topics) from the Twilio API
   */
  public override HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    if (!preset) {
      response.body = (endPoint.contains(Label.MS_Get_CustomerChatChannels))
        ? TwilioServiceMock.CHAT_CHANNELS_SUCCESS_RESPONSE
        : TwilioServiceMock.SINGLE_CHAT_CHANNEL_SUCCESS_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId customer id
   * @param messageContent the content of the message to be sent
   * @param customerName the first name of the customer
   * @param issueType the issue type (default to Follow Up)
   * @param issueSubType the issue sub type (default to ANZ Plus Support)
   * @return `HttpCalloutResponse` the api response
   * @description sends the initial chat message
   */
  public override HttpCalloutResponse initiateChat(
    String ocvId,
    String messageContent,
    String customerName,
    String issueType,
    String issueSubType
  ) {
    if (!preset) {
      response.body = TwilioServiceMock.INITIATE_CHAT_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param conversationSid id the id of the chat to reinitiate
   * @return `HttpCalloutResponse` the api response
   * @description reinitiates customer chat
   */
  public override HttpCalloutResponse reinitiateChat(
    String ocvId,
    String conversationSid
  ) {
    if (!preset) {
      response.body = TwilioServiceMock.REINITIATE_CHAT_RESPONSE;
    }
    return response;
  }
}
