/**
 * @author Arpit Pittie
 * @date Oct 2024
 * @description Test class for {@link FinancialAccountService}
 */

@isTest
public with sharing class FinancialAccountServiceTest {
  @isTest
  static void testGetOffsetAccountsSuccess() {
    Test.setMock(HttpCalloutMock.class, new MockGetOffsetAccountsSuccess());
    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    FinancialAccountService service = new FinancialAccountService();
    HttpCalloutResponse response = service.getOffsetAccounts(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();

    Assert.areEqual(
      200,
      response.statusCode,
      'Status code of the response should be 500'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.isTrue(
      response.body.contains('loan_offsets'),
      'Response should have loan_offsets'
    );
  }

  @isTest
  static void testGetOffsetAccountsFailure() {
    Test.setMock(HttpCalloutMock.class, new MockGetOffsetAccountsFailure());
    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    FinancialAccountService service = new FinancialAccountService();
    HttpCalloutResponse response = service.getOffsetAccounts(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();

    Assert.areEqual(
      500,
      response.statusCode,
      'Status code of the response should be 500'
    );
  }

  class MockGetOffsetAccountsSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource mockResponse = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_linkedOffsetAccount'
        WITH SECURITY_ENFORCED
      ];

      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(mockResponse.Body.toString());
      return res;
    }
  }

  class MockGetOffsetAccountsFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}
