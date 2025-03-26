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
  public LoanPreferenceResponseModel getViewLoanPreference(
    LoanPreferenceRequestModel requestModel,
    String ocvId
  ) {
    HttpCalloutResponse response = LP_SERVICE.getLoanPrefDetails(
      requestModel,
      ocvId
    );
    return handleGetLoanPrefResponse(response);
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
  private static LoanPreferenceResponseModel handleGetLoanPrefResponse(
    HttpCalloutResponse response
  ) {
    if (response.successful == false) {
      throw new UnhandledGetLoanPreferenceException(response);
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
    LoanPreferenceUpdateResponseModel responseModel = LoanPreferenceUpdateResponseModel.parse(
      response.successful ? response.body : response.error.getMessage()
    );
    responseModel.successful = response.successful;
    if (responseModel.successful) {
      return responseModel;
    }

    String errorCodeStr = String.valueOf(responseModel.errorCode);
    responseModel.message = QueryErrorCodeMessageMapping.getByMasterLabel(
        errorCodeStr
      )
      ?.Message__c ?? '';
    return responseModel;
  }

  /**
   * @description Exception class for Unhandled Get Loan Preference
   */
  public class UnhandledGetLoanPreferenceException extends Exception {
    /**
     * @description Exception class for Unhandled Get Loan Preference
     * @param response HttpCalloutResponse
     */
    public UnhandledGetLoanPreferenceException(HttpCalloutResponse response) {
      this(response.error.getMessage());
      Logger.error(
          'UnhandledGetSOPException LoanPreferenceService: getLoanPrefDetails',
          response.error
        )
        .save();
    }
  }
}
