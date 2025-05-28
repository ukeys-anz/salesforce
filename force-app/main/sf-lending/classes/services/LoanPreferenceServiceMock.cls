/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description Mock service class for Loan Preference
 */
public with sharing class LoanPreferenceServiceMock extends LoanPreferenceService {
  /**
   * @description constructor which sets default code as succesful
   */
  public LoanPreferenceServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final String LOAN_PREFERENCE_RESPONSE = getStaticResource(
    'mock_GetLoanPreference'
  );
  private static final String UPDATE_LOAN_PREFERENCE_RESPONSE = getStaticResource(
    'mock_UpdateLoanPreference'
  );

  /**
   * @param requestModel LoanPreferenceRequestModel
   * @param ocvId ocvId of customer
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for Loan Preference api
   */

  public override HttpCalloutResponse getLoanPrefDetails(
    LoanPreferenceRequestModel requestModel,
    String ocvId
  ) {
    if (!preset) {
      response.body = LoanPreferenceServiceMock.LOAN_PREFERENCE_RESPONSE;
    }
    return response;
  }

  /**
   * @param ocvId String
   * @param urlParams List<Object>
   * @param updateLoanPreferenceRequestBody LoanPreferenceEditModel
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for Loan Preference api
   */

  public override HttpCalloutResponse updateLoanPreferenceDetails(
    String ocvId,
    List<Object> urlParams,
    LoanPreferenceEditModel updateLoanPreferenceRequestBody
  ) {
    if (!preset) {
      response.body = LoanPreferenceServiceMock.UPDATE_LOAN_PREFERENCE_RESPONSE;
    }
    return response;
  }
}
