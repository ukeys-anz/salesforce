/**
 * @description Test class for {@link PDIApiRepository}.
 * @author Tan Phan
 * @since 04/2025
 * @group Person Digital Entity
 */
@IsTest
private class PDIApiRepositoryTest {
  static final Faker FAKER = new Faker('AU');
  static final String CUSTOMER_ID = FAKER.randomString(10);

  @IsTest
  static void testGetPublicKeyCredentialsSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = '{"publicKeyCredentials": []}';
    Lib_MockProvider.forType(PDIService.class)
      .mock('getPublicKeyCredentials', success);
    Exception ex;
    try {
      new PDIApiRepository().getPublicKeyCredentials(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testGetPublicKeyCredentialsError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PDIService.class)
      .mock('getPublicKeyCredentials', error);
    Exception ex;
    try {
      new PDIApiRepository().getPublicKeyCredentials(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }

  @IsTest
  static void testGetAccessControlsSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = '{"accessControls": []}';
    Lib_MockProvider.forType(PDIService.class)
      .mock('getAccessControls', success);
    Exception ex;
    try {
      new PDIApiRepository().getAccessControls(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testGetAccessControlsError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PDIService.class).mock('getAccessControls', error);
    Exception ex;
    try {
      new PDIApiRepository().getAccessControls(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }

  @IsTest
  static void testCreateAccessControlSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    success.body = '{}';
    Lib_MockProvider.forType(PDIService.class)
      .mock('createAccessControl', success);
    Exception ex;
    try {
      new PDIApiRepository().createAccessControl(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testCreateAccessControlError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PDIService.class)
      .mock('createAccessControl', error);
    Exception ex;
    try {
      new PDIApiRepository().createAccessControl(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }

  @IsTest
  static void testDeleteAccessControlSuccess() {
    HttpCalloutResponse success = new HttpCalloutResponse();
    success.successful = true;
    success.statusCode = 200;
    Lib_MockProvider.forType(PDIService.class)
      .mock('deleteAccessControl', success);
    Exception ex;
    try {
      new PDIApiRepository().deleteAccessControl(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testDeleteAccessControlError() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 500;
    error.error = new CalloutException('Error');
    Lib_MockProvider.forType(PDIService.class)
      .mock('deleteAccessControl', error);
    Exception ex;
    try {
      new PDIApiRepository().deleteAccessControl(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isTrue(
      ex instanceof RepositoryBase.ServerErrorException,
      'Exception should be thrown.'
    );
  }

  @IsTest
  static void testDeleteAccessControlSuppressedNotFound() {
    HttpCalloutResponse error = new HttpCalloutResponse();
    error.successful = false;
    error.statusCode = 404;
    error.error = new CalloutException(
      '{"additionalInfo":{"reason":"APP:NOT_FOUND"}}'
    );
    Lib_MockProvider.forType(PDIService.class)
      .mock('deleteAccessControl', error);
    Exception ex;
    try {
      new PDIApiRepository().deleteAccessControl(CUSTOMER_ID, null);
    } catch (Exception e) {
      ex = e;
    }
    Assert.isNull(ex, 'Exception should not be thrown.');
  }
}
