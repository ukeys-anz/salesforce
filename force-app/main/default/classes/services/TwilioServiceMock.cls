/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Mock implementation of Twilio api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TwilioServiceMock extends Service {
  @TestVisible
  private static final String CHAT_CHANNELS_SUCCESS_RESPONSE = getStaticResource(
    'mock_chatChannels'
  );

  @TestVisible
  private static final String SINGLE_CHAT_CHANNEL_SUCCESS_RESPONSE = getStaticResource(
    'mock_chatChannelsSingle'
  );

  public override HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    if (response.statusCode == null) {
      response.statusCode = 200;
      response.body = (endPoint.contains(Label.MS_Get_CustomerChatChannels))
        ? TwilioServiceMock.CHAT_CHANNELS_SUCCESS_RESPONSE
        : TwilioServiceMock.SINGLE_CHAT_CHANNEL_SUCCESS_RESPONSE;
      response.successful = true;
    }
    return response;
  }
}
