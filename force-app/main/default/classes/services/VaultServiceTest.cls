/**
 * @author Shivam Swaraj
 * @since 2024
 * @description Test Class for VaultService
 */
@isTest
public with sharing class VaultServiceTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String FAILURE_TOKENIZE_DOCUMENT_NUMBER_RESPONSE =
    '{' +
    '  \"error\": \"Invalid token.\"' +
    '}';
  private static final String FAILURE_DETOKENIZE_DOCUMENT_NUMBER_RESPONSE =
    '{' +
    '  \"error\": \"Invalid token.\"' +
    '}';

  private static String customerId = FAKER.randomString(10);
  private static String customerIdType = Service.IdType.OCVID.name();

  @isTest
  static void getRealService() {
    Test.startTest();
    Service service = (Service) ServiceProvider.getService(VaultService.class);
    Test.stopTest();
    Assert.isTrue(
      service instanceof VaultServiceMock,
      'Service should be instance of VaultServiceMock.'
    );
  }

  @isTest
  static void testGetFullCardNumberDetails() {
    Test.setMock(HttpCalloutMock.class, new VaultServiceMockResponse());
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken1111',
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    DetokenizationRequestModel contextReq = new DetokenizationRequestModel();
    contextReq.value = CryptoOperationsUtilsTest.MOCK_TOKENIZED_CARD_NUMBER;
    contextReq.type = 'TOKEN_TYPE_CARD_NUMBER';
    HttpCalloutResponse response = serviceInstance.getFullCardNumberDetails(
      '1111',
      contextReq
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 200, 'Invalid status');
  }

  @isTest
  static void testTokenizeDocumentNumberSuccess() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + customerId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockTokenizeDocumentNumberSuccess()
    );

    TokenizeDocumentNumberRequestModel tokenizedDocumentNumber = new TokenizeDocumentNumberRequestModel(
      FAKER.randomString(5),
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    HttpCalloutResponse response = serviceInstance.tokenizeDocumentNumber(
      customerId,
      customerIdType,
      tokenizedDocumentNumber
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 200, 'Status code should be 200.');
  }

  @isTest
  static void testTokenizeDocumentNumberFailure() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + customerId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockTokenizeDocumentNumberFailure()
    );

    TokenizeDocumentNumberRequestModel tokenizedDocumentNumber = new TokenizeDocumentNumberRequestModel(
      FAKER.randomString(5),
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    HttpCalloutResponse response = serviceInstance.tokenizeDocumentNumber(
      customerId,
      customerIdType,
      tokenizedDocumentNumber
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 500, 'Status code should be 500.');
  }

  @isTest
  static void testDetokenizeDocumentNumberSuccess() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + customerId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockDetokenizeDocumentNumberSuccess()
    );

    DetokenizeDocumentNumberRequestModel detokenizedDocumentNumber = new DetokenizeDocumentNumberRequestModel(
      FAKER.randomString(5),
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    HttpCalloutResponse response = serviceInstance.detokenizeDocumentNumber(
      customerId,
      customerIdType,
      detokenizedDocumentNumber
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 200, 'Status code should be 200.');
  }

  @isTest
  static void testDetokenizeDocumentNumberFailure() {
    //load forge staff token
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + customerId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockDetokenizeDocumentNumberFailure()
    );

    DetokenizeDocumentNumberRequestModel detokenizedDocumentNumber = new DetokenizeDocumentNumberRequestModel(
      FAKER.randomString(5),
      VaultDocumentType.DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE
    );

    Test.startTest();
    VaultService serviceInstance = new VaultService();
    HttpCalloutResponse response = serviceInstance.detokenizeDocumentNumber(
      customerId,
      customerIdType,
      detokenizedDocumentNumber
    );
    Test.stopTest();

    Assert.areEqual(response.statuscode, 500, 'Status code should be 500.');
  }

  class VaultServiceMockResponse implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(
        JSON.serialize(CryptoOperationsUtilsTest.MOCK_GCP_RESPONSE.body)
      );
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockDetokenizeDocumentNumberSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockDetokenizeDocumentNumberFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }

  class MockTokenizeDocumentNumberSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(200);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockTokenizeDocumentNumberFailure implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse invalid response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();

      res.setStatusCode(500);
      res.setHeader('Content-Type', 'application/json');

      return res;
    }
  }
}
