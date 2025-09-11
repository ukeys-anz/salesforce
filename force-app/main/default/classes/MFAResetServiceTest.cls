@isTest
private class MFAResetServiceTest {
  private static Lib_MockProvider calloutMock = Lib_MockProvider.forType(
    Lib_HttpCallout.class
  );
  @isTest
  private static void testBuildElevatedTokenRequest() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';

    Test.startTest();
    Lib_HttpCallout.RESTCalloutWrapper result = MFAResetService.buildElevatedTokenRequest(
      testBrokerEmail,
      testStaffToken
    );
    Test.stopTest();

    Assert.isNotNull(
      result.headers?.get('traceparent'),
      '"traceparent" header is required for end to end traceability of request.'
    );
    Assert.areEqual(
      Label.Mulesoft_Get_Forge_Elevated_Token,
      result.endpoint,
      'Endpoint should match with CustomLabel: "Mulesoft_Get_Forge_Elevated_Token" i.e. ' +
      Label.Mulesoft_Get_Forge_Elevated_Token
    );
    Assert.isNotNull(result.requestBody, 'Request body cannot be empty');
    List<String> requestBodyFragments = result.requestBody.split('&');

    Assert.isTrue(
      requestBodyFragments.contains(
        'client_id=' + Label.Forge_MFA_Reset_Client_Id
      ),
      'Client ID should match with CustomLabel: "Forge_MFA_Reset_Client_Id" i.e. ' +
      Label.Forge_MFA_Reset_Client_Id
    );
    Assert.isTrue(
      requestBodyFragments.contains(
        'grant_type=urn:ietf:params:oauth:grant-type:token-exchange'
      ),
      'Grant type of request should be token-exchange.'
    );
    Assert.isTrue(
      requestBodyFragments.contains('subject_token=test-staff-token'),
      'Staff token is missing from request.'
    );
    Assert.isTrue(
      requestBodyFragments.contains('id_value=test-broker-email@anz.test.com'),
      'Broker email is not present in the request.'
    );
  }

  @isTest
  private static void testBuildMFAResetRequest() {
    Test.startTest();
    Lib_HttpCallout.RESTCalloutWrapper result = MFAResetService.buildMFAResetRequest(
      'mock-elevated-token'
    );
    Test.stopTest();

    Assert.isNotNull(
      result.headers?.get('traceparent'),
      '"traceparent" header is required for end to end traceability of request.'
    );
    Assert.areEqual(
      Label.Mulesoft_Reset_Forge_MFA,
      result.endpoint,
      'Endpoint should match with CustomLabel "Mulesoft_Reset_Forge_MFA" i.e. ' +
      Label.Mulesoft_Reset_Forge_MFA
    );
    Assert.areEqual(
      '{"types":["TYPE_OATH_TOTP"],"reason":"Support ticket #12345 - Broker locked out"}',
      result.requestBody,
      'Request body is not setup correctly'
    );
  }

  @isTest
  private static void testGetCommonMuleHeaders() {
    Test.startTest();
    Map<String, String> headers = MFAResetService.getCommonMuleHeaders();
    Test.stopTest();

    Assert.isTrue(
      headers.containsKey('client_id'),
      '"client_id" is missing from headers'
    );
    Assert.isTrue(
      headers.containsKey('client_secret'),
      '"client_secret" is missing from headers'
    );
    Assert.isNotNull(
      headers.get('traceparent'),
      '"traceparent" is missing from headers'
    );
    Assert.areEqual(
      '{!$Credential.UserName}',
      headers.get('client_id'),
      '"client_id" is not Mulesoft username'
    );
    Assert.areEqual(
      '{!$Credential.Password}',
      headers.get('client_secret'),
      '"client_id" is not Mulesoft username'
    );
  }

  @isTest
  private static void testGetElevatedTokenSuccess() {
    String testBrokerEmail = 'test-broker-email@anz.test.com';
    String testStaffToken = 'test-staff-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = JSON.serialize(buildMockAccessTokenResponse());
    mockResponse.statusCode = 200;
    mockResponse.status = 'OK';
    mockResponse.successful = true;
    calloutMock.mock('makeRestCallout', mockResponse);

    Test.startTest();
    HttpCalloutResponse response = new MFAResetService()
      .getElevatedToken(testBrokerEmail, testStaffToken);
    Test.stopTest();

    Assert.isTrue(
      response.successful,
      'Did not return mocked success resposne.'
    );
    Assert.isNotNull(response.body, 'Did not return mocked success body.');
    Assert.isTrue(
      response.body.contains(
        '"access_token":"eyJ0eXAi***ifQ.eyJzdW...6e319.uTfe...CVQUw"'
      ),
      'Elevated access token is missing from the returned mock response.'
    );
    Assert.isTrue(
      response.body.contains(
        '"scope":"Au_Anzx_Broker_Accreditation_And_Onboarding_Team"'
      ),
      'The scope of the elevated token is missing from the returned mock response.'
    );
  }
  @isTest
  private static void testResetMFASuccess() {
    String testElevatedToken = 'mock-elevated-token';
    HttpCalloutResponse mockResponse = new HttpCalloutResponse();
    mockResponse.body = '{"removedByDeviceType":{"TYPE_OATH_TOTP":1}}';
    mockResponse.statusCode = 200;
    mockResponse.status = 'OK';
    mockResponse.successful = true;
    calloutMock.mock('makeRestCallout', mockResponse);

    Test.startTest();
    HttpCalloutResponse response = new MFAResetService()
      .resetMFA(testElevatedToken);
    Test.stopTest();

    Assert.isTrue(
      response.successful,
      'Did not return mocked success resposne.'
    );
    Assert.areEqual(
      response.body,
      '{"removedByDeviceType":{"TYPE_OATH_TOTP":1}}',
      'Did not return mocked success body.'
    );
  }

  /* END of test methods  */

  /* START : Helpers, Mock, and utils  */

  private static String buildMockTokenErrorResponse(
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
      'scope' => 'Au_Anzx_Broker_Accreditation_And_Onboarding_Team',
      'token_type' => 'Bearer',
      'expires_in' => 899
    };
    return fakeAccessTokenPayload;
  }
}
