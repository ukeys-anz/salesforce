/**
 * @description Test class for {@link PDIApiRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIApiRepositoryTest {
  @IsTest
  static void testSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = '{"publicKeyCredentials": []}';
    Lib_MockProvider.forType(PDIService.class)
      .mock('getPublicKeyCredentials', success);
    Exception ex;
    try {
      new PDIApiRepository().getPublicKeyCredentials('customerUuid', null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PDIService.class)
      .mock('getPublicKeyCredentials', error);
    Exception ex;
    try {
      new PDIApiRepository().getPublicKeyCredentials('customerUuid', null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }
}
