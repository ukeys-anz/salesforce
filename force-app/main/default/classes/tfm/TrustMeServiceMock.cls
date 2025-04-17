/**
 * @author Shivraj Kadam
 * @since APr 2025
 * @description Mock implementation of TrustMeService api service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class TrustMeServiceMock extends TrustMeService {
  /**
   * @description constructor which sets default status code and successful
   */
  public TrustMeServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  @TestVisible
  private static final String EVALUATION_RESPONSE = Service.getStaticResource(
    'trustMeMock'
  );
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
   * @param  staffModel StaffTokenRequestModel
   * @param caseUpdateDetails caseUpdateDetails
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public override HttpCalloutResponse updateCaseStatus(
    StaffTokenRequestModel staffModel,
    TrustMeCaseUpdateModel caseUpdateDetails
  ) {
    if (!preset) {
      response.body = '';
    }
    return response;
  }

  /**
   * @param  staffModel StaffTokenRequestModel
   * @param requestModel requestModel
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public override HttpCalloutResponse getTrustMeDocuments(
    StaffTokenRequestModel staffModel,
    TrustMeDocumentRequestModel requestModel
  ) {
    if (!preset) {
      response.body = ONBOARDING_DOCUMENTS_LIST;
    }
    return response;
  }
  /**
   * @param  staffModel StaffTokenRequestModel
   * @param evaluationId evaluationId
   * @return HttpCalloutResponse response
   * @description send parameter to update status
   */
  public override HttpCalloutResponse getEvaluationDetails(
    StaffTokenRequestModel staffModel,
    String evaluationId
  ) {
    if (!preset) {
      response.body = EVALUATION_RESPONSE;
    }
    return response;
  }

  /**
   * @description mock response for callout
   * @param statusCode statusCode
   * @return HttpCalloutResponse invalid response
   */
  @TestVisible
  private static HttpCalloutResponse setMockErrorResponse(Integer statusCode) {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.body = AUTHENTICATION_ERROR_RESPONSE;
    response.statusCode = statusCode;
    response.successful = false;
    response.error = new CalloutException(TFMConstants.SERVERERROR);
    return response;
  }
}