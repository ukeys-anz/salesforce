/**
 * @description       : API call for Onboarding documents
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 06-28-2024
 * @last modified by  : Anuj Jain
 **/
public with sharing virtual class OnboardingService extends Service {
  TFMCommonFunctionUtility commonFuncs = new TFMCommonFunctionUtility();

  /**
   * @param staffModel model to call staffJWT api
   * @param onboardingModelList onboardingModelList
   * @return HttpCalloutResponse response
   * @description send parameter to fetch onboarding
   */
  public virtual HttpCalloutResponse fetchOnboardingDocumentsAPI(
    StaffTokenRequestModel staffModel,
    List<OnboardingRequestModel> onboardingModelList
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_OnboardingUpload_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(onboardingModelList)
    );
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param manageOpsRequest ManageOpsWorkflowRequestModel instance
   * @return HttpCalloutResponse response
   * @description send parameter to fetch onboarding
   */
  public virtual HttpCalloutResponse updateCaseStatusAPI(
    StaffTokenRequestModel staffModel,
    ManageOpsWorkflowRequestModel manageOpsRequest
  ) {
    Map<String, String> headers = new Map<String, String>();
    headers = commonFuncs.setCommonHeadersInMap(staffModel);
    headers.put('action', staffModel.apiScopesRequested);
    
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_OnboardingUpdateStatus_API,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(manageOpsRequest)
    );

    return response;
  }
}