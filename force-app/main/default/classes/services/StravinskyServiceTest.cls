/**
 * @author Paul Boyington
 * @since May 2022
 * @description Test class for {@link StravinskyService}
 * @group Services
 */
@isTest
public inherited sharing class StravinskyServiceTest {
  private static final String SUCCESS_CLOSE_PACKAGE_RESPONSE =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '   \"meta\": { ' +
    '      \"accountA1\":{ \"number\": \"packag789\", \"status\": \"SUCCESS\" },' +
    '      \"accountS1\":{ \"number\": \"packag789\", \"status\": \"SUCCESS\" },' +
    '      \"card\":{ "number": "packag789", \"status\": \"SUCCESS\" },' +
    '      \"package\":{ \"number\": \"packag789\", \"status\": \"SUCCESS\" }' +
    '   }' +
    '}';

  private static final String FAILURE_CLOSE_PACKAGE_RESPONSE =
    '{' +
    '   \"status\": { \"code\": 400, \"description\": \"FAILURE\" },' +
    '   \"meta\": {}' +
    '}';

  @isTest
  static void getRealService() {
    Test.startTest();
    Service stravinskyService = (Service) ServiceProvider.getService(
      StravinskyService.class
    );
    Test.stopTest();
    System.assert(
      stravinskyService instanceof StravinskyServiceMock,
      'Service should be instance of StravinskyServiceMock.'
    );
  }

  @isTest
  static void testClosePackageSuccess() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    String packageId = faker.randomString(10);
    String checkingAccount = faker.randomString(10);
    String savingsAccount = faker.randomString(10);

    Test.setMock(HttpCalloutMock.class, new MockClosePackageSuccess());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      ForgeTokenHandlerTest.IDTESTVALUE
    );

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.closePackage(
      ocvId,
      packageId,
      checkingAccount,
      savingsAccount
    );

    Test.stopTest();

    System.assertNotEquals(
      null,
      response.body,
      'Response body should not be null.'
    );
  }

  @isTest
  static void testClosePackageWithFailure() {
    Faker faker = new Faker('AU');

    String ocvId = faker.randomString(10);
    String packageId = faker.randomString(10);
    String checkingAccount = faker.randomString(10);
    String savingsAccount = faker.randomString(10);
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      ForgeTokenHandlerTest.IDTESTVALUE
    );
    Test.setMock(HttpCalloutMock.class, new MockClosePackageFailure());

    Test.startTest();
    StravinskyService stravinskyService = new StravinskyService();
    HttpCalloutResponse response = stravinskyService.closePackage(
      ocvId,
      packageId,
      checkingAccount,
      savingsAccount
    );
    Test.stopTest();

    System.assertEquals(null, response.body, 'Response body should be null.');
  }

  class MockClosePackageSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      String body = req.getBody();

      res.setStatusCode(200);
      res.setBody(SUCCESS_CLOSE_PACKAGE_RESPONSE);

      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }

  class MockClosePackageFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(FAILURE_CLOSE_PACKAGE_RESPONSE);

      return res;
    }
  }
}
