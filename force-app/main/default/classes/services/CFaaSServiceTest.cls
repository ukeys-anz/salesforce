/**
 * @author Emma Bindi
 * @since November 2022
 * @description Test class for {@link CFaaSService}
 * @group Services
 */
@isTest
public inherited sharing class CFaaSServiceTest {
  private static final String DOCUMENT_NOT_FOUND_RESPONSE =
    '{' +
    '   \"error\": \"5 NOT_FOUND: File Not Found. CFaaS Error Code: 110006\"' +
    '}';

  private static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  private static final String CFAAS_DOCUMENT_RESPONSE = '"Test Document Content"';

  @isTest
  static void getRealService() {
    Test.startTest();
    Service cfaasService = (Service) ServiceProvider.getService(
      CFaaSService.class
    );
    Test.stopTest();
    System.assert(
      cfaasService instanceof CFaaSServiceMock,
      'Service should be an instance of CFaaSServiceMock'
    );
  }

  @isTest
  static void testGetDownloadUrlSuccess() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    String docId = faker.randomString(35);

    Test.setMock(HttpCalloutMock.class, new MockCFaaSDownloadUrlSuccess());
    // set forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    CFaaSService cfaasService = new CFaaSService();
    HttpCalloutResponse response = cfaasService.getDownloadUrl(ocvId, docId);
    Test.stopTest();

    System.assertNotEquals(
      null,
      response.body,
      'Response body should not be null'
    );
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testFetchCFaaSDocumentSuccess() {
    Faker faker = new Faker('AU');
    String url = faker.randomString(50);
    String otp = faker.randomString(40);
    String contentType = 'image/jpeg';

    Test.setMock(HttpCalloutMock.class, new MockCFaaSDocumentSuccess());

    Test.startTest();
    CFaaSService cfaasService = new CFaaSService();
    HttpCalloutResponse response = cfaasService.fetchDocumentContent(
      url,
      otp,
      contentType
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      response.bodyAsBlob,
      'Response body as blob should not be null'
    );
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetDownloadUrlAuthenticationFailure() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    String docId = faker.randomString(35);

    Test.setMock(HttpCalloutMock.class, new MockAuthenticationError());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    CFaaSService cfaasService = new CFaaSService();
    HttpCalloutResponse response = cfaasService.getDownloadUrl(ocvId, docId);
    Test.stopTest();

    System.assertEquals(null, response.body, 'Response body should be null.');

    System.assertEquals(
      401,
      response.statusCode,
      'Response status code 401 expected'
    );
  }

  @isTest
  static void testGetDownloadUrlDocNotFoundError() {
    Faker faker = new Faker('AU');
    String ocvId = faker.randomString(10);
    String docId = '';

    Test.setMock(HttpCalloutMock.class, new MockDocumentNotFoundError());
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART +
      'forgeJWTToken' +
      ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    CFaaSService cfaasService = new CFaaSService();
    HttpCalloutResponse response = cfaasService.getDownloadUrl(ocvId, docId);
    Test.stopTest();

    System.assertEquals(null, response.body, 'Response body should be null.');

    System.assertEquals(
      404,
      response.statusCode,
      'Response status code 404 expected'
    );
  }

  class MockAuthenticationError implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HttpResponse authentication error response
     */
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();

      res.setStatusCode(401);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(AUTHENTICATION_ERROR_RESPONSE);

      return res;
    }
  }

  class MockDocumentNotFoundError implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HttpResponse document not found response
     */
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();

      res.setStatusCode(404);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(DOCUMENT_NOT_FOUND_RESPONSE);

      return res;
    }
  }

  class MockCFaaSDownloadUrlSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HttpResponse get download url response
     */
    public HttpResponse respond(HttpRequest req) {
      StaticResource mockResponse;

      mockResponse = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_cfaasDownloadUrl'
        WITH SECURITY_ENFORCED
      ];

      HttpResponse res = new HttpResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBody(mockResponse.Body.toString());

      return res;
    }
  }

  class MockCFaaSDocumentSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HttpResponse cfaas document content response
     */
    public HttpResponse respond(HttpRequest req) {
      HttpResponse res = new HttpResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      res.setBodyAsBlob(Blob.valueOf(CFAAS_DOCUMENT_RESPONSE));

      return res;
    }
  }
}
