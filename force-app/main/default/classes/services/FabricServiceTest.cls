/**
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Test class for {@link FabricService}
 * @group Services
 */
@isTest
public inherited sharing class FabricServiceTest {
  @isTest
  static void testGetFinancialAccounts() {
    Test.setMock(HttpCalloutMock.class, new MockFabricCallout());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    FabricService service = new FabricService();
    HttpCalloutResponse response = service.getFinancialAccounts(
      '1111',
      new List<String>()
    );
    Test.stopTest();

    System.assertEquals(
      201,
      response.statusCode,
      'Response statusCode should be as expected.'
    );
  }

  @isTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      FabricService.class
    );
    Test.stopTest();
    System.assert(
      serviceResult instanceof FabricServiceMock,
      'Service should be instance of FabricServiceMock.'
    );
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
      resultException.getMessage(),
      'Error message should be as expected.'
    );
  }

  @isTest
  public static void testGetCardList() {
    FabricService serviceClass = new FabricService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockCardListCallout());
    HttpCalloutResponse resp = serviceClass.getCardList('1111');
    System.assertNotEquals(
      null,
      resp.body,
      'Response body should not be null.'
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
        res.setBody(FabricServiceMock.FINANCIAL_ACCOUNTS_SUCCESS_RESPONSE);
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }

  /**
   * @author Lance Shi
   * @since 04/2021
   * @description Mock forge auth api callout result
   */
  public class MockCardListCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"cards": [{"name": "test"}]}');
      return res;
    }
  }
}
