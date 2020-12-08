/**
 * @author Lance Shi
 * @since 11/2020
 * @description Covers {@link ForgeTokenHandler}
 */
@isTest
public class ForgeTokenHandlerTest {
  //jwt containing a single claim of exp 26/11/2050
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';

  /**
   * @description test method for getForgeJWTToken when successful
   */
  @isTest
  public static void testGetForgeJWTToken() {
    Test.setMock(HttpCalloutMock.class, new MockForgeCallout());
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    Map<String, Object> responseMap = ForgeTokenHandler.getForgeJWTToken(
      '1111'
    );
    String accessToken = (String) responseMap.get('access_token');
    System.assertEquals(accessToken, 'xxxxx');
    Test.stopTest();
  }

  /**
   * @description test method for getForgeJWTToken when failed
   */
  @isTest
  public static void testGetForgeJWTTokenFailure() {
    Test.setMock(HttpCalloutMock.class, new MockForgeCalloutFailed());
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    try {
      ForgeTokenHandler.getForgeJWTToken('1111');
    } catch (Exception e) {
      System.assertEquals('Get access token failed', e.getMessage());
    }

    Test.stopTest();
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
}
