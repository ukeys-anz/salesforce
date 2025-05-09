/**
 * @author Pooja Kirtishahi
 * @since Nov 2024
 * @description service class for Loan Preference API callouts
 * @group Services
 */
public with sharing virtual class LoanPreferenceService extends Service {
  private static final Lib_HttpCallout HTTP_CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @description Fetches Loan Preference details from calculateLoanRepayment
   * @param requestModel LoanPreferenceRequestModel
   * @param ocvId OcvId of the Customer
   * @return HttpCalloutResponse
   */
  public virtual HttpCalloutResponse getLoanPrefDetails(
    LoanPreferenceRequestModel requestModel,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();

    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      Label.MS_CalculateLoanRepayment,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(requestModel)
    );
    return response;
  }

  /**
   * @description Send the Loan Preference record updates to the external system
   * @param ocvId String
   * @param urlParams List<Object>
   * @param updateLoanPreferenceRequestBody LoanPreferenceEditModel
   * @return `HttpCalloutResponse` the api response
   */
  public virtual HttpCalloutResponse updateLoanPreferenceDetails(
    String ocvId,
    List<Object> urlParams,
    LoanPreferenceEditModel updateLoanPreferenceRequestBody
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');
    String requestUrl = String.format(
      Label.MS_Update_LoanPreference,
      urlParams
    );
    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      requestUrl,
      HTTP_METHOD.HTTP_PATCH,
      headers,
      JSON.serialize(updateLoanPreferenceRequestBody)
    );
    return response;
  }
}
