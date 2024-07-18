/**
 * @author shawg2
 * @since January 2024
 * @description Test class for JoinCIBAService
 * @group Services
 */

@IsTest
private class JoinCIBAServiceTest {
  public static final String AUTH_SUCCESS_RESPONSE = CCRMARNCService.generateJWTToken();

  @IsTest
  static void getRealService() {
    Test.startTest();
    Service serviceResult = (Service) ServiceProvider.getService(
      JoinCIBAService.class
    );
    Test.stopTest();
    Assert.isTrue(
      serviceResult instanceof JoinCIBAServiceMock,
      'Service should be instance of JoinCIBAServiceMock.'
    );

    String strJSON = ((JoinCIBAServiceMock) serviceResult)
      .getAuthorisationRequest('', '');
    Assert.isFalse(
      String.isEmpty(strJSON),
      'The expected JSON string is not returned'
    );
  }

  @isTest
  static void testInitiateAuthenticationRequest() {
    Test.setMock(HttpCalloutMock.class, new JoinCIBAServiceMockResponse());
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    storeSampleforgeJWTToken(ocvId);
    Test.startTest();
    JoinCIBAService jcs = new JoinCIBAService();
    HttpCalloutResponse hcr = jcs.initiateAuthenticationRequest(ocvId, '123');
    Test.stopTest();
    assert.areEqual(hcr.statuscode, 200, 'Invalid status');
  }

  @isTest
  static void testAuthenticationPollingResponse() {
    Test.setMock(HttpCalloutMock.class, new JoinCIBAServiceMockResponse());
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    storeSampleforgeJWTToken(ocvId);
    Test.startTest();
    JoinCIBAService jcs = new JoinCIBAService();
    HttpCalloutResponse hcr = jcs.authenticationPollingResponse('123', ocvId);
    Test.stopTest();
    assert.areEqual(hcr.statuscode, 200, 'Invalid status');
  }

  @isTest
  static void testGetPublicKey() {
    Test.setMock(HttpCalloutMock.class, new JoinCIBAServiceMockResponse());
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    storeSampleforgeJWTToken(ocvId);
    Test.startTest();
    JoinCIBAService jcs = new JoinCIBAService();
    HttpCalloutResponse hcr = jcs.getPublicKey('123', ocvId);
    Test.stopTest();
    assert.areEqual(hcr.statuscode, 200, 'Invalid status');
  }
  class JoinCIBAServiceMockResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(AUTH_SUCCESS_RESPONSE);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  private static void storeSampleforgeJWTToken(String ocvId) {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );
  }
}
