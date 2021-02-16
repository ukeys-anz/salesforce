@isTest
public inherited sharing class FabricServiceTest {
  @isTest
  static void testGetAccountsAndGoals() {
    Test.setMock(HttpCalloutMock.class, new MockFabricCallout());
    //load forge staff token
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      ForgeTokenHandlerTest.IDTESTVALUE
    );

    Test.startTest();
    FabricService service = new FabricService();
    HttpCalloutResponse response = service.getAccountsAndGoals('1111');
    Test.stopTest();

    System.assertEquals(201, response.statusCode);
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      FabricService.class
    );
    Test.stopTest();
    System.assert(serviceResult instanceof FabricServiceMock);
  }

  @isTest
  static void getBadService() {
    Exception resultException;
    Test.startTest();
    try {
      ServiceProvider.getService('energy-innovation-1488');
    } catch (Exception e) {
      resultException = e;
    }

    Test.stopTest();
    System.assertEquals(
      'No Service class found called [energy-innovation-1488]',
      resultException.getMessage()
    );
  }

  class MockFabricCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().endsWith('accounts')) {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody(FabricServiceMock.ACCOUNTS_AND_GOALS_SUCCESS_RESPONSE);
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }
}
