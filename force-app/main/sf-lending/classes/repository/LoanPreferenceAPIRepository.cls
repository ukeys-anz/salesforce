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
  public Boolean updateLoanPreference(
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
      throw new ServerErrorLoanPreferenceException(
        response,
        'getCalculateLoanRepayment'
      );
    }
    if (response.statusCode == 400) {
      throw new UserErrorLoanPreferenceException(
        response,
        'getCalculateLoanRepayment'
      );
    }
    if (response.successful == false) {
      throw new UnhandledLoanPreferenceException(
        response,
        'getCalculateLoanRepayment'
      );
    }
    return LoanPreferenceResponseModel.parse(response.body);
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @return LoanPreferenceUpdateResponseModel processed viewModel
   */
  private static Boolean handleUpdateLoanPreference(
    HttpCalloutResponse response
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorLoanPreferenceException(
        response,
        'updateLoanPreference'
      );
    }
    if (response.statusCode == 400) {
      LoanPreferenceUpdateResponseModel responseModel = LoanPreferenceUpdateResponseModel.parse(
        response.error.getMessage()
      );
      throw new UserErrorLoanPreferenceException(
        response,
        'updateLoanPreference',
        responseModel?.errorCode
      );
    }
    if (response.successful == false) {
      throw new UnhandledLoanPreferenceException(
        response,
        'updateLoanPreference'
      );
    }

    return response.successful;
  }

  /**
   * @description Exception class for ServerError on get and update LoanPreference APIs
   */
  public class ServerErrorLoanPreferenceException extends Exception {
    /**
     * @description Exception class for ServerError on get and update LoanPreference APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public ServerErrorLoanPreferenceException(
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
   * @description Exception class for UserError on get and update LoanPreference APIs
   */
  public class UserErrorLoanPreferenceException extends Exception {
    /**
     * @description errorCode.
     */
    public Integer errorCode;
    /**
     * @description errorMessage.
     */
    public String errorMessage {
      get {
        return QueryUpdateLoanPrefErrorCodeMapping.getByMasterLabel(errorCode)
          ?.Message__c ?? 'Failed to update loan preference';
      }
    }
    /**
     * @description Exception class for UserError on get and update LoanPreference APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public UserErrorLoanPreferenceException(
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
    /**
     * @description Exception class for UserError on get and update LoanPreference APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     * @param errorCode
     */
    public UserErrorLoanPreferenceException(
      HttpCalloutResponse response,
      String serviceName,
      Integer errorCode
    ) {
      this(response.error.getMessage());
      this.errorCode = errorCode;
      Logger.info(
          'HTTP ' + response.statusCode + ' Error from ' + serviceName,
          response.error
        )
        .save();
    }
  }

  /**
   * @description Exception class for Unhandled on get and update LoanPreference APIs
   */
  public class UnhandledLoanPreferenceException extends Exception {
    /**
     * @description Exception class for Unhandled on get and update LoanPreference APIs
     * @param response HttpCalloutResponse
     * @param serviceName
     */
    public UnhandledLoanPreferenceException(
      HttpCalloutResponse response,
      String serviceName
    ) {
      this(response.error.getMessage());
      Logger.error('UnhandledException from  ' + serviceName, response.error)
        .save();
    }
  }

  /**
   * @param ocvId String
   * @param urlParams List<Object>
   * @param loanPrefData LexLoanappV1b1_loanapplication_types.LoanPreferences
   * @description Make callout and get the response for update Loan Preference
   * @return LexLoanappV1b1_loanapplication_types.LoanApplication
   */
  public LexLoanappV1b1_loanapplication_types.LoanApplication updateLoanPreference(
    String ocvId,
    List<Object> urlParams,
    LexLoanappV1b1_loanapplication_types.LoanPreferences loanPrefData
  ) {
    HttpCalloutResponse response = LP_SERVICE.updateLoanPreferenceDetails(
      ocvId,
      urlParams,
      loanPrefData
    );
    return handleUpdateLoanPreferenceDetails(
      response,
      String.valueOf(urlParams[0])
    );
  }

  /**
   * @description process the response received from callout
   * @param response Http Callout Response
   * @param loanAccNumber loanAccNumber
   * @return LexLoanappV1b1_loanapplication_types.LoanApplication
   */
  private static LexLoanappV1b1_loanapplication_types.LoanApplication handleUpdateLoanPreferenceDetails(
    HttpCalloutResponse response,
    String loanAccNumber
  ) {
    if (response.statusCode == 500) {
      throw new ServerErrorLoanPreferenceException(
        response,
        'updateLoanPreference'
      );
    }

    if (response.statusCode == 400) {
      Integer errorCode = (Integer) ((Map<String, Object>) JSON.deserializeUntyped(
          response.error?.getMessage()
        ))
        .get('errorCode');
      throw new UserErrorLoanPreferenceException(
        response,
        'updateLoanPreference',
        errorCode
      );
    }

    if (response.successful == false) {
      throw new UnhandledLoanPreferenceException(
        response,
        'updateLoanPreference'
      );
    }

    LexLoanappV1b1_loanapplication_types.LoanApplication updateloanloanResponse = (LexLoanappV1b1_loanapplication_types.LoanApplication) CalloutModel.deserialize(
      response.body,
      LexLoanappV1b1_loanapplication_types.LoanApplication.class
    );
    DataPartitionUtil.storeDataToCache(
      LoanApplicationAPIRepository.CACHE_DATA_KEY_PREFIX_GETLOANAPI +
      loanAccNumber,
      updateloanloanResponse
    );
    return updateloanloanResponse;
  }
}
