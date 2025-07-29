/**
 * @author Ashish Kumar
 * @since  July 2025
 * @description Repository class for Electronic Access APIs
 */
public with sharing class ElectronicAccessAPIRepository extends RepositoryBase {
  private static final ARNCService ARNC_SERVICE = (ARNCService) Lib_InstanceProvider.forType(
    ARNCService.class
  );

  /**
   * @param accNumber account number to query
   * @return result
   * @description calls the service class methods for integration/callout
   */
  public HttpCalloutResponse retrieveCardDetails(String accNumber) {
    HttpCalloutResponse response = ARNC_SERVICE.queryAccountRegistrations(
      accNumber
    );
    return handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorException(response);
    }
    if (!response.successful) {
      throw new UnhandledException(response);
    }
    return response;
  }

  /**
   * @description custom exception for server errors
   */
  public class ServerErrorException extends Exception {
    /**
     * @param response HttpCalloutResponse that caused the user error
     * @description constructs ServerErrorException with error message and logs info
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from ARNC_SERVICE',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception for user errors
   */
  public class UserErrorException extends Exception {
    /**
     * @param response HttpCalloutResponse that caused the user error
     * @description constructs UserErrorException with error message and logs info
     */
    public UserErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from ARNC_SERVICE',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception for unhandled errors
   */
  public class UnhandledException extends Exception {
    /**
     * @param response HttpCalloutResponse that caused the user error
     * @description constructs UnhandledException with error message and logs info
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledException ServiceName: <ARNC_SERVICE>',
          response.error
        )
        .save();
    }
  }
}
