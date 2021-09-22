/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Test class for {@link CallCenterAPIRepository}
 * @group Repository
 */
@isTest
public with sharing class CallCenterAPIRepositoryTest {
  /**
   * @description fetch valid chat topics by customer, mocked values in force-app/main/default/classes/services/TwilioServiceMock.cls
   */
  @isTest
  static void testValidResponseByCustomer() {
    Test.startTest();
    CallCenterAPIRepository callCenterAPI = new CallCenterAPIRepository();
    ChatChannelModel model = callCenterAPI.getChatTopicsByCustomer(
      '4017640246',
      '3267346723',
      ''
    );
    Test.stopTest();

    System.assertEquals(
      2,
      model.channels.size(),
      'Number of chat topics returned does not match with mock values size.'
    );
    System.assertEquals(
      'CH147c6128b4864e0aaadc58d87d74e50c',
      model.channels[0].id,
      'Id of 1st chat topic does not match.'
    );
  }

  /**
   * @description fetch valid chat topics by channel SID, mocked values in force-app/main/default/classes/services/TwilioServiceMock.cls
   */
  @isTest
  static void testValidResponseByChannelSID() {
    Test.startTest();
    CallCenterAPIRepository callCenterAPI = new CallCenterAPIRepository();
    ChatChannelModel.Channel channel = callCenterAPI.getChatTopicsByChannelSID(
      '4017640246',
      'CHc6ad9b34eb3e4788a12eb1caa07aefd5'
    );
    Test.stopTest();

    System.assertEquals(
      'CHc6ad9b34eb3e4788a12eb1caa07aefd5',
      channel.id,
      'Channel Id does not match.'
    );
    System.assertEquals(
      'April2021',
      channel.name,
      'Channel name does not match.'
    );
  }

  /**
   * @description fetch invalid chat topic
   */
  @isTest
  static void tetInvalidResponse() {
    ChatChannelModel model;
    HttpCalloutResponse res = getInvalidResponse();
    Service s = ServiceProvider.getService(TwilioService.class);
    s.setCalloutResponse(res);
    Exception resultException;
    Test.startTest();
    CallCenterAPIRepository callCenterAPI = new CallCenterAPIRepository();
    try {
      model = callCenterAPI.getChatTopicsByCustomer(
        '4017640246',
        '3267346723',
        ''
      );
    } catch (Exception e) {
      resultException = e;
    }
    Test.stopTest();
    System.assertEquals(
      'Get chat topics failed',
      resultException.getMessage(),
      'Error message does not match.'
    );
  }

  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Get chat topics failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }
}
