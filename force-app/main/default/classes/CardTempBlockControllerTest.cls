/**
 * @author Peter Charalambous
 * @since 2021
 * @description CardTempBlockControllerTest is the test class to cover tests for {@link CardTempBlockController}
 */
@isTest
public with sharing class CardTempBlockControllerTest {
  /**
   * @description test method for blockCard when successful
   */
  @isTest
  public static void validResponse() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCallout()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    Test.startTest();
    String respBody = CardTempBlockController.blockCard(
      '4444444444444444',
      '1111'
    );
    System.assertEquals('{"access_token":"xxxxx","expires_in":900}', respBody);
    Test.stopTest();
  }

  /**
   * @description test method for blockCard when forge token failed
   */
  @isTest
  public static void invalidResponseFromForgeToken() {
    Test.setMock(
      HttpCalloutMock.class,
      new ForgeTokenHandlerTest.MockForgeCalloutFailed()
    );
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    String expMessage;

    Test.startTest();
    try {
      CardTempBlockController.blockCard('4444444444444444', '1111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get access token failed', expMessage);

    Test.stopTest();
  }

  /**
   * @description test method for blockCard when failed
   */
  @isTest
  public static void invalidResponse() {
    Test.setMock(HttpCalloutMock.class, new MockInvalidCardBlockCallout());
    Id userId = UserInfo.getUserId();
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + userId,
      ForgeTokenHandlerTest.IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );

    String expMessage;

    Test.startTest();
    try {
      CardTempBlockController.blockCard('4444444444444444', '1111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Block card failed', expMessage);

    Test.stopTest();
  }
  class MockInvalidCardBlockCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().endsWith('block')) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Block card failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }
}
