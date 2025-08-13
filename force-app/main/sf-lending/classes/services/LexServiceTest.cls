/**
 * @author Peter Charalambous
 * @since Tue Jun 03 2025
 * @description Test class for LexService
 */
@isTest
public inherited sharing class LexServiceTest {
  // Shared ocvId for all tests
  private static final String SHARED_OCV_ID;

  static {
    // Generate a random ocvId once for all tests
    Faker faker = new Faker('AU');
    SHARED_OCV_ID = faker.randomString(10);
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + SHARED_OCV_ID,
      AuthServiceTest.IDTESTVALUE
    );
  }

  @isTest
  static void testVerifyInsurance() {
    Faker faker = new Faker('AU');
    String requestbody = faker.randomString(20);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_verifyInsurance')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.verifyInsurance(
      requestbody,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetSettlement() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(HttpCalloutMock.class, new MockCallout('mock_settlement'));
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getSettlement(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testListLoanFacilityConfigs() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_listLoanFacilityConfigs')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.listLoanFacilityConfigs(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testListAutomaticRepaymentPreferences() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_automaticrepayments')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.listAutomaticRepaymentPreferences(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetProofOfInsurance() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_proofOfInsurance')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getProofOfInsurance(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetListMortgageContracts() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_listMortgageContracts')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getListMortgageContracts(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetSettlementAccount() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(
      HttpCalloutMock.class,
      new MockCallout('mock_getSettlementAccount')
    );
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getSettlementAccount(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetListDrawdowns() {
    Faker faker = new Faker('AU');
    String settlementId = faker.randomString(10);
    Test.setMock(HttpCalloutMock.class, new MockCallout('mock_listDrawdowns'));
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getListDrawdowns(
      settlementId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  @isTest
  static void testGetDrawdown() {
    Faker faker = new Faker('AU');
    String drawdownId = faker.randomString(10);
    Test.setMock(HttpCalloutMock.class, new MockCallout('mock_getDrawdown'));
    Test.startTest();
    LexService service = new LexService();
    HttpCalloutResponse response = service.getDrawdown(
      drawdownId,
      SHARED_OCV_ID
    );
    Test.stopTest();
    System.assertEquals(
      200,
      response.statusCode,
      'Response status code 200 expected'
    );
  }

  /**
   * @description Generic HTTP mock response using static resource
   */
  public class MockCallout implements HttpCalloutMock {
    private String resourceName;

    /**
     * @description Constructor for MockCallout
     * @param resourceName The name of the static resource to use as the mock response body
     */
    public MockCallout(String resourceName) {
      this.resourceName = resourceName;
    }

    /**
     * @description Responds to HTTP callouts with the contents of the specified static resource
     * @param req The HTTP request
     * @return HTTPResponse with status 200 and the static resource body
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(resourceName);
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
