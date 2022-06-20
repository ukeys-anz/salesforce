/**
 *
 * @author Pavan Kumar Ananta
 * @since Feb 2020
 * @description Test class for {@link Lib_HttpCallout}
 * @group Library
 */
@isTest
public inherited sharing class Lib_HttpCalloutTest {
  private static final String TEST_SUCCESS_BODY = '[{"Name": "Test"}]';
  private static final String TEST_FAILURE_BODY = '{"code":"ERROR","message":"Internal Server Error","additionalInfo":{"reason":"HTTP:UNAUTHORIZED","category":"TECHNICAL","errorDetails":"An error occurred during processing, please consult logs for more information"}}';
  @isTest
  static void testMakeRestCalloutSuccess() {
    Lib_HttpMockCallout fakeResponse = new Lib_HttpMockCallout(
      200,
      'Complete',
      TEST_SUCCESS_BODY,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'https://testapi.com/test',
      HTTP_METHOD.HTTP_GET,
      null,
      null
    );
    System.assert(response.successful, 'Successful response');
    System.assertEquals(
      'Complete',
      response.status,
      'The response status should be as expected.'
    );
    System.assertEquals(
      TEST_SUCCESS_BODY,
      response.body,
      'The response body should be as expected.'
    );
    System.assertEquals(200, response.statusCode, 'Status code is 200');
    System.assert(response.error == null, 'There are no exceptions');
  }

  @isTest
  static void testMethodNullError() {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      '',
      HTTP_METHOD.HTTP_GET,
      null,
      null
    );
    System.assert(
      response.successful == false,
      'The callout was not successful'
    );
    System.assert(
      response.error instanceof CalloutException,
      'Callout exception'
    );
    System.assertEquals(
      'Endpoint or Method cannot be empty for a HTTP callout',
      response.error.getMessage(),
      'The error message should be as expected.'
    );
  }

  @isTest
  static void testSuccessBlankResponse() {
    Lib_HttpMockCallout fakeResponse = new Lib_HttpMockCallout(
      200,
      'Complete',
      '   ',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'https://testapi.com/test',
      HTTP_METHOD.HTTP_POST,
      null,
      TEST_SUCCESS_BODY
    );
    System.assertEquals(
      'Complete',
      response.status,
      'The response status should be as expected.'
    );
    System.assertEquals(200, response.statusCode, 'Status code is 200');
    System.assert(response.successful, 'The callout was successful');
    System.assert(String.isBlank(response.body), 'Response Body was empty');
    System.assert(response.error == null, 'There are no exceptions');
  }
  @isTest
  static void testSuccessEmptyJSONResponse() {
    Lib_HttpMockCallout fakeResponse = new Lib_HttpMockCallout(
      200,
      'Complete',
      '{}',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'https://testapi.com/test',
      HTTP_METHOD.HTTP_POST,
      null,
      TEST_SUCCESS_BODY
    );
    System.assertEquals(
      'Complete',
      response.status,
      'The response status should be as expected.'
    );
    System.assertEquals(200, response.statusCode, 'Status code is 200');
    System.assert(response.successful, 'The callout was successful');
    System.assertEquals('{}', response.body, 'Response Body was empty JSON');
    System.assert(response.error == null, 'There are no exceptions');
  }
  @isTest
  static void testFailueResponse() {
    Lib_HttpMockCallout fakeResponse = new Lib_HttpMockCallout(
      500,
      'Server Error',
      TEST_FAILURE_BODY,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'https://testapi.com/test',
      HTTP_METHOD.HTTP_POST,
      null,
      TEST_SUCCESS_BODY
    );
    System.assertEquals(
      'Server Error',
      response.status,
      'The response status should be as expected.'
    );
    System.assertEquals(500, response.statusCode, 'Status code is 500');
    System.assert(!response.successful, 'The callout was not successful');
    System.assert(String.isBlank(response.body), 'Response Body is empty');
    System.assert(
      response.error instanceof CalloutException,
      'Callout exception'
    );
    System.assertEquals(
      TEST_FAILURE_BODY,
      response.error.getMessage(),
      'Error message matched'
    );
  }
}
