/** @author CMOS
 * @since April 2026
 * @description Repo class for fetching Quality Assessments
 */
public with sharing class IDRQAService extends Service {
  /**
   * @param reqModel request body
   * @return HttpCalloutResponse response
   * @description to get the Quality Assessments from GCP
   */
  public HttpCalloutResponse getQualityAssessments(
    QualityAssessmentRequestModel reqModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    StaffTokenRequestModel staffModel = IDRQAService.setStaffModel(
      IDRConstants.QA_FORGE_RECORD
    );
    headers = setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.SF_QA_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(reqModel)
    );
    return response;
  }

  /**
   * @description method is setting common headers used in api callout
   * @param staffModel staff model
   * @return Map<String, String>
   */
  public Map<String, String> setCommonHeadersInMap(
    StaffTokenRequestModel staffModel
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = setCalloutCommonHeaders(staffModel);
    headers.put('Content-Type', 'application/json');
    return headers;
  }
  /**
   * @param scopes scope of the API
   * @return `StaffTokenRequestModel`
   * @description set StaffTokenRequestModel class instance
   */
  public static StaffTokenRequestModel setStaffModel(String scopes) {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.anzTokenType = 'staff';
    staffModel.apiScopesRequested = scopes;
    staffModel.realm = 'system';
    staffModel.isSecureWafFlow = true;
    return staffModel;
  }
}
