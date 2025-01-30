@isTest
private class LoanappServiceTest {
  public final static String IDTESTVALUE = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjI1NTMwMzIxNzh9.eAWGLhTYhn4y9M2t2OHeTLIe7MLPObBFK2Nli8CPTD4';

  @isTest
  static void getCreateApplicationCalloutResponse() {
    Cache.Session.put(
      'local.SessionAzureTokens.idToken' + UserInfo.getUserId(),
      IDTESTVALUE,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new CreateLoanappTestMock());
    LoanappModel lm = new LoanappModel();
    lm.request_id = String.valueOf(UUID.randomUUID());
    LoanappService svc = new LoanappService();
    String result = svc.getCreateApplicationCalloutResponse(lm);
    Test.stopTest();
    Assert.isNotNull(result, 'Application key should be returned!');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class CreateLoanappTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource('mock_createLoanappResponse');
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
