/**
 * @author Hitesh
 * @since  July 2025
 * @description Repository class for Financial Summary APIs
 */

public with sharing class FinancialSummaryAPIRepository extends RepositoryBase {
  private static final FinancialSummaryService FINSUM_SERVICE = (FinancialSummaryService) Lib_InstanceProvider.forType(
    FinancialSummaryService.class
  );
  private static final String ERROR_RESPONSE = 'Unexpected error';

  /**
   * @param endPoint - endpoint to which we have to make a callout
   * @param requestObj - searlized wrapper object
   * @param useStaffToken - Boolean if JWE Staff token is used
   * @return String Return Finanacial Summary Response value
   * @description get financial summary response
   */
  public HttpCalloutResponse getFinancialSummaryResponse(
    String endPoint,
    String requestObj,
    Boolean useStaffToken
  ) {
    HttpCalloutResponse response = FINSUM_SERVICE.getFinancialSummaryResponse(
      endPoint,
      requestObj,
      useStaffToken
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
    if (response.successful == false) {
      throw new UnhandledException(response);
    }
    return response;
  }

  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description constructor for ServerErrorException
     * @param response HttpCalloutResponse
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from FinancialSummaryService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class UserErrorException extends Exception {
    /**
     * @description constructor for UserErrorException
     * @param response HttpCalloutResponse
     */
    public UserErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from FinancialSummaryService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description custom exception
   */
  public class UnhandledException extends Exception {
    /**
     * @description constructor for UnhandledException
     * @param response HttpCalloutResponse
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledException ServiceName: <FinancialSummaryService>',
          response.error
        )
        .save();
    }
  }
}
