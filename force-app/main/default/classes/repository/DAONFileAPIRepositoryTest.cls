/**
 * @author Tan Phan
 * @since 01/2024
 * @description Test class for {@link DAONFileAPIRepository}
 */
@isTest
private class DAONFileAPIRepositoryTest {
  @IsTest
  static void testDownloadFiles() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    Lib_MockProvider.forType(DAONFileService.class)
      .mock('downloadFiles', success);
    Exception ex;
    try {
      new DAONFileAPIRepository()
        .downloadFiles(
          new DAONFileRequestModel(),
          'customerId',
          'customerIdType'
        );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testDownloadFilesError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(DAONFileService.class)
      .mock('downloadFiles', error);
    Exception ex;
    try {
      new DAONFileAPIRepository()
        .downloadFiles(
          new DAONFileRequestModel(),
          'customerId',
          'customerIdType'
        );
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }
}
