/**
 * @title OCDD API Repository Test
 * @description Test class for {@link OCDDApiRepository}
 */
@IsTest
private class OCDDApiRepositoryTest {
  static final String OCV_ID = 'ocv-123';

  @IsTest
  static void testGetOCDDKycReviewStatusSuccess() {
    Lib_MockProvider ocddServiceMock = Lib_MockProvider.forType(
      OCDDService.class
    );

    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.successful = true;
    mockResponse.statusCode = 200;
    mockResponse.body = '{"kycReviewStatus":{"id":"1","description":"Approved"}}';

    ocddServiceMock.mock('getOCDDKycReviewStatus', mockResponse);

    Test.startTest();
    OCDDResponseModel result = new OCDDApiRepository()
      .getOCDDKycReviewStatus(OCV_ID);
    Test.stopTest();

    Assert.areEqual(
      'Approved',
      result.kycReviewStatus.description,
      'KYC review status description should be parsed'
    );
    Assert.areEqual(
      OCV_ID,
      ocddServiceMock.getHistory('getOCDDKycReviewStatus').getParam('ocvId'),
      'ocvId should be passed to service'
    );
  }

  @IsTest
  static void testGetOCDDKycReviewStatusAccessError() {
    Lib_MockProvider ocddServiceMock = Lib_MockProvider.forType(
      OCDDService.class
    );

    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.successful = false;
    mockResponse.statusCode = 403;
    mockResponse.error = new CalloutException('Forbidden');

    ocddServiceMock.mock('getOCDDKycReviewStatus', mockResponse);

    Test.startTest();
    try {
      new OCDDApiRepository().getOCDDKycReviewStatus(OCV_ID);
      Assert.fail('Expected InsufficientAccessException to be thrown');
    } catch (RepositoryBase.InsufficientAccessException ex) {
      Assert.isTrue(
        ex.getMessage().contains('Forbidden'),
        'Exception message should include callout error'
      );
    }
    Test.stopTest();
  }
}
