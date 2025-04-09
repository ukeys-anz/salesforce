/**
 * @author Kopal Goswami
 * @since March 2025
 * @description Repository class for fetching the Confirmation of Payee (CoP) status details for financial accounts.
 * @group Repository
 */
public with sharing class UpdateFinAccCOPStatusAPIRepository {
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
   * @description Updates the CoP status details for financial accounts via a Client-Initiated Backchannel Authorization (CIBA) call.
   * @param request A list of financial account update requests for CoP status modification.
   * @param ocvId The OCV ID of the customer.
   * @return FinancialAccModelUpdateResponseCoP Parsed response containing the updated CoP status details.
   */
  public FinancialAccModelUpdateResponseCoP updateAccountCoPdetails(
    FinancialAccModelUpdateRequestCoP request,
    String ocvId
  ) {
    HttpCalloutResponse response = SERVICE.updateAccountCoPdetails(
      JSON.serialize(request),
      ocvId
    );
    response = handleResponse(response);
    return FinancialAccModelUpdateResponseCoP.parse(response.body);
  }

  private static HttpCalloutResponse handleResponse(
    HttpCalloutResponse response
  ) {
    if (SERVER_ERROR_CODES.contains(response.statusCode)) {
      throw new ServerErrorException(response);
    }
    if (ACCESS_ERROR_CODES.contains(response.statusCode)) {
      throw new AccessErrorException(response);
    }
    if (response.successful == false) {
      throw new UnhandledException(response);
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
     */
    public ServerErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Error from Confirmation of Payee Service - Updating COP status of Accounts',
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
     */
    public AccessErrorException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' +
            response.statusCode +
            ' Error from Confirmation of Payee Service - Updating COP status of Accounts',
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
     */
    public UnhandledException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledException with: ' +
            response.statusCode +
            ' From Confirmation of Payee Service - Updating COP status of Accounts',
          response.error
        )
        .save();
    }
  }
}
