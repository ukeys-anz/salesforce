/**
 * @author Ashwin Mohan
 * @since  May 2025
 * @description Repository class for Loanapp APIs
 */

public with sharing class LoanAppAPIRepository extends RepositoryBase {
  private static final LoanappService LOANAPP_SERVICE = (LoanappService) Lib_InstanceProvider.forType(
    LoanappService.class
  );

  /**
   * @param requestModel ANZPlusLoanAppModel wrapper record
   * @return String
   * @description calls the ANZ Plus Loanapp service class methods for integration/callout
   */
  public String anzPlusLoanAppCallout(ANZPlusLoanAppModel requestModel) {
    HttpCalloutResponse response = LOANAPP_SERVICE.getANZPlusLoanappCalloutResponse(
      requestModel
    );
    response = handleResponse(response);
    return response.body;
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
          'HTTP ' + response.statusCode + ' Error from LOANAPP_SERVICE',
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
          'HTTP ' + response.statusCode + ' Error from LOANAPP_SERVICE',
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
          'UnhandledException ServiceName: <LOANAPP_SERVICE>',
          response.error
        )
        .save();
    }
  }
}
