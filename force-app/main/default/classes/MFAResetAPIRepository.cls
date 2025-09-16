/**
 * @description Repository for handling Multi-Factor Authentication (MFA) reset operations,
 * providing methods to obtain elevated tokens and execute MFA resets for brokers.
 *
 * @created      2025-08-30 Manish Bisht
 * @lastModified 2025-08-30 Manish Bisht
 */
public with sharing class MFAResetAPIRepository extends RepositoryBase {
  private static final MFAResetService MFA_RESET_SERVICE = (MFAResetService) Lib_InstanceProvider.forType(
    MFAResetService.class
  );

  /**
   * @description Retrieves an elevated token for a specified user using their email and a staff token.
   *
   * @param userEmail The email address of the user for whom the elevated token is requested.
   * @param staffToken The token provided by staff for authorization in the request.
   * @return MFAResetElevatedTokenModel The model containing the elevated token information.
   */
  public String getElevatedToken(String userEmail, String staffToken) {
    HttpCalloutResponse response = MFA_RESET_SERVICE.getElevatedToken(
      userEmail,
      staffToken
    );
    return handleMFAElevatedTokenResponse(response);
  }

  /**
   * @description Initiates the MFA reset process for a broker using the provided elevated token.
   *
   * @param elevatedToken The token obtained from the elevated token request, used for authorization in the MFA reset call.
   * @return Boolean Indicates whether the MFA reset was successful.
   */
  public Boolean resetMFA(String elevatedToken) {
    HttpCalloutResponse response = MFA_RESET_SERVICE.resetMFA(elevatedToken);
    return handleMFAResetResponse(response);
  }

  /**
   * @description Processes the response received from the elevated token request, handling various error cases.
   *
   * @param response The HTTP callout response from the elevated token request.
   * @return the elevated token.
   * @throws ServerErrorMFAResetAPIException If a server error occurs.
   * @throws UserErrorMFAResetAPIException If a user error occurs.
   * @throws UnhandledMFAResetAPIException If an unhandled error occurs.
   * @throws UnexpectedResponseMFAResetAPIException If the response does not contain the expected access token.
   */
  @testVisible
  private static String handleMFAElevatedTokenResponse(
    HttpCalloutResponse response
  ) {
    if (response.successful) {
      MFAResetElevatedTokenModel apiResponse = MFAResetElevatedTokenModel.parse(
        response.body
      );
      if (String.isNotBlank(apiResponse?.accessToken)) {
        return apiResponse?.accessToken;
      }
      throw new UnexpectedResponseMFAResetAPIException(
        response,
        'getElevatedToken',
        'Access token not found in the response at key "access_token"'
      );
    }
    if (response.statusCode >= 500) {
      throw new ServerErrorMFAResetAPIException(response, 'getElevatedToken');
    }
    if (response.statusCode >= 400) {
      throw new UserErrorMFAResetAPIException(response, 'getElevatedToken');
    }
    throw new UnhandledMFAResetAPIException(response, 'getElevatedToken');
  }

  /**
   * @description Processes the response received from the MFA reset request, handling various error cases.
   *
   * @param response The HTTP callout response from the MFA reset request.
   * @return Boolean Indicates whether the MFA reset was successful.
   * @throws ServerErrorMFAResetAPIException If a server error occurs.
   * @throws UserErrorMFAResetAPIException If a user error occurs.
   * @throws UnhandledMFAResetAPIException If an unhandled error occurs.
   * @throws UnexpectedResponseMFAResetAPIException If the response does not contain the expected value.
   */
  @testVisible
  private static Boolean handleMFAResetResponse(HttpCalloutResponse response) {
    if (
      response.successful && MFAResetModel.parse(response.body).isResetSuccess()
    ) {
      return true;
    } else if (response.successful) {
      throw new UnexpectedResponseMFAResetAPIException(
        response,
        'resetMFA',
        'MFA reset API returned an unsuccessful response. Expected value "1" at JSON path: removedByDeviceType.TYPE_OATH_TOTP'
      );
    }
    if (response.statusCode >= 500) {
      throw new ServerErrorMFAResetAPIException(response, 'resetMFA');
    }
    if (response.statusCode >= 400) {
      throw new UserErrorMFAResetAPIException(response, 'resetMFA');
    }
    throw new UnhandledMFAResetAPIException(response, 'resetMFA');
  }

  /**
   * @description Exception thrown when a server error occurs during the MFA reset API operations.
   */
  public class ServerErrorMFAResetAPIException extends Exception {
    /**
     * @description Constructor; builds exeption object, and Log the error with response payload.
     *
     * @param response HTTP response from service.
     * @param serviceName name of the failed service(method) where this exception occured.
     */
    public ServerErrorMFAResetAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error?.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName: ' +
            serviceName,
          response.error
        )
        .setPayload(response.body)
        .setExceptionDetails(this)
        .save();
    }
  }

  /**
   * @description Exception thrown when a user error occurs during the MFA reset API operations.
   */
  public class UserErrorMFAResetAPIException extends Exception {
    /**
     * @description Constructor; builds exeption object, and Log the error with response payload.
     *
     * @param response HTTP response from service.
     * @param serviceName name of the failed service(method) where this exception occured.
     */
    public UserErrorMFAResetAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error?.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName: ' +
            serviceName,
          response.error
        )
        .setPayload(response.body)
        .setExceptionDetails(this)
        .save();
    }
  }

  /**
   * @description Exception thrown for unhandled errors that occur during the MFA reset API operations.
   */
  public class UnhandledMFAResetAPIException extends Exception {
    /**
     * @description Constructor; builds exeption object, and Log the error with response payload.
     *
     * @param response HTTP response from service.
     * @param serviceName name of the failed service(method) where this exception occured.
     */
    public UnhandledMFAResetAPIException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error?.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName: ' +
            serviceName,
          response.error
        )
        .setPayload(response.body)
        .setExceptionDetails(this)
        .save();
    }
  }

  /**
   * @description Exception thrown when the response from the MFA reset API does not match expected values.
   */
  public class UnexpectedResponseMFAResetAPIException extends Exception {
    /**
     * @description Constructor; builds exeption object, and Log the error with response payload.
     *
     * @param response HTTP response from service.
     * @param serviceName name of the failed service(method) where this exception occured.
     * @param errorMessage a custom error message for exception
     */
    public UnexpectedResponseMFAResetAPIException(
      HttpCalloutResponse response,
      String serviceName,
      String errorMessage
    ) {
      this(errorMessage);
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from ServiceName: ' +
            serviceName,
          response.error
        )
        .setPayload(response.body)
        .setExceptionDetails(this)
        .save();
    }
  }
}
