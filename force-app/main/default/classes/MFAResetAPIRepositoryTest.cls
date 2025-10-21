@isTest
private class MFAResetAPIRepositoryTest {
  private static Lib_MockProvider serviceMock = Lib_MockProvider.forType(
    MFAResetService.class
  );
  private static Lib_MockProvider calloutMock = Lib_MockProvider.forType(
    Lib_HttpCallout.class
  );

  @isTest
  private static void testHandleMFAElevatedTokenResponseSuccess() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = JSON.serialize(buildMockAccessTokenResponse());
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    Test.startTest();
    String elevatedToken = MFAResetAPIRepository.handleMFAElevatedTokenResponse(
      mockResponse
    );
    Test.stopTest();

    Assert.areEqual(
      'eyJ0eXAi***ifQ.eyJzdW...6e319.uTfe...CVQUw',
      elevatedToken,
      'Access token returned is either incorrect, or blank.'
    );
  }

  @isTest
  private static void testhandleMFAResetResponseSuccess() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockMFAResetResponse(1); // "1" means mfa reset was successful
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    Test.startTest();
    Boolean isSuccess = MFAResetAPIRepository.handleMFAResetResponse(
      mockResponse
    );
    Test.stopTest();

    Assert.isTrue(
      isSuccess,
      'Should\'ve returned "true" for success response.'
    );
  }

  @isTest
  private static void testResetMFASuccessWithSuccessResponse() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockMFAResetResponse(1); // "1" means mfa reset was successful
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    serviceMock.mock('resetMFA', mockResponse);

    Test.startTest();
    Boolean isSuccess = new MFAResetAPIRepository()
      .resetMFA('mock-elevated-token');
    Test.stopTest();

    Assert.isTrue(isSuccess, 'Should\'ve returned "true" when success.');
  }

  @isTest
  private static void testResetMFASuccessWithFailureResponse() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockMFAResetResponse(0); // "0" means mfa reset was NOT successful
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    serviceMock.mock('resetMFA', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository().resetMFA('mock-elevated-token');
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown when API returns a unsuccessful response.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UnexpectedResponseMFAResetAPIException,
        'Exception is not of type "UnexpectedResponseMFAResetAPIException"'
      );
      Assert.areEqual(
        'MFA reset API returned an unsuccessful response. Expected value "1" at JSON path: removedByDeviceType.TYPE_OATH_TOTP',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testResetMFAWith400BadRequest() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse(
      'Bad Request',
      'Invalid grant type'
    );
    mockResponse.status = 'Bad Request';
    mockResponse.statusCode = 400;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('resetMFA', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository().resetMFA('mock-elevated-token');
      Test.stopTest();

      Assert.fail('Expected an exception to be thrown in case of bad request.');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UserErrorMFAResetAPIException,
        'Exception is not of type "UserErrorMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Bad Request","error_description":"Invalid grant type"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testResetMFAWith500ServerError() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse(
      'Internal Server Error',
      'Service Unavailable'
    );
    mockResponse.status = 'Internal Server Error';
    mockResponse.statusCode = 500;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('resetMFA', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository().resetMFA('mock-elevated-token');
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown in case of a server error.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.ServerErrorMFAResetAPIException,
        'Exception is not of type "ServerErrorMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Internal Server Error","error_description":"Service Unavailable"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testResetMFAWithUnknownError() {
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse('Found', 'Moved temporarily');
    mockResponse.status = 'Found';
    mockResponse.statusCode = 302;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('resetMFA', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository().resetMFA('mock-elevated-token');
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown in case of an unknown error.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UnhandledMFAResetAPIException,
        'Exception is not of type "UnhandledMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Found","error_description":"Moved temporarily"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testGetElevatedTokenSuccess() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = JSON.serialize(buildMockAccessTokenResponse());
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    serviceMock.mock('getElevatedToken', mockResponse);

    Test.startTest();
    String elevatedToken = new MFAResetAPIRepository()
      .getElevatedToken(testBrokerEmail, testStaffToken);
    Test.stopTest();

    Assert.areEqual(
      'eyJ0eXAi***ifQ.eyJzdW...6e319.uTfe...CVQUw',
      elevatedToken,
      'Access token returned is either incorrect, or blank.'
    );
  }

  @isTest
  private static void testGetElevatedTokenWithEmptyToken() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = '{}'; // call successful, but no token
    mockResponse.status = 'OK';
    mockResponse.statusCode = 200;
    mockResponse.successful = true;

    serviceMock.mock('getElevatedToken', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository()
        .getElevatedToken(testBrokerEmail, testStaffToken);
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown when elevated token is missing from response.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UnexpectedResponseMFAResetAPIException,
        'Exception is not of type "UnexpectedResponseMFAResetAPIException"'
      );
      Assert.areEqual(
        'Access token not found in the response at key "access_token"',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testGetElevatedTokenFailWith400BadRequest() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse(
      'Bad Request',
      'Invalid grant type'
    );
    mockResponse.status = 'Bad Request';
    mockResponse.statusCode = 400;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('getElevatedToken', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository()
        .getElevatedToken(testBrokerEmail, testStaffToken);
      Test.stopTest();

      Assert.fail('Expected an exception to be thrown in case of bad request.');
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UserErrorMFAResetAPIException,
        'Exception is not of type "UserErrorMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Bad Request","error_description":"Invalid grant type"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testGetElevatedTokenFailWith500ServerError() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse(
      'Internal Server Error',
      'Service Unavailable'
    );
    mockResponse.status = 'Internal Server Error';
    mockResponse.statusCode = 500;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('getElevatedToken', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository()
        .getElevatedToken(testBrokerEmail, testStaffToken);
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown in case of a server error.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.ServerErrorMFAResetAPIException,
        'Exception is not of type "ServerErrorMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Internal Server Error","error_description":"Service Unavailable"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  @isTest
  private static void testGetElevatedTokenFailWithUnknownError() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = buildMockErrorResponse('Found', 'Moved temporarily');
    mockResponse.status = 'Found';
    mockResponse.statusCode = 302;
    mockResponse.successful = false;
    mockResponse.error = new CalloutException(mockResponse.body);

    serviceMock.mock('getElevatedToken', mockResponse);

    try {
      Test.startTest();
      new MFAResetAPIRepository()
        .getElevatedToken(testBrokerEmail, testStaffToken);
      Test.stopTest();

      Assert.fail(
        'Expected an exception to be thrown in case of an unknown error.'
      );
    } catch (Exception e) {
      Assert.isTrue(
        e instanceof MFAResetAPIRepository.UnhandledMFAResetAPIException,
        'Exception is not of type "UnhandledMFAResetAPIException"'
      );
      Assert.areEqual(
        '{"error":"Found","error_description":"Moved temporarily"}',
        e.getMessage(),
        'Exception message is blank or incorrect.'
      );
    }
  }

  /* END of test methods  */

  /* START : Helpers, Mock, and utils  */

  private static String buildMockErrorResponse(
    String errorTitle,
    String errorDescription
  ) {
    return '{"error":"' +
      errorTitle +
      '","error_description":"' +
      errorDescription +
      '"}';
  }

  private static Map<String, Object> buildMockAccessTokenResponse() {
    Map<String, Object> fakeAccessTokenPayload = new Map<String, Object>{
      'access_token' => 'eyJ0eXAi***ifQ.eyJzdW...6e319.uTfe...CVQUw',
      'scope' => 'AU_ANZx_Broker_Accreditation_and_Onboarding_Team',
      'token_type' => 'Bearer',
      'expires_in' => 899
    };
    return fakeAccessTokenPayload;
  }

  private static String buildMockMFAResetResponse(Integer successFlag) {
    return '{"removedByDeviceType":{"TYPE_OATH_TOTP":' + successFlag + '}}';
  }

  private static MFAResetElevatedTokenModel buildMockResponseModel() {
    return MFAResetElevatedTokenModel.parse(
      JSON.serialize(buildMockAccessTokenResponse())
    );
  }
}
