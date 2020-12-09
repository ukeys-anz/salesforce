/**
 * @author Aidan Majewski
 * @since 08/2020
 * @description Covers {@link GetAccountsAndGoals}
 */
@isTest
public class GetAccountsAndGoalsTest {
  /**
   * @description test method for getAccounts when successful
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
    String respBody = GetAccountsAndGoals.getAccounts('1111');
    System.assertEquals('{"access_token":"xxxxx","expires_in":900}', respBody);
    Test.stopTest();
  }

  /**
   * @description test method for getAccounts when forge token failed
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
      GetAccountsAndGoals.getAccounts('1111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get access token failed', expMessage);

    Test.stopTest();
  }

  /**
   * @description test method for getAccounts when failed
   */
  @isTest
  public static void invalidResponse() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockInvalidAccountsAndGoalsCallout()
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
      GetAccountsAndGoals.getAccounts('1111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get accounts failed', expMessage);

    Test.stopTest();
  }

  class MockInvalidAccountsAndGoalsCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().endsWith('accounts')) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Get accounts failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }
}
