/**
 * @author ramvilas
 * @since May 2025
 * @description API repository for Loan Application callouts
 * @group Repository
 */
public with sharing class LoanApplicationAPIRepository extends RepositoryBase {
  private static final LoanApplicationService LA_SERVICE = (LoanApplicationService) Lib_InstanceProvider.forType(
    LoanApplicationService.class
  );

  /**
   * @param loanAppNumber loan application number
   * @param ocvId ocv id of the customer account
   * @return `HttpCalloutResponse` response
   * @description cancelResidentialLoanApp cancels a residential loan application
   */
  public HttpCalloutResponse cancelResidentialLoanApp(
    String loanAppNumber,
    String ocvId
  ) {
    HttpCalloutResponse response = LA_SERVICE.cancelResidentialLoanApp(
      loanAppNumber,
      ocvId
    );
    return handleCancelResidentialLoanApp(response);
  }
  /**
   * @param response loan application number
   * @return `HttpCalloutResponse` response
   * @description cancelResidentialLoanApp cancels a residential loan application
   */
  private HttpCalloutResponse handleCancelResidentialLoanApp(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorLoanApplicationException(
        response,
        'cancelResidentialLoanApp'
      );
    }
    if (response.statusCode == 400) {
      throw new UserErrorLoanApplicationException(
        response,
        'cancelResidentialLoanApp'
      );
    }
    if (response.successful == false) {
      throw new UnhandledLoanApplicationException(
        response,
        'cancelResidentialLoanApp'
      );
    }

    return response;
  }

  /**
   * @description Exception class for ServerError on LoanApplication APIs
   */
  public class ServerErrorLoanApplicationException extends Exception {
    /**
     * @description Exception class for ServerError on LoanApplication APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public ServerErrorLoanApplicationException(
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
   * @description Exception class for UserError on LoanApplication APIs
   */
  public class UserErrorLoanApplicationException extends Exception {
    /**
     * @description Exception class for UserError on LoanApplication APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public UserErrorLoanApplicationException(
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
   * @description Exception class for Unhandled on LoanApplication APIs
   */
  public class UnhandledLoanApplicationException extends Exception {
    /**
     * @description Exception class for Unhandled on LoanApplication APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public UnhandledLoanApplicationException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error('UnhandledException from  ' + serviceName, response.error)
        .save();
    }
  }
}
