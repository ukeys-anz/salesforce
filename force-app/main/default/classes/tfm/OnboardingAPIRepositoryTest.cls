/**
 * @description       : Test Class for OnboardingAPIRepository
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 07-04-2024
 * @last modified by  : Anuj Jain
 **/
@IsTest
public with sharing class OnboardingAPIRepositoryTest {
  private static final String ONBOARDING_DOCUMENTS_LIST = Service.getStaticResource(
    'mock_OnboardingDocuments'
  );
  private static final String ONBOARDING_ACTION = Service.getStaticResource(
    'mock_OnboardingAction'
  );
  @isTest
  static void testfetchOnboardingDocumentsAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    OnboardingAPIRepository repo = new OnboardingAPIRepository();

    List<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);

    Test.startTest();
    OnboardingResponseModel response = repo.fetchOnboardingDocumentsAPI(
      staffModel,
      onboardingModelList
    );
    Test.stopTest();
    Assert.areEqual(
      4,
      response.DAONFile.size(),
      'Expecting 4 files in the response'
    );
  }

  @isTest
  static void testfetchOnboardingDocumentsAPIError() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String exceptionMsg;
    Integer statusCode = 500;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    OnboardingAPIRepository repo = new OnboardingAPIRepository();

    Test.startTest();
    list<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);
    try {
      OnboardingResponseModel response = repo.fetchOnboardingDocumentsAPI(
        staffModel,
        onboardingModelList
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Expecting server error'
    );
  }

  @isTest
  static void testfetchOnboardingDocumentsAPIError401() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String exceptionMsg;
    Integer statusCode = 401;
    String error = TFMConstants.INSUFFICIENT_ACCESS_ERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    OnboardingAPIRepository repo = new OnboardingAPIRepository();

    Test.startTest();
    list<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );
    onboardingModelList.add(onboardingModel);
    try {
      OnboardingResponseModel response = repo.fetchOnboardingDocumentsAPI(
        staffModel,
        onboardingModelList
      );
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      TFMConstants.INSUFFICIENT_ACCESS_ERROR,
      exceptionMsg,
      'Expecting server error'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    OnboardingAPIRepository repo = new OnboardingAPIRepository();

    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    HttpCalloutResponse response = new HttpCalloutResponse();
    Test.startTest();
    response = repo.updateCaseStatusAPI(staffModel, manageOpsRequest);
    Test.stopTest();
    Assert.areEqual(200, response.statusCode, 'CallOut is not successfully');
  }

  @isTest
  static void testUpdateCaseStatusAPIError() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String exceptionMsg;
    Integer statusCode = 500;
    String error = TFMConstants.SERVERERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    OnboardingAPIRepository repo = new OnboardingAPIRepository();
    HttpCalloutResponse response = new HttpCalloutResponse();
    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    try {
      response = repo.updateCaseStatusAPI(staffModel, manageOpsRequest);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      TFMConstants.SERVERERROR,
      exceptionMsg,
      'Expecting server error'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPIError401() {
    StaffTokenRequestModel staffModel = setStaffModel();
    String exceptionMsg;
    Integer statusCode = 401;
    String error = TFMConstants.INSUFFICIENT_ACCESS_ERROR;
    HttpCalloutResponse res = OnboardingServiceMock.setMockErrorResponse(
      statusCode,
      error
    );
    Service s = ServiceProvider.getService(OnboardingService.class);
    s.setCalloutResponse(res);
    OnboardingAPIRepository repo = new OnboardingAPIRepository();

    Test.startTest();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    HttpCalloutResponse response = new HttpCalloutResponse();
    try {
      response = repo.updateCaseStatusAPI(staffModel, manageOpsRequest);
    } catch (Exception e) {
      exceptionMsg = e.getMessage();
    }

    Test.stopTest();
    Assert.areEqual(
      TFMConstants.INSUFFICIENT_ACCESS_ERROR,
      exceptionMsg,
      'Expecting server error'
    );
  }

  private static StaffTokenRequestModel setStaffModel() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = '1122r5421';
    staffModel.anzTokenType = 'staffRqfCustomer';
    Cache.Session.put(
      'local.ForgeToken.forgeJWTToken' + staffModel.idValue,
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    return staffModel;
  }
}