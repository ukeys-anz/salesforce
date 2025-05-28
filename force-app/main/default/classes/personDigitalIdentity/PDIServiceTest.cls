/**
 * @author Tan Phan
 * @since 01/2024
 * @description Test class for {@link DAONFileService}
 */
@IsTest
private class PDIServiceTest {
  static final Faker FAKER = new Faker('AU');
  static final String CUSTOMER_ID = FAKER.randomString(10);

  static Lib_MockProvider calloutMock = TestUtil.httpCalloutMock;

  @IsTest
  static void testGetPublicKeyCredentials() {
    Test.startTest();
    new PDIService().getPublicKeyCredentials(CUSTOMER_ID, 'value');
    Test.stopTest();
    Assert.areEqual(
      '{"filter":"value"}',
      calloutMock.getHistory('makeRestCallout').getParam('requestBody'),
      'Request body should contain filter value'
    );
  }

  @IsTest
  static void testDeletePublicKeyCredential() {
    Test.startTest();
    new PDIService().deletePublicKeyCredential(CUSTOMER_ID, 'value');
    Test.stopTest();
    Assert.areEqual(
      '{"name":"value"}',
      calloutMock.getHistory('makeRestCallout').getParam('requestBody'),
      'Request body should contain name value'
    );
  }

  @IsTest
  static void testDisconnectCRN() {
    Test.startTest();
    new PDIService().disconnectCRN(CUSTOMER_ID, 'value');
    Test.stopTest();
    Assert.areEqual(
      '{"personaId":"value","personId":"' + CUSTOMER_ID + '"}',
      calloutMock.getHistory('makeRestCallout').getParam('requestBody'),
      'Request body should contain personId and personaId values'
    );
  }

  @IsTest
  static void testGetHeaders() {
    Test.startTest();
    Map<String, String> headers = new PDIService().getHeaders(CUSTOMER_ID);
    Test.stopTest();
    Assert.isTrue(
      headers.containsKey('Authorization'),
      'Authorization header should be present'
    );
  }

  @IsTest
  static void testGetPublicKeyCredentialsMock() {
    Test.startTest();
    HttpCalloutResponse response = new PDIServiceMock()
      .getPublicKeyCredentials(null, null);
    Test.stopTest();
    Assert.isTrue(response.successful, 'Response should be successful');
  }

  @IsTest
  static void testDeletePublicKeyCredentialMock() {
    Test.startTest();
    HttpCalloutResponse response = new PDIServiceMock()
      .deletePublicKeyCredential(null, null);
    Test.stopTest();
    Assert.isTrue(response.successful, 'Response should be successful');
  }

  @IsTest
  static void testDisconnectCRNMock() {
    Test.startTest();
    HttpCalloutResponse response = new PDIServiceMock()
      .disconnectCRN(null, null);
    Test.stopTest();
    Assert.isTrue(response.successful, 'Response should be successful');
  }
}
