/**
 * @author Peter Charalambous
 * @since Thu Jun 20 2024
 * @description test class for Loan Property API repo
 */
@isTest
public with sharing class LoanApplicationPropertyAPIRepositoryTest {
  @isTest
  static void testErrorHandling() {
    Test.setMock(HttpCalloutMock.class, new MockReassessCollateralCallout());
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    String collateralAssessmentId = faker.randomString(20);
    UUIDLog uuidLog = new UUIDLog(collateralAssessmentId);
    Map<String, String> payload = new Map<String, String>{
      'collateralAssessmentId' => collateralAssessmentId
    };
    String requestPayload = json.serialize(payload, true);
    LoanApplicationPropertyService s = new LoanApplicationPropertyService();
    Test.startTest();
    HttpCalloutResponse res = s.reassessCollateralAssessment(
      requestPayload,
      ocvId,
      collateralAssessmentId
    );
    Test.stopTest();
    Assert.areEqual(res.statusCode, 400, 'API callout unsuccessful');
  }

  /**
   * @description Mock get mandate api callout
   */
  public class MockReassessCollateralCallout implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      string jsonBody = Service.getStaticResource(
        'mock_ReassessCollateralError'
      );
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(400);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(jsonBody);
      return res;
    }
  }
}
