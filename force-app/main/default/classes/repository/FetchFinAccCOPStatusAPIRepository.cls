/**
 * @author Kopal Goswami
 * @since March 2025
 * @description Repository class for fetching the Confirmation of Payee (CoP) status details for financial accounts.
 * @group Repository
 */
public with sharing class FetchFinAccCOPStatusAPIRepository {
  private static final ConfirmationOfPayeeService SERVICE = (ConfirmationOfPayeeService) Lib_InstanceProvider.forType(
    ConfirmationOfPayeeService.class
  );

  private static final Set<Integer> SUCCESS_CODES = new Set<Integer>{
    200,
    206
  };
  private static final Set<Integer> SERVER_ERROR_CODES = new Set<Integer>{
    500
  };
  private static final Set<Integer> ACCESS_ERROR_CODES = new Set<Integer>{
    401,
    403
  };

  /**
   * @description Retrieves the Confirmation of Payee (CoP) status details for financial accounts.
   * @param request The request payload containing account details for CoP status retrieval.
   * @param ocvId The OCV ID of the customer.
   * @return FinancialAccountModelGetResponseCoP Parsed response containing the CoP status details.
   */

  public FinancialAccountModelGetResponseCoP getAccountCoPdetails(
    AccountCoPStatusRequestModel request,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.getAccountCoPdetails(
      JSON.serialize(request),
      ocvId
    );
    response = handleResponse(
      response,
      'Confirmation of Payee Service - Fetching COP status of Accounts'
    );
    return FinancialAccountModelGetResponseCoP.parse(response.body);
  }

  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response,
    String serviceName
  ) {
    if (SERVER_ERROR_CODES.contains(response.statusCode)) {
      throw new ServerErrorException(response, serviceName);
    }
    if (ACCESS_ERROR_CODES.contains(response.statusCode)) {
      throw new AccessErrorException(response, serviceName);
    }
    if (response.successful == false) {
      throw new UnhandledException(response, serviceName);
    }
    return response;
  }

  /**
   * @description ServerErrorException custom exception
   */
  public class ServerErrorException extends Exception {
    /**
     * @description ServerErrorException custom exception
     * @param response
     * @param serviceName
     */
    public ServerErrorException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from ' + serviceName,
          response.error
        )
        .save();
    }
  }

  /**
   * @description AccessErrorException custom exception
   */
  public class AccessErrorException extends Exception {
    /**
     * @description AccessErrorException custom exception
     * @param response
     * @param serviceName
     */
    public AccessErrorException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from ' + serviceName,
          response.error
        )
        .save();
    }
  }

  /**
   * @description UnhandledException custom exception
   */

  public class UnhandledException extends Exception {
    /**
     * @description AccessErrorException custom exception
     * @param response
     * @param serviceName
     */
    public UnhandledException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error('UnhandledException from: ' + serviceName, response.error)
        .save();
    }
  }
}
