/**
 * @description       : APIRepository class for OnboardingService
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 06-17-2024
 * @last modified by  : Anuj Jain
 **/
public with sharing class OnboardingAPIRepository {
  /**
   * @param staffModel model to call staffJWT api
   * @param onboardingModelList model to call api
   * @return OnboardingResponseModel response
   * @description make API callout to fetchDocument and handle response
   */
  public OnboardingResponseModel fetchOnboardingDocumentsAPI(
    StaffTokenRequestModel staffModel,
    List<OnboardingRequestModel> onboardingModelList
  ) {
    OnboardingService s = (OnboardingService) ServiceProvider.getService(
      OnboardingService.class
    );
    HttpCalloutResponse response = s.fetchOnboardingDocumentsAPI(
      staffModel,
      onboardingModelList
    );
    HttpCalloutResponse handledResponse = handleResponse(response);
    OnboardingResponseModel onboardingModel = OnboardingResponseModel.parse(
      handledResponse.body
    );
    return onboardingModel;
  }

  /**
   * @param staffModel model to call staffJWT api
   * @param manageOpsRequest ManageOpsWorkflowRequestModel instance
   * @return HttpCalloutResponse response
   * @description send parameter to update mobile number
   */
  public HttpCalloutResponse updateCaseStatusAPI(
    StaffTokenRequestModel staffModel,
    ManageOpsWorkflowRequestModel manageOpsRequest
  ) {
    OnboardingService s = (OnboardingService) ServiceProvider.getService(
      OnboardingService.class
    );
    HttpCalloutResponse response = s.updateCaseStatusAPI(
      staffModel,
      manageOpsRequest
    );
    return handleResponse(response);
  }

  /**
   * @param response HttpCalloutResponse model to be handled
   * @return HttpCalloutResponse response
   * @description handle received response and either return the response or throw exception
   */
  public HttpCalloutResponse handleResponse(HttpCalloutResponse response) {
    if (response.successful || response.statusCode == 206) {
      return response;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw new InsufficientAccessException(response.error.getMessage());
    } else if (response.statusCode == 500) {
      throw new ServerErrorException(response.error.getMessage());
    } else {
      throw response.error;
    }
  }

  /**
   * @description custom exception
   */
  public class InsufficientAccessException extends Exception {
  }
  /**
   * @description custom exception
   */
  public class ServerErrorException extends Exception {
  }
}