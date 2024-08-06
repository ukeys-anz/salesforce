/**
 * @author Batya Aisman Sufrin
 * @since Dec 20233
 * @description Test class for {@link ConnectIDService}
 * @group Services
 */
@isTest
public inherited sharing class ConnectIDServiceTest {
  private static final String FAILURE_LIST_CONSENT_HISTORY_RESPONSE =
    '{' +
    '   \"status\": { \"code\": 500, \"description\": \"FAILURE\" },' +
    '}';

  @isTest
  static void getRealService() {
    Test.startTest();
    Service connectIdService = (Service) ServiceProvider.getService(
      ConnectIDService.class
    );
    Test.stopTest();
    Assert.isTrue(
      connectIdService instanceof ConnectIDServiceMock,
      'Service should be instance of ConnectIDServiceeMock.'
    );
  }

  @isTest
  static void testGetConsentHistoryListSuccess() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      AuthTokenCacheUtil.getHashedKey('forgeJWTToken' + ocvId + 'ForgeV2'),
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockListConsentHistorySuccess());

    Test.startTest();
    ConnectIDService connectIdService = new ConnectIDService();
    HttpCalloutResponse response = connectIdService.getConsentHistoryList(
      ocvId
    );
    Test.stopTest();

    Assert.areEqual(
      200,
      response.statusCode,
      'Response status should be as expected.'
    );
    Assert.areNotEqual(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testGetConsentHistoryListWithFailure() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);

    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      AuthTokenCacheUtil.getHashedKey('forgeJWTToken' + ocvId + 'ForgeV2'),
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockListConsentHistoryFailure());

    Test.startTest();
    ConnectIDService connectIdService = new ConnectIDService();
    HttpCalloutResponse response = connectIdService.getConsentHistoryList(
      ocvId
    );
    Test.stopTest();

    Assert.areEqual(
      500,
      response.statusCode,
      'Response status should be as expected.'
    );
  }

  class MockListConsentHistorySuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setBody(ConnectIDServiceMock.LIST_CONSENT_HISTORY_RESPONSE);

      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }

  class MockListConsentHistoryFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(FAILURE_LIST_CONSENT_HISTORY_RESPONSE);

      return res;
    }
  }
}
