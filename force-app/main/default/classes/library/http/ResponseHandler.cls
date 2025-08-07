/**
 * @description Handles HTTP callout responses by applying configured response processing rules.
 * Provides a flexible framework for processing HTTP responses with custom configurations
 * and sensible defaults for common error scenarios. Supports fluent configuration
 * and priority-based rule evaluation.
 */
public with sharing class ResponseHandler {
  /**
   * @description Default response configurations applied when no custom base configurations are specified.
   * Includes standard handling for client errors (4xx), server errors (5xx), and general failures.
   */
  static final List<ResponseConfig> DEFAULT_CONFIGS = new List<ResponseConfig>{
    new ResponseConfig.Code(400, 499)
      .logAsInfo('HTTP {code} Access Error from {service}')
      .fail(RepositoryBase.InsufficientAccessException.class),
    new ResponseConfig.Code(500, 599)
      .logAsError('HTTP {code} Server Error from {service}')
      .fail(RepositoryBase.ServerErrorException.class),
    new ResponseConfig.Unsuccessful()
      .logAsError('HTTP {code} Unhandled Error from {service}')
      .fail(RepositoryBase.UnhandledException.class)
  };

  /**
   * @description The name of the service for which responses are being handled.
   */
  String serviceName;

  /**
   * @description Base configurations that override the default configurations.
   */
  List<ResponseConfig> baseConfigs;

  /**
   * @description Custom configurations that take priority over base configurations.
   */
  List<ResponseConfig> customConfigs = new List<ResponseConfig>();

  /**
   * @description Constructs a ResponseHandler for the specified service.
   * @param serviceName The name of the service being handled.
   */
  public ResponseHandler(String serviceName) {
    this.serviceName = serviceName;
  }

  /**
   * @description Sets custom base configurations to replace the default configurations.
   * @param baseConfigs List of base response configurations.
   * @return The current ResponseHandler instance for method chaining.
   */
  public ResponseHandler defaults(List<ResponseConfig> baseConfigs) {
    this.baseConfigs = baseConfigs;
    return this;
  }

  /**
   * @description Adds a single custom configuration with higher priority than base configurations.
   * @param config The response configuration to add.
   * @return The current ResponseHandler instance for method chaining.
   */
  public ResponseHandler config(ResponseConfig config) {
    this.customConfigs.add(config);
    return this;
  }

  /**
   * @description Adds multiple custom configurations with higher priority than base configurations.
   * @param configs List of response configurations to add.
   * @return The current ResponseHandler instance for method chaining.
   */
  public ResponseHandler config(List<ResponseConfig> configs) {
    this.customConfigs.addAll(configs);
    return this;
  }

  /**
   * @description Processes an HTTP callout response using the configured response rules.
   * Evaluates configurations in priority order: custom configurations first, then base
   * configurations (or defaults if no base configurations are specified). The first
   * matching configuration is applied and processing stops.
   * @param response The HTTP callout response to process.
   * @return The processed HTTP response.
   */
  public HttpCalloutResponse process(HttpCalloutResponse response) {
    List<ResponseConfig> configs = new List<ResponseConfig>();
    configs.addAll(this.customConfigs);
    configs.addAll(this.baseConfigs ?? DEFAULT_CONFIGS);

    for (ResponseConfig config : configs) {
      if (config.isValid(response)) {
        return config.process(this.serviceName, response);
      }
    }
    return response;
  }
}
