/**
 * @description Test class for {@link OCDDService}
 */
@IsTest
private class OCDDServiceTest {
  static final Faker FAKER = new Faker('AU');
  static final String OCV_ID = FAKER.randomString(10);

  static Lib_MockProvider calloutMock = TestUtil.httpCalloutMock;

  @IsTest
  static void testGetOCDDKycReviewStatus() {
    AuthTokenCacheUtilTest.setupForgeAuthCache('GENESIS', OCV_ID);
    Test.startTest();
    new OCDDService().getOCDDKycReviewStatus(OCV_ID);
    Test.stopTest();

    Assert.areEqual(
      '{}',
      calloutMock.getHistory('makeRestCallout').getParam('requestBody'),
      'Request body should be empty JSON object'
    );
    Assert.areEqual(
      HTTP_METHOD.HTTP_POST,
      calloutMock.getHistory('makeRestCallout').getParam('method'),
      'HTTP method should be POST'
    );
  }

  @IsTest
  static void testGetHeaders() {
    AuthTokenCacheUtilTest.setupForgeAuthCache('GENESIS', OCV_ID);
    Test.startTest();
    Map<String, String> headers = new OCDDService().getHeaders(OCV_ID);
    Test.stopTest();

    Assert.isTrue(
      headers.containsKey('Authorization'),
      'Authorization header should be present'
    );
    Assert.isTrue(
      headers.containsKey('x-correlation-id'),
      'x-correlation-id header should be present'
    );
    Assert.areEqual(
      'application/json',
      headers.get('Content-Type'),
      'Content-Type header should be application/json'
    );
  }
}
