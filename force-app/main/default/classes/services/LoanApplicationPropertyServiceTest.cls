/**
 * @author Peter Charalambous
 * @since Thu Jun 06 2024
 * @description Test class for Loan Property Service
 */
@isTest
public with sharing class LoanApplicationPropertyServiceTest {
  @isTest
  static void testGetCreditAssessmentsSuccess() {
    Faker faker = new Faker('AU');
    Test.setMock(HttpCalloutMock.class, new MockPropertyCalloutSuccess());
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
    Test.startTest();

    LoanApplicationPropertyService s = new LoanApplicationPropertyService();
    HttpCalloutResponse response = s.reassessCollateralAssessment(
      uuidLog.attachUUID(requestPayload),
      ocvId,
      collateralAssessmentId
    );
    Test.stopTest();

    System.assertEquals(
      200,
      response.statusCode,
      'Expected status code to be 200'
    );
  }

  class MockPropertyCalloutSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }
}
