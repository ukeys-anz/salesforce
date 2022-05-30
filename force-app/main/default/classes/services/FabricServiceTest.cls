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
      ForgeTokenHandlerTest.IDTESTVALUE
    );

    Test.startTest();
    FabricService service = new FabricService();
    HttpCalloutResponse response = service.getFinancialAccounts(
      '1111',
      new List<String>()
    );
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

  @isTest
  public static void testGetForgeJWTToken() {
    FabricService serviceClass = new FabricService();

    Forgerock_Auth__mdt forgeAuth;
    if (Forgerock_Auth__mdt.sObjectType.getDescribe().isQueryable()) {
      forgeAuth = [
        SELECT
          Id,
          Encrypted_Forge_Client_Id__c,
          Encrypted_Forge_Client_Secret__c
        FROM Forgerock_Auth__mdt
        WHERE DeveloperName = 'Forgerock'
        LIMIT 1
      ];
    }

    Test.setMock(HttpCalloutMock.class, new MockForgeCallout());
    HttpCalloutResponse resp = serviceClass.getForgeJWTToken(
      '1111',
      ForgeTokenHandlerTest.IDTESTVALUE,
      forgeAuth
    );
    System.assertNotEquals(null, resp.body);
  }

  @isTest
  public static void testGetCardList() {
    FabricService serviceClass = new FabricService();
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      ForgeTokenHandlerTest.IDTESTVALUE
    );

    Test.setMock(HttpCalloutMock.class, new MockCardListCallout());
    HttpCalloutResponse resp = serviceClass.getCardList('1111');
    System.assertNotEquals(null, resp.body);
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
   * @since 11/2020
   * @description Mock forge auth api callout result
   */
  public class MockForgeCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"access_token":"xxxxx","expires_in":900}');
      return res;
    }
  }

  /**
   * @author Lance Shi
   * @since 11/2020
   * @description Mock forge auth api callout result
   */
  public class MockForgeCalloutFailed implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/Plaintext');
      res.setBody('Get access token failed');
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
