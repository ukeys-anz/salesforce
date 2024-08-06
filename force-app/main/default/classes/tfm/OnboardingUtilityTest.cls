/**
 * @description       : Test Class for OnboardingUtility
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 07-04-2024
 * @last modified by  : Anuj Jain
 **/
@isTest
public with sharing class OnboardingUtilityTest {
  private static final String ONBOARDING_DOCUMENTS_LIST = Service.getStaticResource(
    'mock_OnboardingDocuments'
  );

  private static final String ONBOARDING_ACTION = Service.getStaticResource(
    'mock_OnboardingAction'
  );

  @isTest
  static void testfetchOnboardingDocumentsAPI() {
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    List<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);
    Map<String, Object> response = OnboardingUtility.fetchOnboardingDocumentsAPI(
      idValue,
      onboardingModelList
    );
    Test.stopTest();

    Assert.areEqual(
      'Success',
      response.get('responseMessage'),
      'API callout is unsuccessful.'
    );
  }

  @isTest
  static void testfetchOnboardingDocumentsAPIError500() {
    String exceptionMsg = 'The server encountered an unexpected error. Please retry after some time.';
    Integer statusCode = 500;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    List<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);
    Map<String, Object> response = OnboardingUtility.fetchOnboardingDocumentsAPI(
      idValue,
      onboardingModelList
    );
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'No exception has occurred, expecting 500 for server error'
    );
  }

  @isTest
  static void testfetchOnboardingDocumentsAPIError401() {
    String exceptionMsg = 'You don\'t have required permission to perform this action.';
    Integer statusCode = 401;
    String error = TFMConstants.INSUFFICIENT_ACCESS_ERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    list<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);

    Map<String, Object> response = OnboardingUtility.fetchOnboardingDocumentsAPI(
      idValue,
      onboardingModelList
    );
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'No exception has occurred, expecting 401 error of permission check'
    );
  }
  @isTest
  static void testfetchOnboardingDocumentsAPIError404() {
    String exceptionMsg = 'The server encountered an unexpected error. Please retry after some time.';
    Integer statusCode = 404;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    List<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);

    Map<String, Object> response = OnboardingUtility.fetchOnboardingDocumentsAPI(
      idValue,
      onboardingModelList
    );

    Test.stopTest();

    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'The server encountered an unexpected error. Please retry after some time.'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPI() {
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    Map<String, String> response = OnboardingUtility.updateCaseStatusAPI(
      idValue,
      manageOpsRequest,
      'OnboardingFalloutApprovalRejection'
    );
    Test.stopTest();

    Assert.areEqual(
      'Success',
      response.get('responseMessage'),
      'API callout is successful.'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPIError500() {
    String exceptionMsg = 'The server encountered an unexpected error. Please retry after some time.';
    Integer statusCode = 500;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    Map<String, String> response = OnboardingUtility.updateCaseStatusAPI(
      idValue,
      manageOpsRequest,
      'OnboardingFalloutApprovalRejection'
    );
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'Server error occurred.'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPIError401() {
    String exceptionMsg = 'You don\'t have required permission to perform this action.';
    Integer statusCode = 401;
    String error = TFMConstants.INSUFFICIENT_ACCESS_ERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    Map<String, String> response = OnboardingUtility.updateCaseStatusAPI(
      idValue,
      manageOpsRequest,
      'OnboardingFalloutApprovalRejection'
    );
    Test.stopTest();
    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      '401 error occurred.'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPIError404() {
    String exceptionMsg = 'The server encountered an unexpected error. Please retry after some time.';
    Integer statusCode = 404;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    String idValue = 'F7AE26D3-5AFA-427D-9DDC-fake';
    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    Map<String, String> response = OnboardingUtility.updateCaseStatusAPI(
      idValue,
      manageOpsRequest,
      'OnboardingFalloutApprovalRejection'
    );

    Test.stopTest();

    Assert.areEqual(
      exceptionMsg,
      response.get('responseMessage'),
      'The server encountered an unexpected error. Please retry after some time.'
    );
  }
}