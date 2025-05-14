/**
 * @author ramvilas
 * @since May 2025
 * @description Home loan history repository for all Home Loan History callouts
 * @group Repository
 */
public with sharing class HomeLoanHistoryAPIRepository extends RepositoryBase {
  private static final HomeLoanHistoryService HL_SERVICE = (HomeLoanHistoryService) Lib_InstanceProvider.forType(
    HomeLoanHistoryService.class
  );

  /**
   * @param ocvId ocv id
   * @param loanAccNumber param to get list of loanAccount changes
   * @return `LoanAccountChangesModel`
   * @description fetches listofLoanAccountChanges from lex, deserialized to a model
   */
  public LoanAccountChangesModel getListOfLoanAccountChanges(
    String ocvId,
    String loanAccNumber
  ) {
    HttpCalloutResponse response = HL_SERVICE.getListOfLoanAccountChanges(
      ocvId,
      loanAccNumber
    );

    return handleGetLoanAccountChangeResponse(response);
  }
  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return LoanAccountChangesModel
   */
  private static LoanAccountChangesModel handleGetLoanAccountChangeResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorGetLoanAccountChangeException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorGetLoanAccountChangeException(response);
    }
    if (!response.successful) {
      throw new UnhandledGetLoanAccountChangeException(response);
    }
    return LoanAccountChangesModel.parse(response.body);
  }

  /**
   * @description Exception class for ServerError on Get Loan Account Changes
   */
  public class ServerErrorGetLoanAccountChangeException extends Exception {
    /**
     * @description Exception class for ServerError Get Loan Account Changes
     * @param response HttpCalloutResponse
     */
    public ServerErrorGetLoanAccountChangeException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from HomeLoanHistoryService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for UserError on Get Loan Account Changes
   */
  public class UserErrorGetLoanAccountChangeException extends Exception {
    /**
     * @description Exception class for UserError Get Loan Account Changes
     * @param response HttpCalloutResponse
     */
    public UserErrorGetLoanAccountChangeException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from HomeLoanHistoryService',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled Get Loan Account Changes
   */
  public class UnhandledGetLoanAccountChangeException extends Exception {
    /**
     * @description Exception class for Unhandled Get Loan Account Changes
     * @param response HttpCalloutResponse
     */
    public UnhandledGetLoanAccountChangeException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetLoanAccountChangeException HomeLoanHistoryService: getListOfLoanAccountChanges',
          response.error
        )
        .save();
    }
  }
}
