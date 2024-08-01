/**
 * @description       : Test Class for OnboardingService
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 06-28-2024
 * @last modified by  : Anuj Jain
 **/

@isTest
public with sharing class OnboardingServiceTest {
  private static final String ONBOARDING_DOCUMENTS_LIST = Service.getStaticResource(
    'mock_OnboardingDocuments'
  );
  private static final String ONBOARDING_ACTION = Service.getStaticResource(
    'mock_OnboardingAction'
  );
  private static final String SUCCESS_ONOBOARDING_RESPONSE =
    '{' +
    '   \"status\": { \"code\": 200, \"description\": \"SUCCESS\" },' +
    '}';
  private static final String ERROR_ONOBOARDING_RESPONSE =
    '{' +
    '   \"status\": { \"code\": 500, \"description\": \"ERROR\" },' +
    '}';

  @isTest
  static void testfetchOnboardingDocumentsAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockOnboardingResponseSuccess());
    Test.startTest();
    OnboardingService service = new OnboardingService();
    list<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingRequestModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );

    onboardingModelList.add(onboardingRequestModel);
    HttpCalloutResponse response = service.fetchOnboardingDocumentsAPI(
      staffModel,
      onboardingModelList
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is successful,expecting status code:200'
    );
  }

  @isTest
  static void testfetchOnboardingDocumentsAPIError() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockOnboardingResponseError());
    Test.startTest();
    OnboardingService service = new OnboardingService();
    list<OnboardingRequestModel> onboardingModelList = new List<OnboardingRequestModel>();
    OnboardingRequestModel onboardingRequestModel = OnboardingRequestModel.parse(
      ONBOARDING_DOCUMENTS_LIST
    );

    onboardingModelList.add(onboardingRequestModel);
    HttpCalloutResponse response = service.fetchOnboardingDocumentsAPI(
      staffModel,
      onboardingModelList
    );

    Test.stopTest();
    Assert.areEqual(
      500,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPI() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockOnboardingResponseSuccess());
    Test.startTest();
    OnboardingService service = new OnboardingService();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );

    HttpCalloutResponse response = service.updateCaseStatusAPI(
      staffModel,
      manageOpsRequest
    );

    Test.stopTest();
    Assert.areEqual(
      200,
      response.statusCode,
      'Callout is successful,expecting status code:200'
    );
  }

  @isTest
  static void testUpdateCaseStatusAPIError() {
    StaffTokenRequestModel staffModel = setStaffModel();
    Test.setMock(HttpCalloutMock.class, new MockOnboardingResponseError());
    Test.startTest();
    OnboardingService service = new OnboardingService();
    ManageOpsWorkflowRequestModel manageOpsRequest = ManageOpsWorkflowRequestModel.parse(
      ONBOARDING_ACTION
    );
    HttpCalloutResponse response = service.updateCaseStatusAPI(
      staffModel,
      manageOpsRequest
    );

    Test.stopTest();
    Assert.areEqual(
      500,
      response.statusCode,
      'Callout is unsuccessful,expecting status code:200'
    );
  }

  private static StaffTokenRequestModel setStaffModel() {
    StaffTokenRequestModel staffModel = new StaffTokenRequestModel();
    staffModel.idType = Service.IdType.UUID;
    staffModel.idValue = 'x00Bm000008L9jfake';
    staffModel.anzTokenType = 'staffRqfCustomer';
    Cache.Session.put(
      'local.ForgeToken.' + AuthTokenCacheUtil.getHashedKey('forgeJWTToken' + staffModel.idValue + staffModel.apiScopesRequested),
      AuthServiceTest.IDTESTVALUEFORGE2,
      300,
      Cache.Visibility.NAMESPACE,
      false
    );
    return staffModel;
  }

  class MockOnboardingResponseSuccess implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(200);
      res.setBody(SUCCESS_ONOBOARDING_RESPONSE);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }

  class MockOnboardingResponseError implements HttpCalloutMock {
    /**
     * @description mock response for callout
     * @param req incoming request
     * @return HTTPResponse success response
     */
    public HTTPResponse respond(HTTPRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(500);
      res.setBody(ERROR_ONOBOARDING_RESPONSE);
      res.setHeader('Content-Type', 'application/json');
      return res;
    }
  }
}