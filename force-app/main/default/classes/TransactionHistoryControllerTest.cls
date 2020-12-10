/**
 *
 * @author Lance Shi
 * @since 04/2020
 * @description TransactionHistoryControllerTest is the test class to cover tests for {@link TransactionHistoryController}
 */
@isTest
public with sharing class TransactionHistoryControllerTest {
  /**
   * @description test method for getTransactions when successful
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
    String respBody = TransactionHistoryController.getTransactions(
      '1111',
      '11111111'
    );
    System.assertEquals('{"access_token":"xxxxx","expires_in":900}', respBody);
    Test.stopTest();
  }

  /**
   * @description test method for getTransactions when forge token failed
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
      TransactionHistoryController.getTransactions('1111', '11111111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get access token failed', expMessage);

    Test.stopTest();
  }

  /**
   * @description test method for getTransactions when failed
   */
  @isTest
  public static void invalidResponse() {
    Test.setMock(HttpCalloutMock.class, new MockInvalidTransactionCallout());
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
      TransactionHistoryController.getTransactions('1111', '11111111');
    } catch (Exception e) {
      expMessage = e.getMessage();
    }

    System.assertEquals('Get transactions failed', expMessage);

    Test.stopTest();
  }
  class MockInvalidTransactionCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      if (req.getEndpoint().contains('/api/transactions?accountnumber')) {
        res.setStatusCode(500);
        res.setHeader('Content-Type', 'application/Plaintext');
        res.setBody('Get transactions failed');
      } else {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"xxxxx","expires_in":900}');
      }

      return res;
    }
  }
}
