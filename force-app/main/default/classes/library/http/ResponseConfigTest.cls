/**
 * @description Test class for ResponseConfig functionality.
 * Validates configuration behaviour including logging, exception handling,
 * status code matching, error evaluation, and composite configuration patterns.
 * @author Tan Phan
 * @since 06/2025
 * @group Library
 */
@IsTest
global class ResponseConfigTest {
  @IsTest
  static void testSetterChainingMethods() {
    ResponseConfig config = new ResponseConfig.Code(200);
    config.logAsInfo();
    Assert.areEqual(
      LoggingLevel.INFO,
      config.logLevel,
      'Should set log level to INFO'
    );

    config.logAsInfo('info log message');
    Assert.areEqual(
      LoggingLevel.INFO,
      config.logLevel,
      'Should set log level to INFO'
    );
    Assert.areEqual(
      'info log message',
      config.logMessage,
      'Should set info log message'
    );

    config.logAsError();
    Assert.areEqual(
      LoggingLevel.ERROR,
      config.logLevel,
      'Should set log level to ERROR'
    );

    config.logAsError('error log message');
    Assert.areEqual(
      LoggingLevel.ERROR,
      config.logLevel,
      ' Should set log level to ERROR'
    );
    Assert.areEqual(
      'error log message',
      config.logMessage,
      'Should set error log message'
    );

    config.severityHigh();
    Assert.areEqual(
      Logger.Severity.HIGH,
      config.severity,
      'Should set severity to HIGH when calling severityHigh()'
    );

    config.severityCritical();
    Assert.areEqual(
      Logger.Severity.CRITICAL,
      config.severity,
      'Should set severity to CRITICAL when calling severityCritical()'
    );

    config.fail();
    Assert.areEqual(
      CalloutException.class,
      config.exceptionType,
      'Should default to CalloutException'
    );

    config.fail(IllegalArgumentException.class);
    Assert.areEqual(
      IllegalArgumentException.class,
      config.exceptionType,
      'Should set custom exception type'
    );
  }

  @IsTest
  static void processWithLoggingCreatesLogEntry() {
    ResponseConfig config = new TestResponseConfig()
      .logAsInfo('Test message for {service} with code {code}');

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;

    Test.startTest();
    HttpCalloutResponse result = config.process('TestService', response);
    Test.stopTest();

    Assert.areEqual(
      response,
      result,
      'Should return the original response after processing'
    );
  }

  @IsTest
  static void processWithErrorLoggingSetsSeverity() {
    ResponseConfig config = new TestResponseConfig()
      .logAsError('Error from {service}')
      .severityHigh();

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 500;

    Test.startTest();
    HttpCalloutResponse result = config.process('TestService', response);
    Test.stopTest();

    Assert.areEqual(
      response,
      result,
      'Should return the original response after processing'
    );
  }

  @IsTest
  static void processWithExceptionThrowsConfiguredException() {
    ResponseConfig config = new TestResponseConfig()
      .fail(CalloutException.class);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('Test error');

    try {
      config.process('TestService', response);
      Assert.fail(
        'Should have thrown CalloutException when configured to fail'
      );
    } catch (CalloutException ex) {
      Assert.areEqual(
        'Test error',
        ex.getMessage(),
        'Should throw exception with original error message'
      );
    }
  }

  @IsTest
  static void processWithExceptionNoErrorUsesLogMessage() {
    ResponseConfig config = new TestResponseConfig()
      .logAsError('Custom error message')
      .fail(CalloutException.class);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 500;

    try {
      config.process('TestService', response);
      Assert.fail(
        'Should have thrown CalloutException when configured to fail'
      );
    } catch (CalloutException ex) {
      Assert.areEqual(
        'Custom error message',
        ex.getMessage(),
        'Should use custom log message when no error is present'
      );
    }
  }

  @IsTest
  static void unsuccessfulWithSuccessfulResponseReturnsFalse() {
    ResponseConfig config = new ResponseConfig.Unsuccessful();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = true;

    Boolean result = config.isValid(response);

    Assert.isFalse(result, 'Should return false for successful responses');
  }

  @IsTest
  static void unsuccessfulWithUnsuccessfulResponseReturnsTrue() {
    ResponseConfig config = new ResponseConfig.Unsuccessful();
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;

    Boolean result = config.isValid(response);

    Assert.isTrue(result, 'Should return true for unsuccessful responses');
  }

  @IsTest
  static void codeWithSingleCodeMatchesCorrectly() {
    ResponseConfig config = new ResponseConfig.Code(404);

    HttpCalloutResponse matchingResponse = new HttpCalloutResponse();
    matchingResponse.statusCode = 404;

    HttpCalloutResponse nonMatchingResponse = new HttpCalloutResponse();
    nonMatchingResponse.statusCode = 200;

    Assert.isTrue(
      config.isValid(matchingResponse),
      'Should match response with specified status code'
    );
    Assert.isFalse(
      config.isValid(nonMatchingResponse),
      'Should not match response with different status code'
    );
  }

  @IsTest
  static void codeWithCodeSetMatchesCorrectly() {
    Set<Integer> codes = new Set<Integer>{ 400, 401, 403 };
    ResponseConfig config = new ResponseConfig.Code(codes);

    HttpCalloutResponse matchingResponse = new HttpCalloutResponse();
    matchingResponse.statusCode = 401;

    HttpCalloutResponse nonMatchingResponse = new HttpCalloutResponse();
    nonMatchingResponse.statusCode = 404;

    Assert.isTrue(
      config.isValid(matchingResponse),
      'Should match response with status code in the set'
    );
    Assert.isFalse(
      config.isValid(nonMatchingResponse),
      'Should not match response with status code not in the set'
    );
  }

  @IsTest
  static void codeWithRangeMatchesCorrectly() {
    ResponseConfig config = new ResponseConfig.Code(400, 499);

    HttpCalloutResponse matchingResponse = new HttpCalloutResponse();
    matchingResponse.statusCode = 404;

    HttpCalloutResponse nonMatchingResponse = new HttpCalloutResponse();
    nonMatchingResponse.statusCode = 500;

    Assert.isTrue(
      config.isValid(matchingResponse),
      'Should match response with status code within the range'
    );
    Assert.isFalse(
      config.isValid(nonMatchingResponse),
      'Should not match response with status code outside the range'
    );
  }

  @IsTest
  static void codeWithNullStatusCodeReturnsFalse() {
    ResponseConfig config = new ResponseConfig.Code(404);
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = null;

    Boolean result = config.isValid(response);

    Assert.isFalse(result, 'Should return false when status code is null');
  }

  @IsTest
  static void errorWithValidFormulaEvaluatesCorrectly() {
    ResponseConfig config = new ResponseConfig.Error(TestErrorModel.class)
      .when('errorCode == "PAYMENT_FAILED"');

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException(
      '{"errorCode":"PAYMENT_FAILED","message":"Insufficient funds"}'
    );

    Boolean result = config.isValid(response);

    Assert.isTrue(
      result,
      'Should return true when error formula evaluates correctly'
    );
  }

  @IsTest
  static void errorWithInvalidJsonReturnsFalse() {
    ResponseConfig config = new ResponseConfig.Error(TestErrorModel.class)
      .when('errorCode == "PAYMENT_FAILED"');

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('invalid json');

    Boolean result = config.isValid(response);

    Assert.isFalse(
      result,
      'Should return false when error contains invalid JSON'
    );
  }

  @IsTest
  static void payloadWithValidFormulaEvaluatesCorrectly() {
    ResponseConfig config = new ResponseConfig.Payload(TestPayloadModel.class)
      .when('amount > 1000');

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = '{"amount":1500,"currency":"USD"}';

    Boolean result = config.isValid(response);

    Assert.isTrue(
      result,
      'Should return true when payload formula evaluates correctly'
    );
  }

  @IsTest
  static void payloadWithInvalidJsonReturnsFalse() {
    ResponseConfig config = new ResponseConfig.Payload(TestPayloadModel.class)
      .when('amount > 1000');

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = 'invalid json';

    Boolean result = config.isValid(response);

    Assert.isFalse(
      result,
      'Should return false when payload contains invalid JSON'
    );
  }

  @IsTest
  static void allMatchWithAllValidConfigsReturnsTrue() {
    List<ResponseConfig> childConfigs = new List<ResponseConfig>{
      new ResponseConfig.Code(200),
      new ResponseConfig.Unsuccessful()
    };
    ResponseConfig config = new ResponseConfig.AllMatch(childConfigs);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;
    response.successful = false;

    Boolean result = config.isValid(response);

    Assert.isTrue(
      result,
      'Should return true when all child configurations are valid'
    );
  }

  @IsTest
  static void allMatchWithOneInvalidConfigReturnsFalse() {
    List<ResponseConfig> childConfigs = new List<ResponseConfig>{
      new ResponseConfig.Code(200),
      new ResponseConfig.Code(404)
    };
    ResponseConfig config = new ResponseConfig.AllMatch(childConfigs);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;

    Boolean result = config.isValid(response);

    Assert.isFalse(
      result,
      'Should return false when any child configuration is invalid'
    );
  }

  @IsTest
  static void anyMatchWithOneValidConfigReturnsTrue() {
    List<ResponseConfig> childConfigs = new List<ResponseConfig>{
      new ResponseConfig.Code(200),
      new ResponseConfig.Code(404)
    };
    ResponseConfig config = new ResponseConfig.AnyMatch(childConfigs);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;

    Boolean result = config.isValid(response);

    Assert.isTrue(
      result,
      'Should return true when at least one child configuration is valid'
    );
  }

  @IsTest
  static void anyMatchWithNoValidConfigsReturnsFalse() {
    List<ResponseConfig> childConfigs = new List<ResponseConfig>{
      new ResponseConfig.Code(404),
      new ResponseConfig.Code(500)
    };
    ResponseConfig config = new ResponseConfig.AnyMatch(childConfigs);

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 200;

    Boolean result = config.isValid(response);

    Assert.isFalse(
      result,
      'Should return false when no child configurations are valid'
    );
  }

  private class TestResponseConfig extends ResponseConfig {
    public override Boolean isValid(HttpCalloutResponse response) {
      return true;
    }
  }

  /**
   * @description Model class for testing parsing error message
   */
  global class TestErrorModel {
    global String errorCode;
    global String message;
  }

  /**
   * @description Model class for testing parsing response body
   */
  global class TestPayloadModel {
    global Integer amount;
    global String currencyCode;
  }
}
