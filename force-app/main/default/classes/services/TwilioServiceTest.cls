/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Test class for {@link TwilioService}
 * @group Services
 */
@isTest
public inherited sharing class TwilioServiceTest {
  @isTest
  static void testFetchChatTopics() {
    Test.setMock(HttpCalloutMock.class, new MockTwilioCallout());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken4017640246',
      AuthServiceTest.IDTESTVALUE
    );
    String endPoint =
      'callout:SF_MS_Twilio' +
      Label.MS_Get_CustomerChatChannels +
      '4017640246' +
      '/channels';

    Test.startTest();
    TwilioService service = new TwilioService();
    HttpCalloutResponse response = service.fetchChatTopics(
      '4017640246',
      endPoint
    );
    Test.stopTest();

    System.assertEquals(
      201,
      response.statusCode,
      'Status code does not match.'
    );
  }

  @isTest
  static void testGetValidService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      TwilioService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof TwilioServiceMock,
      'Invalid service returned.'
    );
  }

  @isTest
  static void testGetInvalidService() {
    Exception resultException;
    Test.startTest();
    try {
      ServiceProvider.getService('non-existing-service');
    } catch (Exception e) {
      resultException = e;
    }

    Test.stopTest();
    System.assertEquals(
      'No Service class found called [non-existing-service]',
      resultException.getMessage(),
      'Error message does not match.'
    );
  }

  class MockTwilioCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(201);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(TwilioServiceMock.CHAT_CHANNELS_SUCCESS_RESPONSE);

      return res;
    }
  }
}
