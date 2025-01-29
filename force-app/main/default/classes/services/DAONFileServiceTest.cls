/**
 * @author Tan Phan
 * @since 01/2024
 * @description Test class for {@link DAONFileService}
 */
@isTest
private class DAONFileServiceTest {
  static final Faker FAKER = new Faker('AU');
  static final String CUSTOMER_ID = FAKER.randomString(10);

  @TestSetup
  static void makeData() {
    Non_Prod_Settings__c settings = Non_Prod_Settings__c.getOrgDefaults();
    settings.SSO_Not_Configured__c = true;
    upsert settings;
  }

  static Lib_MockProvider calloutMock;
  static void registerMocks() {
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  @IsTest
  static void testDownloadFiles() {
    registerMocks();
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
    registerMocks();
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
