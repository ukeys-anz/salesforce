/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Mock implementation of Twilio api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 */
public with sharing class TwilioServiceMock extends Service {
  @TestVisible
  private static final String CHAT_CHANNELS_SUCCESS_RESPONSE = '{\"channels\":[{\"id\":\"CH147c6128b4864e0aaadc58d87d74e50c\",\"name\":\"Demo1\",\"status\":\"active\",\"chatFlowStatus\":\"NEW\",\"lastModified\":\"2021-02-18T03:53:45Z\"},{\"id\":\"CH07de552ae10641328a77758d2dc9c777\",\"name\":\"TransactionHelp\",\"status\":\"active\",\"chatFlowStatus\":\"ACCEPTED\",\"lastModified\":\"2021-02-13T03:37:25Z\"}],\"_links\":{\"_links\":{\"next\":\"/chat/users/4017631302/channels?limit=3&sortBy=lastModified&order=desc&offset=PTCH2e701f0ed62b4e2689a37ef09290251e\",\"self\":\"/chat/users/4017631302/channels?limit=3&sortBy=lastModified&order=desc\"}},\"failures\":[{\"id\":\"CH0699d7c4e69f45aa953bd642a012f7f1\",\"message\":\"Therequestedresource/Conversations/CH0699d7c4e69f45aa953bd642a012f7f1wasnotfound\"}]}';

  /**
   * @description construct a mock with hardcoded success value
   */
  public TwilioServiceMock() {
    response.statusCode = 200;
    response.body = TwilioServiceMock.CHAT_CHANNELS_SUCCESS_RESPONSE;
    response.successful = true;
  }

  public override HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    return response;
  }
}
