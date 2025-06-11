/**
 * @author Tan Phan
 * @since 01/2024
 * @description Test class for {@link DAONFileService}
 */
@isTest
private class DAONFileServiceTest {
  static final Faker FAKER = new Faker('AU');
  static final String CUSTOMER_ID = FAKER.randomString(10);

  static Lib_MockProvider calloutMock = TestUtil.httpCalloutMock;

  @IsTest
  static void testDownloadFiles() {
    DAONFileRequestModel request = new DAONFileRequestModel();
    Test.startTest();
    new DAONFileService().downloadFiles(request, CUSTOMER_ID, 'OCVID');
    Test.stopTest();
    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.areEqual(
      request.serialize(),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized request'
    );
  }

  @IsTest
  static void testGetHeaders() {
    Test.startTest();
    Map<String, String> headers = new DAONFileService()
      .getHeaders(CUSTOMER_ID, 'OCVID');
    Test.stopTest();
    Assert.isTrue(
      headers.containsKey('Authorization'),
      'Authorization header should be present'
    );
  }

  @IsTest
  static void testDownloadFilesMock() {
    Test.startTest();
    HttpCalloutResponse response = new DAONFileServiceMock()
      .downloadFiles(null, null, null);
    Test.stopTest();
    Assert.isTrue(response.successful, 'Response should be successful');
  }
}
