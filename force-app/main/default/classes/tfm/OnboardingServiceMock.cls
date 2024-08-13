/**
 * @description       : OnboardingServiceMock
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 06-04-2024
 * @last modified by  : Anuj Jain
 **/
public with sharing class OnboardingServiceMock extends OnboardingService {
  /**
   * @description constructor which sets default status code and successful
   */
  public OnboardingServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String ONBOARDING_DOCUMENTS_LIST = Service.getStaticResource(
    'mock_OnboardingDocumentsResponse'
  );
  @TestVisible
  public static final String AUTHENTICATION_ERROR_RESPONSE =
    '{' +
    '   \"error\": \"16 UNAUTHENTICATED: authentication failed\"' +
    '}';

  /**
   * @param staffModel model to call staffJWT api
   * @param onboardingModelList onboardingModelList
   * @return HttpCalloutResponse api response
   * @description fetchOnboardingDocumentsAPI
   */
  public override HttpCalloutResponse fetchOnboardingDocumentsAPI(
    StaffTokenRequestModel staffModel,
    List<OnboardingRequestModel> onboardingModelList
  ) {
    if (!preset) {
      response.body = ONBOARDING_DOCUMENTS_LIST;
    }
    return response;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param manageOpsRequest ManageOpsWorkflowRequestModel instance
   * @return HttpCalloutResponse api response
   * @description fetchOnboardingDocumentsAPI
   */
  public override HttpCalloutResponse updateCaseStatusAPI(
    StaffTokenRequestModel staffModel,
    ManageOpsWorkflowRequestModel manageOpsRequest
  ) {
    if (!preset) {
      response.body = '';
    }
    return response;
  }

  /**
   * @description mock response for callout
   * @param statusCode
   * @param error
   * @return HttpCalloutResponse invalid response
   */
  @TestVisible
  private static HttpCalloutResponse setMockErrorResponse(
    Integer statusCode,
    String error
  ) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = statusCode;
    response.successful = false;
    response.error = new CalloutException(error);
    return response;
  }
}