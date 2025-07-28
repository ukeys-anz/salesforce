/**
 * @description Abstract base class for configuring HTTP response handling behaviour.
 * Provides a fluent interface for setting up logging, error handling, and validation
 * of HTTP callout responses. Supports various configuration strategies including
 * status code matching, formula-based evaluation, and composite configurations.
 */
public with sharing abstract class ResponseConfig {
  /**
   * @description The logging level to use when processing responses.
   */
  @TestVisible
  LoggingLevel logLevel = null;

  /**
   * @description The severity level for error logging.
   */
  @TestVisible
  Logger.Severity severity = Logger.Severity.MEDIUM;

  /**
   * @description Template message for logging, supports {code} and {service} placeholders.
   */
  @TestVisible
  String logMessage = 'HTTP {code} Response from {service}';

  /**
   * @description The exception type to throw when processing fails.
   */
  @TestVisible
  Type exceptionType = null;

  /**
   * @description Configures the response to be logged at INFO level.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig logAsInfo() {
    this.logLevel = LoggingLevel.INFO;
    return this;
  }

  /**
   * @description Configures the response to be logged at INFO level with a custom message.
   * @param message Custom log message template.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig logAsInfo(String message) {
    this.logMessage = message;
    this.logLevel = LoggingLevel.INFO;
    return this;
  }

  /**
   * @description Configures the response to be logged at ERROR level.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig logAsError() {
    this.logMessage = 'HTTP {code} Error from {service}';
    this.logLevel = LoggingLevel.ERROR;
    return this;
  }

  /**
   * @description Configures the response to be logged at ERROR level with a custom message.
   * @param message Custom error log message template.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig logAsError(String message) {
    this.logMessage = message;
    this.logLevel = LoggingLevel.ERROR;
    return this;
  }

  /**
   * @description Sets the logging severity to HIGH for error logs.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig severityHigh() {
    this.severity = Logger.Severity.HIGH;
    return this;
  }

  /**
   * @description Sets the logging severity to CRITICAL for error logs.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig severityCritical() {
    this.severity = Logger.Severity.CRITICAL;
    return this;
  }

  /**
   * @description Configures the response to throw a CalloutException when processed.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig fail() {
    this.exceptionType = CalloutException.class;
    return this;
  }

  /**
   * @description Configures the response to throw a specific exception type when processed.
   * @param exceptionType The type of exception to throw.
   * @return The current ResponseConfig instance for method chaining.
   */
  public ResponseConfig fail(Type exceptionType) {
    this.exceptionType = exceptionType;
    return this;
  }

  /**
   * @description Determines whether this configuration applies to the given HTTP response.
   * @param response The HTTP callout response to validate.
   * @return True if this configuration should be applied to the response, false otherwise.
   */
  public abstract Boolean isValid(HttpCalloutResponse response);

  /**
   * @description Processes the HTTP response according to this configuration.
   * Handles logging and exception throwing based on the configuration settings.
   * @param serviceName The name of the service being called.
   * @param response The HTTP callout response to process.
   * @return The processed HTTP response.
   */
  public virtual HttpCalloutResponse process(
    String serviceName,
    HttpCalloutResponse response
  ) {
    String msg = this.logMessage
      .replace('{service}', serviceName ?? '')
      .replace('{code}', String.valueOf(response.statusCode) ?? '');

    if (this.logLevel != null) {
      LogEventBuilder log = LoggerHelper.newEntry(this.logLevel)
        .setMessage(msg)
        .setExceptionDetails(response.error);
      if (this.logLevel == LoggingLevel.ERROR) {
        log.setSeverity(this.severity);
      }
      log.save();
    }

    if (this.exceptionType != null) {
      Exception ex = (Exception) this.exceptionType.newInstance();
      ex.setMessage(response.error?.getMessage() ?? msg);
      throw ex;
    }

    return response;
  }

  /**
   * @description Configuration that matches unsuccessful HTTP responses.
   * Applies to responses where the successful flag is false.
   */
  public class Unsuccessful extends ResponseConfig {
    /**
     * @description Validates whether the response is unsuccessful.
     * @param response The HTTP callout response to validate.
     * @return True if the response is unsuccessful, false otherwise.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      return response.successful == false;
    }
  }

  /**
   * @description Configuration that matches HTTP responses based on status codes.
   * Supports single codes, sets of codes, or ranges of codes.
   */
  public class Code extends ResponseConfig {
    /**
     * @description Set of specific status codes to match.
     */
    Set<Integer> codes = new Set<Integer>();

    /**
     * @description Starting code for range matching.
     */
    Integer fromCode = 0;

    /**
     * @description Ending code for range matching.
     */
    Integer toCode = 0;

    /**
     * @description Constructs a Code configuration for a single status code.
     * @param code The HTTP status code to match.
     */
    public Code(Integer code) {
      this.codes.add(code);
    }

    /**
     * @description Constructs a Code configuration for a set of status codes.
     * @param codes Set of HTTP status codes to match.
     */
    public Code(Set<Integer> codes) {
      this.codes = codes;
    }

    /**
     * @description Constructs a Code configuration for a range of status codes.
     * @param fromCode Starting status code (inclusive).
     * @param toCode Ending status code (inclusive).
     */
    public Code(Integer fromCode, Integer toCode) {
      this.fromCode = fromCode;
      this.toCode = toCode;
    }

    /**
     * @description Validates whether the response status code matches this configuration.
     * @param response The HTTP callout response to validate.
     * @return True if the status code matches, false otherwise.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      Integer code = response.statusCode;
      if (code == null) {
        return false;
      }
      if (this.codes.contains(code)) {
        return true;
      }
      return this.fromCode <= code && code <= this.toCode;
    }
  }

  /**
   * @description Abstract base class for formula-based response configurations.
   * Allows evaluation of complex conditions using formula expressions against
   * deserialised response data.
   */
  public abstract class FormulaConfig extends ResponseConfig {
    /**
     * @description The model class used for deserialising response data.
     */
    Type modelClass;

    /**
     * @description The formula expression to evaluate.
     */
    String formulaToEval;

    /**
     * @description Lazy-loaded formula instance for evaluation.
     */
    FormulaEval.FormulaInstance builder {
      get {
        return builder ??
          (builder = Formula.builder()
            .withType(this.modelClass)
            .withReturnType(FormulaEval.FormulaReturnType.Boolean)
            .withFormula(this.formulaToEval)
            .build());
      }
      set;
    }

    /**
     * @description Constructs a FormulaConfig with the specified model class.
     * @param modelClass The class used for deserialising response data.
     */
    public FormulaConfig(Type modelClass) {
      this.modelClass = modelClass;
    }

    /**
     * @description Sets the formula expression to evaluate.
     * @param formulaToEval The formula expression as a string.
     * @return The current FormulaConfig instance for method chaining.
     */
    public FormulaConfig when(String formulaToEval) {
      this.formulaToEval = formulaToEval;
      return this;
    }

    /**
     * @description Validates whether this formula configuration applies to the response.
     * @param response The HTTP callout response to validate.
     * @return True if the formula evaluation matches, false otherwise.
     */
    override public abstract Boolean isValid(HttpCalloutResponse response);
  }

  /**
   * @description Formula configuration that evaluates expressions against error response data.
   * Deserialises the error message as JSON and applies the formula to the resulting object.
   */
  public class Error extends FormulaConfig {
    /**
     * @description Constructs an Error configuration with the specified error model class.
     * @param errorModelClass The class used for deserialising error response data.
     */
    public Error(Type errorModelClass) {
      super(errorModelClass);
    }

    /**
     * @description Validates the response by evaluating the formula against the error data.
     * @param response The HTTP callout response to validate.
     * @return True if the formula evaluation succeeds and returns true, false otherwise.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      try {
        Object obj = JSON.deserialize(
          response.error.getMessage(),
          this.modelClass
        );
        return (Boolean) super.builder.evaluate(obj);
      } catch (Exception ex) {
        return false;
      }
    }
  }

  /**
   * @description Formula configuration that evaluates expressions against response payload data.
   * Deserialises the response body as JSON and applies the formula to the resulting object.
   */
  public class Payload extends FormulaConfig {
    /**
     * @description Constructs a Payload configuration with the specified payload model class.
     * @param payloadModelClass The class used for deserialising response payload data.
     */
    public Payload(Type payloadModelClass) {
      super(payloadModelClass);
    }

    /**
     * @description Validates the response by evaluating the formula against the payload data.
     * @param response The HTTP callout response to validate.
     * @return True if the formula evaluation succeeds and returns true, false otherwise.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      try {
        Object obj = JSON.deserialize(response.body, this.modelClass);
        return (Boolean) super.builder.evaluate(obj);
      } catch (Exception ex) {
        return false;
      }
    }
  }

  /**
   * @description Composite configuration that requires all child configurations to match.
   * Implements logical AND behaviour across multiple response configurations.
   */
  public class AllMatch extends ResponseConfig {
    /**
     * @description List of child configurations that must all match.
     */
    List<ResponseConfig> childConfigs;

    /**
     * @description Constructs an AllMatch configuration with the specified child configurations.
     * @param configs List of response configurations that must all match.
     */
    public AllMatch(List<ResponseConfig> configs) {
      this.childConfigs = configs;
    }

    /**
     * @description Validates the response against all child configurations.
     * @param response The HTTP callout response to validate.
     * @return True if all child configurations match, false if any fail to match.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      for (ResponseConfig config : this.childConfigs) {
        if (!config.isValid(response)) {
          return false;
        }
      }
      return true;
    }
  }

  /**
   * @description Composite configuration that requires at least one child configuration to match.
   * Implements logical OR behaviour across multiple response configurations.
   */
  public class AnyMatch extends ResponseConfig {
    /**
     * @description List of child configurations where at least one must match.
     */
    List<ResponseConfig> childConfigs;

    /**
     * @description Constructs an AnyMatch configuration with the specified child configurations.
     * @param configs List of response configurations where at least one must match.
     */
    public AnyMatch(List<ResponseConfig> configs) {
      this.childConfigs = configs;
    }

    /**
     * @description Validates the response against child configurations.
     * @param response The HTTP callout response to validate.
     * @return True if any child configuration matches, false if none match.
     */
    override public Boolean isValid(HttpCalloutResponse response) {
      for (ResponseConfig config : this.childConfigs) {
        if (config.isValid(response)) {
          return true;
        }
      }
      return false;
    }
  }
}
