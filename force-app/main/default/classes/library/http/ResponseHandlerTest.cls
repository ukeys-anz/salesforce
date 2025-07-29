/**
 * @description Test class for ResponseHandler functionality.
 * Validates response processing behaviour including custom configurations,
 * default configurations, and error handling scenarios.
 * @author Tan Phan
 * @since 06/2025
 * @group Library
 */
@IsTest
private class ResponseHandlerTest {
  @IsTest
  static void processWithNoMatchingConfigReturnsOriginalResponse() {
    ResponseHandler handler = new ResponseHandler('TestService');
    HttpCalloutResponse originalResponse = new HttpCalloutResponse();
    originalResponse.statusCode = 200;
    originalResponse.successful = true;

    HttpCalloutResponse result = handler.process(originalResponse);

    Assert.areEqual(
      originalResponse,
      result,
      'Should return the original response when no matching configuration is found'
    );
  }

  @IsTest
  static void processWithCustomConfigPriority() {
    ResponseConfig customConfig = new TestResponseConfig(true, 'Custom');
    ResponseConfig baseConfig = new TestResponseConfig(true, 'Base');

    ResponseHandler handler = new ResponseHandler('TestService')
      .config(customConfig)
      .defaults(new List<ResponseConfig>{ baseConfig });

    HttpCalloutResponse response = new HttpCalloutResponse();

    try {
      handler.process(response);
      Assert.fail(
        'Should have thrown exception when custom configuration matches'
      );
    } catch (TestException ex) {
      Assert.areEqual(
        'Custom',
        ex.getMessage(),
        'Should prioritise custom configuration over base configuration'
      );
    }
  }

  @IsTest
  static void processWithBaseConfigOverridesDefaults() {
    ResponseConfig baseConfig = new TestResponseConfig(true, 'Base');

    ResponseHandler handler = new ResponseHandler('TestService')
      .defaults(new List<ResponseConfig>{ baseConfig });

    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 400;

    try {
      handler.process(response);
      Assert.fail(
        'Should have thrown exception when base configuration matches'
      );
    } catch (TestException ex) {
      Assert.areEqual(
        'Base',
        ex.getMessage(),
        'Should use base configuration when it matches the response'
      );
    }
  }

  @IsTest
  static void processWithDefaultConfigsForClientError() {
    ResponseHandler handler = new ResponseHandler('TestService');
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 404;

    try {
      handler.process(response);
      Assert.fail('Should have thrown exception for client error status code');
    } catch (RepositoryBase.InsufficientAccessException ex) {
      Assert.isTrue(
        ex.getMessage().contains('Access Error'),
        'Exception message should contain "Access Error" for client error'
      );
    }
  }

  @IsTest
  static void processWithDefaultConfigsForServerError() {
    ResponseHandler handler = new ResponseHandler('TestService');
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.statusCode = 500;

    try {
      handler.process(response);
      Assert.fail('Should have thrown exception for server error status code');
    } catch (RepositoryBase.ServerErrorException ex) {
      Assert.isTrue(
        ex.getMessage().contains('Server Error'),
        'Exception message should contain "Server Error" for server error'
      );
    }
  }

  @IsTest
  static void processWithDefaultConfigsForUnsuccessful() {
    ResponseHandler handler = new ResponseHandler('TestService');
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.successful = false;
    response.statusCode = 999;

    try {
      handler.process(response);
      Assert.fail('Should have thrown exception for unsuccessful response');
    } catch (RepositoryBase.UnhandledException ex) {
      Assert.isTrue(
        ex.getMessage().contains('Unhandled Error'),
        'Exception message should contain "Unhandled Error" for unhandled error'
      );
    }
  }

  @IsTest
  static void processWithMultipleCustomConfigs() {
    ResponseConfig firstConfig = new TestResponseConfig(false, 'First');
    ResponseConfig secondConfig = new TestResponseConfig(true, 'Second');

    ResponseHandler handler = new ResponseHandler('TestService')
      .config(firstConfig)
      .config(secondConfig);

    HttpCalloutResponse response = new HttpCalloutResponse();

    try {
      handler.process(response);
      Assert.fail(
        'Should have thrown exception when a custom configuration matches'
      );
    } catch (TestException ex) {
      Assert.areEqual(
        'Second',
        ex.getMessage(),
        'Should use the first matching configuration from multiple custom configurations'
      );
    }
  }

  @IsTest
  static void processWithCustomConfigList() {
    List<ResponseConfig> customConfigs = new List<ResponseConfig>{
      new TestResponseConfig(false, 'First'),
      new TestResponseConfig(true, 'Second')
    };

    ResponseHandler handler = new ResponseHandler('TestService')
      .config(customConfigs);

    HttpCalloutResponse response = new HttpCalloutResponse();

    try {
      handler.process(response);
      Assert.fail(
        'Should have thrown exception when a configuration from the list matches'
      );
    } catch (TestException ex) {
      Assert.areEqual(
        'Second',
        ex.getMessage(),
        'Should use the first matching configuration from the configuration list'
      );
    }
  }

  private class TestResponseConfig extends ResponseConfig {
    private Boolean shouldMatch;
    private String exceptionMessage;

    private TestResponseConfig(Boolean shouldMatch, String exceptionMessage) {
      this.shouldMatch = shouldMatch;
      this.exceptionMessage = exceptionMessage;
      this.fail(TestException.class);
    }

    public override Boolean isValid(HttpCalloutResponse response) {
      return this.shouldMatch;
    }

    public override HttpCalloutResponse process(
      String serviceName,
      HttpCalloutResponse response
    ) {
      throw new TestException(this.exceptionMessage);
    }
  }

  private class TestException extends Exception {
  }
}
