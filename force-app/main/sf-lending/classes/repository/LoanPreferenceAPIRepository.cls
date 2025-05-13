/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description API repository for Loan Preference callouts
 * @group Repository
 */
public with sharing class LoanPreferenceAPIRepository extends RepositoryBase {
  private static final LoanPreferenceService LP_SERVICE = (LoanPreferenceService) Lib_InstanceProvider.forType(
    LoanPreferenceService.class
  );

  /**
   * @description fetches loan preferances, deserialized to a model
   * @param requestModel LoanPreferenceRequestModel
   * @param ocvId OcvId of the Customer
   * @return LoanPreferenceResponseModel
   */
  public LoanPreferenceResponseModel getCalculateLoanRepayment(
    LoanPreferenceRequestModel requestModel,
    String ocvId
  ) {
    HttpCalloutResponse response = LP_SERVICE.getLoanPrefDetails(
      requestModel,
      ocvId
    );
    return handleGetCalculateLoanRepaymentResponse(response);
  }

  /**
   * @param ocvId String
   * @param urlParams List<Object>
   * @param requestBody LoanPreferenceEditModel
   * @description Make callout and get the response for update Loan Preference
   * @return LoanPreferenceUpdateResponseModel
   */
  public LoanPreferenceUpdateResponseModel updateLoanPreference(
    String ocvId,
    List<Object> urlParams,
    LoanPreferenceEditModel requestBody
  ) {
    HttpCalloutResponse response = LP_SERVICE.updateLoanPreferenceDetails(
      ocvId,
      urlParams,
      requestBody
    );
    return handleUpdateLoanPreference(response);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return LoanPreferenceResponseModel processed viewModel
   */
  private static LoanPreferenceResponseModel handleGetCalculateLoanRepaymentResponse(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorGetCalculateLoanRepaymentException(response);
    }
    if (response.statusCode == 400) {
      throw new UserErrorGetCalculateLoanRepaymentException(response);
    }
    if (!response.successful) {
      throw new UnhandledGetCalculateLoanRepaymentException(response);
    }
    return LoanPreferenceResponseModel.parse(response.body);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return LoanPreferenceUpdateResponseModel processed viewModel
   */
  private static LoanPreferenceUpdateResponseModel handleUpdateLoanPreference(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorUpdateLoanPreferenceException(response);
    }
    if (response.statusCode == 400) {
      LoanPreferenceUpdateResponseModel responseModel = LoanPreferenceUpdateResponseModel.parse(
        response.error.getMessage()
      );
      responseModel.successful = response.successful;
      responseModel.message = QueryUpdateLoanPrefErrorCodeMapping.getByMasterLabel(
          responseModel.errorCode
        )
        ?.Message__c ?? '';
      return responseModel;
    }
    if (!response.successful) {
      throw new UnhandledUpdateLoanPreferenceException(response);
    }

    LoanPreferenceUpdateResponseModel responseModel = LoanPreferenceUpdateResponseModel.parse(
      response.body
    );
    responseModel.successful = response.successful;

    return responseModel;
  }

  /**
   * @description Exception class for ServerError on Get Calucalte Loan Repayment
   */
  public class ServerErrorGetCalculateLoanRepaymentException extends Exception {
    /**
     * @description Exception class for ServerError Get Calculate Loan Repayment
     * @param response HttpCalloutResponse
     */
    public ServerErrorGetCalculateLoanRepaymentException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for UserError on Get Calucalte Loan Repayment
   */
  public class UserErrorGetCalculateLoanRepaymentException extends Exception {
    /**
     * @description Exception class for UserError Get Calculate Loan Repayment
     * @param response HttpCalloutResponse
     */
    public UserErrorGetCalculateLoanRepaymentException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled Get Calucalte Loan Repayment
   */
  public class UnhandledGetCalculateLoanRepaymentException extends Exception {
    /**
     * @description Exception class for Unhandled Get Calculate Loan Repayment
     * @param response HttpCalloutResponse
     */
    public UnhandledGetCalculateLoanRepaymentException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetSOPException LoanPreferenceService: getLoanPrefDetails',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for ServerError on UpdateLoanPreference
   */
  public class ServerErrorUpdateLoanPreferenceException extends Exception {
    /**
     * @description Exception class for ServerError UpdateLoanPreference
     * @param response HttpCalloutResponse
     */
    public ServerErrorUpdateLoanPreferenceException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'HTTP ' +
            response.statusCode +
            ' Error from UpdateLoanPreference Service',
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled UpdateLoanPreference
   */
  public class UnhandledUpdateLoanPreferenceException extends Exception {
    /**
     * @description Exception class for Unhandled UpdateLoanPreference
     * @param response HttpCalloutResponse
     */
    public UnhandledUpdateLoanPreferenceException(
      HttpCalloutResponse response
    ) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledUpdateLoanPreferenceException LoanPreferenceService: UpdateLoanPreference',
          response.error
        )
        .save();
    }
  }
}
