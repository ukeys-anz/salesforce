/**
 * @author cruzb
 * @since May 2023
 * @description Service test class for BOH Service
 * @group Services
 */
@isTest
public inherited sharing class BOHServiceTest {
  @isTest
  static void testGetCreditAssessmentsSuccess() {
    String credId = '1111';
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, new MockGearboxCalloutSuccess());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    HttpCalloutResponse response = service.getCreditAssessments(credId, ocvId);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  class MockGearboxCalloutSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      StaticResource mockResponse;

      mockResponse = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_CRListAssessment'
        WITH SECURITY_ENFORCED
      ];

      HttpResponse res = new HttpResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(mockResponse.Body.toString());

      return res;
    }
  }

  @isTest
  static void testEditDebts() {
    String ocvId = '11111231';
    Test.setMock(HttpCalloutMock.class, new MockGearboxCalloutSuccess());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    BOHService service = new BOHService();
    String testDebt = '{"name": "testDebt", "uid", "testStr"}';
    HttpCalloutResponse response = service.editDebt(ocvId, testDebt);
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }
}
