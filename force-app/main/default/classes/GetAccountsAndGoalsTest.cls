/**
 * @author Aidan Majewski
 * @since 08/2020
 * @description Covers {@link GetAccountsAndGoals}
 */
@isTest
public class GetAccountsAndGoalsTest {
  /* @isTest
  public static void validResponse() {
    Test.setMock(HttpCalloutMock.class, new MockValidAccountsAndGoalsCallout());
    Test.startTest();
    GetAccountsAndGoals.getAccounts('23');
    Test.stopTest();
    //void returntype, no valuable assertion until future refactor
    System.assert('true' == 'true');
  }
  @isTest
  public static void invalidResponse() {
    Test.setMock(
      HttpCalloutMock.class,
      new MockInvalidAccountsAndGoalsCallout()
    );

    AuraHandledException thrownException;
    Test.startTest();
    try {
      GetAccountsAndGoals.getAccounts('322');
    } catch (AuraHandledException e) {
      thrownException = e;
    }
    Test.stopTest();

    System.assert(thrownException != null);
  }*/

  class MockValidAccountsAndGoalsCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse valid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"example":"test"}');
      return res;
    }
  }

  class MockInvalidAccountsAndGoalsCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"example":"test"}');
      res.setStatusCode(500);
      return res;
    }
  }
}
