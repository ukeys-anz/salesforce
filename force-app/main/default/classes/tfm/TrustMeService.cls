/**
 * @author Shivraj Kadam
 * @since Feb 2025
 * @description Service class for TrustMe
 * @group Service
 */
public with sharing virtual class TrustMeService extends Service {
  private static Map<String, String> sfRecordTypeToWorkflow = new Map<String, String>{
    'TrustMe_eIDV_Case' => 'trustMeManual',
    'TrustMe_eIDV_QA_Case' => 'trustMeQA',
    'ReKYC_QA_Case' => 'reKYC'
  };
  TFMCommonFunctionUtility commonFuncs = new TFMCommonFunctionUtility();
  /**
   * @param  staffModel StaffTokenRequestModel
   * @param  caseUpdateDetails caseUpdateDetails
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public virtual HttpCalloutResponse updateCaseStatus(
    StaffTokenRequestModel staffModel,
    TrustMeCaseUpdateModel caseUpdateDetails
  ) {
    String actionUrl = System.Label.MS_TrustMe_CaseUpdate;
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    headers.put(
      'workflow',
      sfRecordTypeToWorkflow.get(caseUpdateDetails.case_type)
    );
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      actionUrl,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(caseUpdateDetails)
    );
    return response;
  }

  /**
   * @description Retrieves documents
   * @param  staffModel StaffTokenRequestModel 
   * @param requestModel requestModel
   * @return HttpCalloutResponse response
   */
  public virtual HttpCalloutResponse getTrustMeDocuments(
    StaffTokenRequestModel staffModel,
    TrustMeDocumentRequestModel requestModel
  ) {
    String actionUrl = System.Label.MS_TrustMe_UploadAttachments;
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      actionUrl,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(requestModel)
    );
    return response;
  }

  /**
   * @description Retrieves Evaluation Details
   * @param  staffModel StaffTokenRequestModel 
   * @param evaluationId evaluationId
   * @return HttpCalloutResponse response
   */
  public virtual HttpCalloutResponse getEvaluationDetails(
    StaffTokenRequestModel staffModel,
    String evaluationId
  ) {
    String actionUrl = System.Label.MS_TrustMe_GetEvaluationDetails;
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    String body = createRequestBody(evaluationId);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      actionUrl,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
    return response;
  }

  private static String createRequestBody(String evaluationId) {
    Map<String,String> requestBody = new Map<String,String>();
    requestBody.put('id',evaluationId);
    return JSON.serialize(requestBody);
  }
}