/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Mock implementation of Twilio api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TwilioServiceMock extends Service {
  @TestVisible
  private static final String CHAT_CHANNELS_SUCCESS_RESPONSE = '{\"channels\":[{\"id\":\"CH147c6128b4864e0aaadc58d87d74e50c\",\"name\":\"Demo1\",\"status\":\"active\",\"chatFlowStatus\":\"NEW\",\"lastModified\":\"2021-02-18T03:53:45Z\"},{\"id\":\"CH07de552ae10641328a77758d2dc9c777\",\"name\":\"TransactionHelp\",\"status\":\"active\",\"chatFlowStatus\":\"ACCEPTED\",\"lastModified\":\"2021-02-13T03:37:25Z\"}],\"_links\":{\"_links\":{\"next\":\"/chat/users/4017631302/channels?limit=3&sortBy=lastModified&order=desc&offset=PTCH2e701f0ed62b4e2689a37ef09290251e\",\"self\":\"/chat/users/4017631302/channels?limit=3&sortBy=lastModified&order=desc\"}},\"failures\":[{\"id\":\"CH0699d7c4e69f45aa953bd642a012f7f1\",\"message\":\"Therequestedresource/Conversations/CH0699d7c4e69f45aa953bd642a012f7f1wasnotfound\"}]}';

  @TestVisible
  private static final String SINGLE_CHAT_CHANNEL_SUCCESS_RESPONSE = '{\"id\":\"CHc6ad9b34eb3e4788a12eb1caa07aefd5\",\"name\":\"April2021\",\"status\":\"inactive\",\"chatFlowStatus\":\"ON_HOLD\",\"onHoldReason\":\"WAITING_ON_CUSTOMER\",\"lastModified\":\"2021-04-15T01:59:56Z\"}';

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
