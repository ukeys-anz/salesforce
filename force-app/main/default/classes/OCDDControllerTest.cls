/**
 * @description Test class for {@link OCDDController}
 */
@IsTest
private class OCDDControllerTest {
  static final String OCV_ID = 'ocv-123';

  @IsTest
  static void testGetOCDDKycReviewStatusSuccess() {
    Lib_MockProvider repoMock = Lib_MockProvider.forType(
      OCDDApiRepository.class
    );

    OCDDResponseModel mockModel = new OCDDResponseModel();
    mockModel.kycReviewStatus = new OCDDResponseModel.KycReviewStatus();
    mockModel.kycReviewStatus.description = 'In Progress';

    repoMock.mock('getOCDDKycReviewStatus', mockModel);

    Test.startTest();
    String status = OCDDController.getOCDDKycReviewStatus(OCV_ID);
    Test.stopTest();

    Assert.areEqual(
      'In Progress',
      status,
      'Should return KYC status description'
    );
    Assert.areEqual(
      OCV_ID,
      repoMock.getHistory('getOCDDKycReviewStatus').getParam('ocvId'),
      'ocvId should be passed to repository'
    );
  }

  @IsTest
  static void testGetOCDDKycReviewStatusError() {
    Lib_MockProvider repoMock = Lib_MockProvider.forType(
      OCDDApiRepository.class
    );
    repoMock.mockException('getOCDDKycReviewStatus');

    Test.startTest();
    try {
      OCDDController.getOCDDKycReviewStatus(OCV_ID);
      Assert.fail('Expected AuraHandledException to be thrown');
    } catch (AuraHandledException ex) {
      Assert.isNotNull(ex, 'AuraHandledException should be thrown');
    }
    Test.stopTest();
  }
}
